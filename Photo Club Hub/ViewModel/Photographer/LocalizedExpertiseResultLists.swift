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

    public init(standardList: [LocalizedExpertiseResult], nonstandardList: [LocalizedExpertiseResult]) {
        standard = LocalizedExpertiseResultList(isStandard: true, list: standardList)
        nonstandard = LocalizedExpertiseResultList(isStandard: false, list: nonstandardList)
    }

    public init(moc: NSManagedObjectContext, _ photographerKeywords: Set<PhotographerExpertise>) {

        // Use init(standardList:nonstandardList) to get access to the icons
        var resultLERLs = LocalizedExpertiseResultLists.init(standardList: [], nonstandardList: [])

        // Step 1. Translate keywords to appropriate language
        var translated: [LocalizedExpertiseResult] = [] // start with empty array
        for photographerKeyword in photographerKeywords {
            translated.append(photographerKeyword.expertise.selectedLocalizedExpertise) // choose most suitable language
        }

        // Step 2. Sort based on selected language.  Has special behavior for keywords without translation
        let sorted: [LocalizedExpertiseResult] = translated.sorted() // note dedicated LocalizedKeywordResult.<() func

        // Step 3. Clip size to maxKeywordsPerMember keywords
        var clipped: [LocalizedExpertiseResult] = [] // start with empty array
        if sorted.count > 0 {
            for index in 0...min(maxKeywordsPerMember-1, sorted.count-1) {
                clipped.append(sorted[index]) // copy the first few sorted LocalizedKeywordResult elements
            }
        }

        // Step 4. Split list of photographer's expertises into 2 parts: standard and nonStandard
        for item in clipped {
            if item.isStandard {
                resultLERLs.standard.list.append(item)
            } else {
                resultLERLs.nonstandard.list.append(LocalizedExpertiseResult(localizedKeyword: item.localizedKeyword,
                                                                           id: item.id))
            }
        }

        // Step 5. remove delimeter after last element
        if sorted.count > maxKeywordsPerMember { // if list overflows, add a warning
            let moreKeyword = Expertise.findCreateUpdateNonStandard(
                                        context: moc,
                                        id: String(localized: "Too many expertises",
                                                   table: "Package",
                                                   comment: "Shown when too many expertises are found"),
                                        name: [],
                                        usage: [] )
            let moreLocalizedKeyword: LocalizedExpertiseResult = moreKeyword.selectedLocalizedExpertise
            resultLERLs.nonstandard.list.append(LocalizedExpertiseResult(
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

    fileprivate func customHint(localizedKeywordResults: [LocalizedExpertiseResult]) -> String {
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

    public func getIconString(standard: Bool) -> String {
        let temp = LocalizedExpertiseResultLists(standardList: [], nonstandardList: [])
        return standard ? temp.standard.icon : temp.nonstandard.icon
    }
}
