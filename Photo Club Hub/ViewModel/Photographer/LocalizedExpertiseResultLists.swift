//
//  LocalizedKeywordResultLists.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/06/2025.
//

// Used to provide UI with pairs of lists with Exertise records with localized names
struct LocalizedExpertiseResultLists {

    init(standardList: [LocalizedKeywordResult], nonstandardList: [LocalizedKeywordResult]) {
        standard = LocalizedExpertiseResultList(icon: "🏵️", list: standardList)
        nonstandard = LocalizedExpertiseResultList(icon: "🪲", list: nonstandardList)
    }

    var standard: LocalizedExpertiseResultList
    var nonstandard: LocalizedExpertiseResultList

}

struct LocalizedExpertiseResultList {

    let icon: String // cannot be modified
    var list: [LocalizedKeywordResult]

}
