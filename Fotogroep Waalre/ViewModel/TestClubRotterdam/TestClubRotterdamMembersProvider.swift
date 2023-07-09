//
//  TestClubRotterdamMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 02/04/2022.
//

import CoreData // for NSManagedObjectContext

class TestClubRotterdamMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photo club Test doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(bgContext: bgContext)
    }

}
