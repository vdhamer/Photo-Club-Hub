//
//  TestMembersProvider.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 02/04/2022.
//

class TestClubMembersProvider {

    init() {

        // used by TestMembersProvider only
        let testBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(testBackgroundContext: testBackgroundContext)
    }

}
