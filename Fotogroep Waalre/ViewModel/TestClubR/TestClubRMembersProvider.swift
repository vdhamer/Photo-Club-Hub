//
//  TestClubRMembersProvider.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 02/04/2022.
//

class TestClubRMembersProvider {

    init() {

        // used by TestClubRMembersProvider only
        let testRBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(testRBackgroundContext: testRBackgroundContext)
    }

}
