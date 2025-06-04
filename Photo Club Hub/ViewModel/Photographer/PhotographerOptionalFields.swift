//
//  PhotographerOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/07/2024.
//

import Foundation // for URL
import SwiftyJSON // for JSON struct

public struct PhotographerOptionalFields {
    var bornDT: Date?
    var isDeceased: Bool? // nil means "don't know"
    var photographerWebsite: URL?
    var photographerImage: URL?
    var photographerKeywords: [JSON] // defaults to empty list

    public init(bornDT: Date? = nil,
                isDeceased: Bool? = nil,
                photographerWebsite: URL? = nil,
                photographerImage: URL? = nil,
                photographerKeywords: [JSON] = []) {
        self.bornDT = bornDT
        self.isDeceased = isDeceased
        self.photographerWebsite = photographerWebsite
        self.photographerImage = photographerImage
        self.photographerKeywords = photographerKeywords
    }
}
