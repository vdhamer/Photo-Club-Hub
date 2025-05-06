//
//  LocalizedKeywordResult.swift
//  Photo Club Hub HTML (struct currently only used by Photo Club Hub HTML)
//
//  Created by Peter van den Hamer on 26/04/2025.
//

import Foundation

struct LocalizedKeywordResult {
    let localizedKeyword: LocalizedKeyword? // a given keyword doesn't have a translation if it isn't defined at Level 0
    let id: String // fallback if localizedKeyword is nil
    var delimiterToAppend: String = "," // can be set to ""
    var customHint: String? // overrules standard Ignite hint
}

extension LocalizedKeywordResult: Comparable {

    static func < (lhs: LocalizedKeywordResult, rhs: LocalizedKeywordResult) -> Bool {
        guard lhs.localizedKeyword != nil else { return false } // put untranslateable at end of list
        guard rhs.localizedKeyword != nil else { return true } // put untranslateable at end of list
        return lhs.localizedKeyword!.name < rhs.localizedKeyword!.name // normal sorting
    }

}
