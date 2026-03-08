//
//  String+random.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 08/03/2025.
//

extension String {

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
        return randomString
    }

}
