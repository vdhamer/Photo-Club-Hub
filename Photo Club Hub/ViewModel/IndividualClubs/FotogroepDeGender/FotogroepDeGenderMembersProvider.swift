//
//  FotogroepDeGenderMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import CoreData // for PersistenceController

class FotogroepDeGenderMembersProvider {

    init(bgContext: NSManagedObjectContext) {
        insertOnlineMemberData(bgContext: bgContext) // should do its own bgContext.save()
    }

}
