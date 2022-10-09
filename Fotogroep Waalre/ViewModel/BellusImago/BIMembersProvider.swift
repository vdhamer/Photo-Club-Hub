//
//  BIMembersProvider.swift
//  BIMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController

class BIMembersProvider {

    init() {

        // used by BIMembersProvider only
        let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()

        // Bellus Imago doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(biBackgroundContext: biBackgroundContext)
    }

}
