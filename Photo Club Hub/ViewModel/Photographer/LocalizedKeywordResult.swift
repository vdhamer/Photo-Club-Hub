//
//  LocalizedKeywordResult.swift
//  Photo Club Hub HTML (struct currently only used by Photo Club Hub HTML)
//
//  Created by Peter van den Hamer on 26/04/2025.
//

import Foundation

public struct LocalizedKeywordResult {
    public let localizedKeyword: LocalizedKeyword? // keyword may not have a translation if it isn't defined at Level 0
    public let id: String // fallback if localizedKeyword is nil
    public var delimiterToAppend: String // normally "," but can be set to ""
    public var customHint: String? // used to overrule standard Ignite hint

    var name: String { localizedKeyword?.name ?? id } // localized name or (if no translations) generic id

    public init(localizedKeyword: LocalizedKeyword?,
                id: String,
                delimiterToAppend: String = ",",
                customHint: String? = nil) { // is the "= nil" still needed in Swift?
        self.localizedKeyword = localizedKeyword
        self.id = id
        self.delimiterToAppend = delimiterToAppend
        self.customHint = customHint
    }
}

extension LocalizedKeywordResult: Comparable {

    public static func < (lhs: LocalizedKeywordResult, rhs: LocalizedKeywordResult) -> Bool {
        guard lhs.localizedKeyword != nil else { return false } // put untranslateable at end of list
        guard rhs.localizedKeyword != nil else { return true } // put untranslateable at end of list
        return lhs.localizedKeyword!.name < rhs.localizedKeyword!.name // normal sorting
    }

}
