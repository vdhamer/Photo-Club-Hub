//
//  LocalizedExpertiseResult.swift
//  Photo Club Hub HTML (struct currently only used by Photo Club Hub HTML)
//
//  Created by Peter van den Hamer on 26/04/2025.
//

import Foundation

public struct LocalizedExpertiseResult {
    public let localizedExpertise: LocalizedExpertise? // Expertise only has a translation if its is listed at Level0
    public let id: String // fallback if localizedExpertise is nil
    public var delimiterToAppend: String // normally "," but can be set to ""
    public var customHint: String? // used to overrule standard Ignite hint

    public var name: String { localizedExpertise?.name ?? id } // localized name or (if no translations) generic id
    var isSupported: Bool { localizedExpertise != nil }

    public init(localizedExpertise: LocalizedExpertise?,
                id: String,
                delimiterToAppend: String = ",",
                customHint: String? = nil) { // is the "= nil" still needed in Swift?
        self.localizedExpertise = localizedExpertise
        self.id = id
        self.delimiterToAppend = delimiterToAppend
        self.customHint = customHint
    }
}

extension LocalizedExpertiseResult: Comparable {

    public static func < (lhs: LocalizedExpertiseResult, rhs: LocalizedExpertiseResult) -> Bool {

        if (lhs.localizedExpertise != nil && rhs.localizedExpertise != nil) || // both sides have a translation
            (lhs.localizedExpertise == nil && rhs.localizedExpertise == nil) { // both sides have no translation
            return lhs.name < rhs.name // normal sorting
        }
        return lhs.localizedExpertise != nil // put untranslateables after translateables

    }

}

extension LocalizedExpertiseResult: Identifiable { } // for compatibility with ForEach
