//
//  TestClubDenHaagMembersProvider.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/01/2023.
//

class TestClubDenHaagMembersProvider {

    init() {

        // used by TestClubAMembersProvider only
        let testDenHaagBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test Adam doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(testDenHaagBackgroundContext: testDenHaagBackgroundContext)
    }

}
