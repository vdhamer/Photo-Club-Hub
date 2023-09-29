//
//  FotogroepDeGenderMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import Foundation

import CoreData // for PersistenceController

class FotogroepDeGenderMembersProvider {

    init(bgContext: NSManagedObjectContext) {

        // Photo club Bellus Imago doesn't currently support loading member data from an online site.
        // So we only insert a member or two from info hardcoded in insertSomeHardcodedMemberData()
        insertSomeHardcodedMemberData(bgContext: bgContext)
    }

}
