//
//  TestClubAmsterdamMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/01/2023.
//

class TestClubAmsterdamMembersProvider {

    init() {

        // used by TestClubAMembersProvider only
        let testAmsterdamBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test Adam doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(testAmsterdamBackgroundContext: testAmsterdamBackgroundContext)
    }

}
