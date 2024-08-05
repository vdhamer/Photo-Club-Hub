//
//  AndersMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/10/2023.
//

import CoreData // for NSManagedObjectContext

class AndersMembersProvider {

    init(bgContext: NSManagedObjectContext) {
        insertOnlineMemberData(bgContext: bgContext) // should do its own bgContext.save()
    }

}
