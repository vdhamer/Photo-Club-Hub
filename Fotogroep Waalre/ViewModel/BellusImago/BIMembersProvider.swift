//
//  BIMembersProvider.swift
//  BIMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController

class BIMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photo club Bellus Imago doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(bgContext: bgContext)
    }

}
