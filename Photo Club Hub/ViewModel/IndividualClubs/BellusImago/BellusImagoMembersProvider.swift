//
//  BellusImagoMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController

class BellusImagoMembersProvider {

    init(bgContext: NSManagedObjectContext) {
        insertOnlineMemberData(bgContext: bgContext)
    }

}
