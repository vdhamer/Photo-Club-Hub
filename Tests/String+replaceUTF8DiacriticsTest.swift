//
//  String+replaceUTF8DiacriticsTest.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 30/11/2025.
//

import Testing

@Suite
struct ReplaceUTF8DiacriticsTests {
    @Test
    func asciiPassThrough() {
        #expect("HELLO world!".replacingUTF8Diacritics == "HELLO world!")
    }

    @Test
    func lowercaseExamples() {
        #expect("café".replacingUTF8Diacritics == "caf&#xE9;")
        #expect("façade".replacingUTF8Diacritics == "fa&#xE7;ade")
        #expect("crème brûlée".replacingUTF8Diacritics == "cr&#xE8;me br&#xFB;l&#xE9;e")
    }

    @Test
    func mixedcaseExamples() {
        #expect("François".replacingUTF8Diacritics == "Fran&#xE7;ois")
        #expect("Mariëtte".replacingUTF8Diacritics == "Mari&#xEB;tte")
    }

    @Test
    func uppercaseExamples() {
        #expect("ÇAĞDAŞ".replacingUTF8Diacritics == "&#xC7;A&#x11E;DA&#x15E;") // Turkish
        #expect("ŒUVRE".replacingUTF8Diacritics == "&#x152;UVRE") // French
    }

    @Test
    func decomposedSequence() {
        let decomposed = "e\u{0301}" // e + combining acute
        #expect(decomposed.replacingUTF8Diacritics == "&#xE9;")
    }

    @Test
    func turkishI() {
        #expect("İstanbul".replacingUTF8Diacritics.hasPrefix("&#x130;"))
        #expect("Iğdır".replacingUTF8Diacritics.contains("&#x11F;")) // ğ
        #expect("Kırıkkale".replacingUTF8Diacritics.contains("&#x131;")) // nasty dotless ı
    }
}
