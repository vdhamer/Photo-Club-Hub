//
//  LocalizedExpertiseResultLists.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/06/2025.
//

import CoreData // for NSManagedObjectContext

let maxKeywordsPerMember: Int = 2

// Used to provide the UI with pairs of lists with Exertise records with localized names
public struct LocalizedExpertiseResultLists {

    public var standard = LocalizedExpertiseResultList(isStandard: true, list: [])
    public var nonstandard = LocalizedExpertiseResultList(isStandard: false, list: [])

    public init(standardList: [LocalizedKeywordResult], nonstandardList: [LocalizedKeywordResult]) {
        standard = LocalizedExpertiseResultList(isStandard: true, list: standardList)
        nonstandard = LocalizedExpertiseResultList(isStandard: false, list: nonstandardList)
    }

    public init(moc: NSManagedObjectContext, _ photographerKeywords: Set<PhotographerKeyword>) {

        // Use init(standardList:nonstandardList) to get access to the icons
        var resultLERLs = LocalizedExpertiseResultLists.init(standardList: [], nonstandardList: [])

        // Step 1. Translate keywords to appropriate language
        var translated: [LocalizedKeywordResult] = [] // start with empty array
        for photographerKeyword in photographerKeywords {
            translated.append(photographerKeyword.keyword.selectedLocalizedKeyword) // choose most suitable language
        }

        // Step 2. Sort based on selected language.  Has special behavior for keywords without translation
        let sorted: [LocalizedKeywordResult] = translated.sorted() // note dedicated LocalizedKeywordResult.<() function

        // Step 3. Clip size to maxKeywordsPerMember keywords
        var clipped: [LocalizedKeywordResult] = [] // start with empty array
        if sorted.count > 0 {
            for index in 0...min(maxKeywordsPerMember-1, sorted.count-1) {
                clipped.append(sorted[index]) // copy the first few sorted LocalizedKeywordResult elements
            }
        }

        // Step 4. Split list of photographer's expertises into 2 parts: standard and nonStandard
//        var localStandard: [LocalizedKeywordResult] = [] // start with two empty arrays
//        var localNonStandard: [LocalizedKeywordResult] = []
        for item in clipped {
            if item.isStandard {
                resultLERLs.standard.list.append(item)
            } else {
                resultLERLs.nonstandard.list.append(LocalizedKeywordResult(localizedKeyword: item.localizedKeyword,
                                                                           id: item.id))
            }
        }

        // Step 5. remove delimeter after last element
        if sorted.count > maxKeywordsPerMember { // if list overflows, add a warning
            let moreKeyword = Keyword.findCreateUpdateNonStandard(
                                        context: moc,
                                        id: String(localized: "Too many expertises",
                                                   table: "Localizable",
                                                   comment: "Shown when too many expertises are found"),
                                        name: [],
                                        usage: [] )
            let moreLocalizedKeyword: LocalizedKeywordResult = moreKeyword.selectedLocalizedKeyword
            resultLERLs.nonstandard.list.append(LocalizedKeywordResult(
                                                    localizedKeyword: moreLocalizedKeyword.localizedKeyword,
                                                    id: moreKeyword.id,
                                                    customHint: customHint(localizedKeywordResults: sorted))
                                                )
        }

        // Step 6. remove delimeter after last element
        if !resultLERLs.standard.list.isEmpty {
            resultLERLs.standard.list[resultLERLs.standard.list.count-1].delimiterToAppend = "" // was ","
        }
        if !resultLERLs.nonstandard.list.isEmpty {
            resultLERLs.nonstandard.list[resultLERLs.nonstandard.list.count-1].delimiterToAppend = ""
        }

        self.standard.list = resultLERLs.standard.list
        self.nonstandard.list = resultLERLs.nonstandard.list
    }

    fileprivate func customHint(localizedKeywordResults: [LocalizedKeywordResult]) -> String {
        var hint: String = ""
        let temp = LocalizedExpertiseResultLists(standardList: [], nonstandardList: [])

        for localizedKeywordResult in localizedKeywordResults {
            if localizedKeywordResult.localizedKeyword != nil {
                hint.append(temp.standard.icon + " " + localizedKeywordResult.localizedKeyword!.name + " ")
            } else {
                hint.append(temp.nonstandard.icon + " " + localizedKeywordResult.id + " ")
            }
        }

        return hint.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }

    fileprivate func getIconString(standard: Bool) -> String {
        let temp = LocalizedExpertiseResultLists(standardList: [], nonstandardList: [])
        return standard ? temp.standard.icon : temp.nonstandard.icon
    }
}

public struct LocalizedExpertiseResultList {

    public init(isStandard: Bool, list: [LocalizedKeywordResult]) {
        self.icon = isStandard ? "🏵️" : "🪲"
        self.list = list
    }

    public let icon: String // cannot be modified, icon is a single Unicode character
    public var list: [LocalizedKeywordResult]

}
