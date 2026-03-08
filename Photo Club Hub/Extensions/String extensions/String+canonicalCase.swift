//
//  String+canonicalCase.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/08/2025.
//

extension String {
    /// Returns a copy of the string with all characters lowercased, but with only the first character in uppercase.
    /// Useful for standardizing strings (entered by users) for use as identifiers..
    /// Example: "black & White PHOTOgraphy" becomes "Black & white photography".
    var canonicalCase: String {
        self.lowercased().capitalizingFirstLetter()
    }
}
