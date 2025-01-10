//
//  ExampleMaxMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController

class ExampleMaxMembersProvider {

    init(bgContext: NSManagedObjectContext) {
        insertOnlineMemberData(bgContext: bgContext)
    }

}
