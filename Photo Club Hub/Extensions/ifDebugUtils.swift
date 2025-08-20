//
//  ifDebugUtils.swift - various utilities that trigger if the app is build is in DEBUG mode
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/03/2023.
//

public func ifDebugPrint(_ string: String) {
    #if DEBUG
        print(string)
    #endif
}

public func ifDebugFatalError(_ string: String) {
    #if DEBUG
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
        fatalError(string, file: file, line: line)
    #else
        // not sure anybody can see this
        print("UnFatal error in RELEASE mode: \(string) in line #\(line) of \(file)")
    #endif
}

public var isDebug: Bool {
    #if DEBUG
        true
    #else
        false
    #endif
}
