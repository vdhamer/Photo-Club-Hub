//
//  ifDebugUtils.swift - various utilities that trigger if the app is build is in DEBUG mode
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/03/2023.
//

import Foundation       // for NSLock

// MARK: - ifDebugPrint

public func ifDebugPrint(_ string: String) {
    #if DEBUG
        print(string)
    #endif
}

// MARK: - ifDebugFatalError

public func ifDebugFatalError(_ string: String) {
    #if DEBUG
        if let spy = installedIfDebugFatalErrorSpy() {
            spy.record(string) // a test installed a spy taht records instead of crashes (the RELEASE-mode path)
            print("ifDebugFatalError triggered, but was bypassed: \(string)") // may help noticing messages
            return
        }
        fatalError(string)
    #else
        // not sure anybody can see this
        print("UnFatal error in RELEASE mode: \(string)")
    #endif
}

// normally the value passed for file should be #fileID (and line should receive #line)
// Note that in Swift 6.0, #fileID may be needed because #file is deprecated
// no point in providing defaults for file & line (would be this file)
public func ifDebugFatalError(_ string: String, file: StaticString, line: UInt) {
    #if DEBUG
        if let spy = installedIfDebugFatalErrorSpy() {
            spy.record(string) // a test installed a spy: record instead of crashing (the RELEASE-mode path)
            print("ifDebugFatalError triggered, but was bypassed: \(string)")
            return
        }
        fatalError(string, file: file, line: line)
    #else
        // not sure anybody can see this
        print("UnFatal error in RELEASE mode: \(string) in line #\(line) of \(file)")
    #endif
}

// MARK: - inDebugMode

public var inDebugMode: Bool {
    #if DEBUG
        true
    #else
        false
    #endif
}

// MARK: - test spy for ifDebugFatalError fatalError handling during testing

// The installed spy is process-global: while it is installed, EVERY ifDebugFatalError — including one from
// unrelated code running in parallel — is recorded rather than crashing. Tests should therefore install a
// spy only briefly, and remove it in a `defer`.
// NSLock (not Mutex) because ifDebugFatalError itself must be able to run on iOS 17.
private let installedSpyLock = NSLock()
// swiftlint:disable:next identifier_name
nonisolated(unsafe) private var installedSpy_: (any IfDebugFatalErrorSpying)? // only touch under installedSpyLock

public func installIfDebugFatalErrorSpy(_ ifDebugFatalErrorSpy: any IfDebugFatalErrorSpying) {
    installedSpyLock.lock()
    defer { installedSpyLock.unlock() }
    installedSpy_ = ifDebugFatalErrorSpy
}

public func removeIfDebugFatalErrorSpy() {
    installedSpyLock.lock()
    defer { installedSpyLock.unlock() }
    installedSpy_ = nil
}

private func installedIfDebugFatalErrorSpy() -> (any IfDebugFatalErrorSpying)? {
    installedSpyLock.lock()
    defer { installedSpyLock.unlock() }
    return installedSpy_
}
