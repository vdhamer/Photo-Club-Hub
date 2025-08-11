//
//  ExpertiseTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 21/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Expertise class") struct ExpertiseTests {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    @Test("Add a standard expertise") func addStandardExpertise() throws {
        let expertiseID = String.random(length: 10).capitalized
        let expertise = Expertise.findCreateUpdateStandard(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID)
        #expect(expertise.isStandard == true)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Add a non-standard expertise") func addNonStandardExpertise() throws {
        let expertiseID = String.random(length: 10).capitalized
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID)
        #expect(expertise.isStandard == false)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Check capitalization of incoming ID strings") func checkIdCaplitalization() throws {
        let expertiseID = "a " + String.random(length: 8).capitalized
        let expertise = Expertise.findCreateUpdateStandard(context: context, id: expertiseID.capitalized,
                                                           names: [], usages: [])
        #expect(expertise.id == expertiseID.capitalized)
    }

    @Test("Avoid creating same expertise twice") func avoidDuplicateExpertises() {
        let id = String.random(length: 10).capitalized
        let expertise1 = Expertise.findCreateUpdateStandard(context: context, id: id, names: [], usages: [])
        #expect(expertise1.isStandard == true)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"")
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record

        let expertise2 = Expertise.findCreateUpdateNonStandard(context: context, id: id, names: [], usages: [])
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
        #expect(expertise2.isStandard == false)

        #expect(expertise1.isStandard == false) // should not create a new record
    }

}
