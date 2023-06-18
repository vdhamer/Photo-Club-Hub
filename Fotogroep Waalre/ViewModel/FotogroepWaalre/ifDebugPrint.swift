//
//  ifDebugPrint.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/03/2023.
//

private let debugMode = false

func ifDebugPrint(_ string: String) {
    if debugMode {
        print(string)
    }
}
