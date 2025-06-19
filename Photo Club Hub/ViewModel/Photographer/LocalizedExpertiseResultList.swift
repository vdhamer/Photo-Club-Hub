//
//  LocalizedExpertiseResultList.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/06/2025.
//

import CoreData // for NSManagedObjectContext

public struct LocalizedExpertiseResultList {

    public init(isStandard: Bool, list: [LocalizedExpertiseResult]) {
        self.icon = isStandard ? "🏵️" : "🪲"
        self.list = list
    }

    public let icon: String // cannot be modified, icon is a single Unicode character
    public var list: [LocalizedExpertiseResult]

}
