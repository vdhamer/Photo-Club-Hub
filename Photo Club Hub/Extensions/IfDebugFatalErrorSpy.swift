//
//  IfDebugFatalErrorSpy.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import Foundation       // for NSLock (iOS 17 version)
import Synchronization  // for Mutex (iOS 18+ version)

/// Test seam for `ifDebugFatalError`:
/// while a spy is installed via `installIfDebugFatalErrorSpy(_:)`, a DEBUG build records the message
/// on the spy and continues (the RELEASE-mode path) instead of crashing on `fatalError`.
/// This lets a test deliberately trigger a debug-fatal guard and assert that it fired.
/// See `ifDebugUtils.swift` for the install/remove API and the private glue that wires the spy into ifDebugFatalError`.
public protocol IfDebugFatalErrorSpying: Sendable {
    func record(_ message: String)
    var messages: [String] { get }
}

/// iOS 18+ version of the spy, protected by a `Synchronization.Mutex` (same pattern as `Level1History`).
@available(iOS 18, macOS 15, *)
public final class IfDebugFatalErrorSpy1827: IfDebugFatalErrorSpying, Sendable {

    public init() { } // making init() public can be needed when invoked from another module

    // swiftlint:disable:next identifier_name
    private let messages_ = Mutex<[String]>([]) // trailing underscore: the wrapped core behind `messages`

    public var messages: [String] {
        messages_.withLock { $0 }
    }

    public func record(_ message: String) {
        messages_.withLock { $0.append(message) }
    }

}

/// iOS 17 version of the spy, that uses `NSLock` because `Mutex` requires iOS 18.
/// Delete this class (and the corresponding `makeIfDebugFatalErrorSpy` branch) when iOS 17 support is dropped.
@available(iOS, obsoleted: 18.0, message: "Please use 'IfDebugFatalErrorSpy1827' for versions above iOS 18.x")
public final class IfDebugFatalErrorSpy1717: IfDebugFatalErrorSpying, @unchecked Sendable {

    private let lock = NSLock()

    public init() { } // making init() public can be needed when invoked from another module

    // swiftlint:disable:next identifier_name
    private var messages_: [String] = [] // trailing underscore: the wrapped core behind `messages`

    public var messages: [String] {
        lock.lock()
        defer { lock.unlock() }
        return messages_
    }

    public func record(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        messages_.append(message)
    }

}

/// Returns a spy implementation that works on the OS the test is running on.
public func makeIfDebugFatalErrorSpy() -> any IfDebugFatalErrorSpying {
    if #available(iOS 18, macOS 15, *) {
        IfDebugFatalErrorSpy1827()
    } else {
        IfDebugFatalErrorSpy1717() // delete this branch when iOS 17 support is dropped
    }
}
