//
//  FoundationExtensions.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2021.
//

import Foundation

extension String {

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

}
