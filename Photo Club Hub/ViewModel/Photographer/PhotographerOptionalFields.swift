//
//  PhotographerOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/07/2024.
//

import Foundation // for URL

struct PhotographerOptionalFields {
    var bornDT: Date?
    var isDeceased: Bool? // nil means "don't know"
    var photographerWebsite: URL?
    var photographerImage: URL?
}
