//
//  String+replaceUTF8Diacritics.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 26/11/2025.
//

import Foundation

// Converts strings containing symbols with diacritic marks like "é"
// to an HTML version of Unicode UTF-8 symbols like "&#xE9;}" that doesn't require UTF-8 support by web server.
// If the Unicode string is not listed below, it is kept as is: increasingly web servers support UTF-8
// so this list just contains common cases covered by the shortcuts provided for Mac/iPadOS keyboard entry.

extension String {

    public var replacingUTF8Diacritics: String {

        // fast return of unmodified strings if they are ASCII only. This should return in almost all cases.
        if self.unicodeScalars.allSatisfy({ $0.isASCII }) { return self }

        // Normalize to precomposed form so combining sequences match our mapping
        let input: String = self.precomposedStringWithCanonicalMapping // unlikely to make a change on Mac made strings

        var result = String.UnicodeScalarView() // still empty
        result.reserveCapacity(input.unicodeScalars.count)

        for scalar in input.unicodeScalars {
            if let replacement = Self.htmlHexEntityMap[scalar] {
                // Append the ASCII text of the entity
                result.append(contentsOf: replacement.unicodeScalars)
            } else {
                result.append(scalar)
            }
        }

        return String(result)
    }

    // The lowercase characters were manually entered by the author using an online source.
    // The uppercase characters were generated (and "checked") using GPT-5.
    fileprivate static let htmlHexEntityMap: [UnicodeScalar: String] = [
        // A - character family that can be typed on Apple systems by long-pressing this key
        "À": "&#xC0;",
        "Á": "&#xC1;",
        "Â": "&#xC2;",
        "Ã": "&#xC3;",
        "Ä": "&#xC4;",
        "Å": "&#xC5;",
        "Æ": "&#xC6;",
        "Ā": "&#x100;",
        "Ǎ": "&#x1CD;",

        // a - character family that can be typed on Apple systems by long-pressing this key
        "à": "&#xE0;",
        "á": "&#xE1;",
        "â": "&#xE2;",
        "ã": "&#xE3;",
        "ä": "&#xE4;",
        "å": "&#xE5;",
        "æ": "&#xE6;",
        "ā": "&#x101;",
        "ǎ": "&#x1CE;",

        // C - character family that can be typed on Apple systems by long-pressing this key
        "Ç": "&#xC7;",
        "Ć": "&#x106;",
        "Ċ": "&#x10A;",
        "Č": "&#x10C;",

        // c - character family that can be typed on Apple systems by long-pressing this key
        "ç": "&#xE7;",
        "ć": "&#x107;",
        "ċ": "&#x10B;",
        "č": "&#x10D;",

        // D - character family that can be typed on Apple systems by long-pressing this key
        "Ď": "&#x10E;",
        "Ð": "&#xD0;",

        // d - character family that can be typed on Apple systems by long-pressing this key
        "ď": "&#x10F;",
        "ð": "&#xF0;",

        // E - character family that can be typed on Apple systems by long-pressing this key
        "È": "&#xC8;",
        "É": "&#xC9;",
        "Ê": "&#xCA;",
        "Ë": "&#xCB;",
        "Ě": "&#x11A;",
        "Ē": "&#x112;",
        "Ė": "&#x116;",
        "Ę": "&#x118;",
        "Ẽ": "&#x1EBC;",

        // e - character family that can be typed on Apple systems by long-pressing this key
        "è": "&#xE8;",
        "é": "&#xE9;",
        "ê": "&#xEA;",
        "ë": "&#xEB;",
        "ě": "&#x11B;",
        "ē": "&#x113;",
        "ė": "&#x117;",
        "ę": "&#x119;",
        "ẽ": "&#x1EBD;",

        // G - character family that can be typed on Apple systems by long-pressing this key
        "Ğ": "&#x11E;",
        "Ġ": "&#x120;",

        // g - character family that can be typed on Apple systems by long-pressing this key
        "ğ": "&#x11F;",
        "ġ": "&#x121;",

        // H - character family that can be typed on Apple systems by long-pressing this key
        "Ħ": "&#x126;",

        // h - character family that can be typed on Apple systems by long-pressing this key
        "ħ": "&#x127;",

        // I - character family that can be typed on Apple systems by long-pressing this key
        "Ì": "&#xCC;",
        "Í": "&#xCD;",
        "Î": "&#xCE;",
        "Ï": "&#xCF;",
        "Ǐ": "&#x1CF;",
        "Ĩ": "&#x128;",
        "Ī": "&#x12A;",
        "Į": "&#x12E;",
        "İ": "&#x130;",

        // i - character family that can be typed on Apple systems by long-pressing this key
        "ì": "&#xEC;",
        "í": "&#xED;",
        "î": "&#xEE;",
        "ï": "&#xEF;",
        "ǐ": "&#x1D0;",
        "ĩ": "&#x129;",
        "ī": "&#x12B;",
        "į": "&#x12F;",
        "ı": "&#x131;",

        // K - character family that can be typed on Apple systems by long-pressing this key
        "Ķ": "&#x136;",

        // k - character family that can be typed on Apple systems by long-pressing this key
        "ķ": "&#x137;",

        // L - character family that can be typed on Apple systems by long-pressing this key
        "Ł": "&#x141;",
        "Ļ": "&#x13B;",
        "Ľ": "&#x13D;",

        // l - character family that can be typed on Apple systems by long-pressing this key
        "ł": "&#x142;",
        "ļ": "&#x13C;",
        "ľ": "&#x13E;",

        // N - character family that can be typed on Apple systems by long-pressing this key
        "Ñ": "&#xD1;",
        "Ń": "&#x143;",
        "Ņ": "&#x145;",
        "Ň": "&#x147;",

        // n - character family that can be typed on Apple systems by long-pressing this key
        "ñ": "&#xF1;",
        "ń": "&#x144;",
        "ņ": "&#x146;",
        "ň": "&#x148;",

        // O - character family that can be typed on Apple systems by long-pressing this key
        "Ò": "&#xD2;",
        "Ó": "&#xD3;",
        "Ô": "&#xD4;",
        "Õ": "&#xD5;",
        "Ö": "&#xD6;",
        "Ø": "&#xD8;",
        "Ō": "&#x14C;",
        "Œ": "&#x152;",
        "Ǒ": "&#x1D1;",

        // o - character family that can be typed on Apple systems by long-pressing this key
        "ò": "&#xF2;",
        "ó": "&#xF3;",
        "ô": "&#xF4;",
        "õ": "&#xF5;",
        "ö": "&#xF6;",
        "ø": "&#xF8;",
        "ō": "&#x14D;",
        "œ": "&#x153;",
        "ǒ": "&#x1D2;",

        // R - character family that can be typed on Apple systems by long-pressing this key
        "Ř": "&#x158;",

        // r - character family that can be typed on Apple systems by long-pressing this key
        "ř": "&#x159;",

        // S - character family that can be typed on Apple systems by long-pressing this key
        "Ś": "&#x15A;",
        "Ş": "&#x15E;",
        "Š": "&#x160;",
        "Ș": "&#x218;",

        // s - character family that can be typed on Apple systems by long-pressing this key
        "ß": "&#xDF;",
        "ś": "&#x15B;",
        "ş": "&#x15F;",
        "š": "&#x161;",
        "ș": "&#x219;",

        // T - character family that can be typed on Apple systems by long-pressing this key
        "Þ": "&#xDE;",
        "Ť": "&#x164;",
        "Ț": "&#x21A;",

        // t - character family that can be typed on Apple systems by long-pressing this key
        "þ": "&#xFE;",
        "ť": "&#x165;",
        "ț": "&#x21B;",

        // U - character family that can be typed on Apple systems by long-pressing this key
        "Ù": "&#xD9;",
        "Ú": "&#xDA;",
        "Û": "&#xDB;",
        "Ü": "&#xDC;",
        "Ũ": "&#x168;",
        "Ū": "&#x16A;",
        "Ů": "&#x16E;",
        "Ű": "&#x170;",
        "Ǔ": "&#x1D3;",

        // u - character family that can be typed on Apple systems by long-pressing this key
        "ù": "&#xF9;",
        "ú": "&#xFA;",
        "û": "&#xFB;",
        "ü": "&#xFC;",
        "ũ": "&#x169;",
        "ū": "&#x16B;",
        "ů": "&#x16F;",
        "ű": "&#x171;",
        "ǔ": "&#x1D4;",

        // W - character family that can be typed on Apple systems by long-pressing this key
        "Ŵ": "&#x174;",

        // w - character family that can be typed on Apple systems by long-pressing this key
        "ŵ": "&#x175;",

        // Y - character family that can be typed on Apple systems by long-pressing this key
        "Ý": "&#xDD;",
        "Ÿ": "&#x178;",
        "Ŷ": "&#x176;",

        // y - character family that can be typed on Apple systems by long-pressing this key
        "ý": "&#xFD;",
        "ÿ": "&#xFF;",
        "ŷ": "&#x177;"
    ]

}
