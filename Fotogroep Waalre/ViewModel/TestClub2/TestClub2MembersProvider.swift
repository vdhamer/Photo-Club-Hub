//
//  TestClub2MembersProvider.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/01/2023.
//

class TestClub2MembersProvider {

    init() {

        // used by TestMembersProvider only
        let test2BackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Photo club Test doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(test2BackgroundContext: test2BackgroundContext)
    }

}
