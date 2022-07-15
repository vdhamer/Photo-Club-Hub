//
//  TestMembersProvider.swift
//  TestMembersProvider
//
//  Created by Peter van den Hamer on 02/04/2022.
//

import CoreData // for PersistenceController

class TestMembersProvider {

    init() {

        // used by TestMembersProvider only
        let testBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeMembers()
        insertSomeMembers(testBackgroundContext: testBackgroundContext)
    }

}
