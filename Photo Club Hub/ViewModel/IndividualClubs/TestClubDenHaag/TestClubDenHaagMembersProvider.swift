//
//  TestClubDenHaagMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext

class TestClubDenHaagMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photo club Test Den Haag doesn't support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(bgContext: bgContext)
    }

}
