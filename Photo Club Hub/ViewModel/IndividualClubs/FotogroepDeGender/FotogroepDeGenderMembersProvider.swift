//
//  FotogroepDeGenderMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import CoreData // for PersistenceController

class FotogroepDeGenderMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photo club de Gender doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
//        insertSomeHardcodedMemberData(bgContext: bgContext) // does its own bgContext.save()
        insertOnlineMemberData(bgContext: bgContext) // should do its own bgContext.save()
    }

}
