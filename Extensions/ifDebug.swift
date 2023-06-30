//
//  ifDebug.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/03/2023.
//

func ifDebugPrint(_ string: String) {
    #if DEBUG
        print(string)
    #endif
}

func ifDebugFatalError(_ string: String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
    fatalError(string, file: file, line: line)
    #else
        print("UnFatal error in RELEASE mode: \(string)")
    #endif
}

func isDebug() -> Bool {
    #if DEBUG
        true
    #else
        false
    #endif
}
