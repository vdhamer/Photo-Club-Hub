//
//  AndersMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/10/2023.
//

import CoreData // for NSManagedObjectContext

class AndersMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photogroup Anders doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(bgContext: bgContext)
    }

}
