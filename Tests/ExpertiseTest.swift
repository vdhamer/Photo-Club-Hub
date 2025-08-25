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
        let expertiseID = String.random(length: 10).canonicalCase
        let expertise = Expertise.findCreateUpdateStandard(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID.canonicalCase)
        #expect(expertise.isStandard == true)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Add a non-standard expertise") func addNonStandardExpertise() throws {
        let expertiseID = String.random(length: 10).canonicalCase
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID)
        #expect(expertise.isStandard == false)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Check capitalization of incoming ID strings") func checkIdCaplitalization() throws {
        let expertiseID = "a " + String.random(length: 8)
        let expertise = Expertise.findCreateUpdateStandard(context: context, id: expertiseID.canonicalCase,
                                                           names: [], usages: [])
        #expect(expertise.id == expertiseID.canonicalCase)
    }

    @Test("Standard expertise cannot be changed back to non-standard") func expertiseStandard2NonStandard() {
        var id = String.random(length: 10) // findCreateUpdate() converts this to .canonicalCase
        let expertise1 = Expertise.findCreateUpdateStandard(context: context, id: id, names: [], usages: [])
        #expect(expertise1.isStandard == true)
        #expect(id.canonicalCase == expertise1.id)
        id = id.canonicalCase
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"")
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)

        let expertise2 = Expertise.findCreateUpdateNonStandard(context: context, id: id, names: [], usages: [])
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(expertise2.isStandard == true) // standard never reverts back to non-standard (latching)
        #expect(expertise1.isStandard == expertise2.isStandard) // should be same, as this is a class
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
    }

    @Test("Non-standard expertise can be promoted to standard") func expertiseNonStandard2Standard() {
        var id = String.random(length: 10) // findCreateUpdate() converts this to .canonicalCase
        let expertise1 = Expertise.findCreateUpdateNonStandard(context: context, id: id, names: [], usages: [])
        #expect(expertise1.isStandard == false)
        #expect(id.canonicalCase == expertise1.id)
        id = id.canonicalCase
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"")
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)

        let expertise2 = Expertise.findCreateUpdateStandard(context: context, id: id, names: [], usages: [])
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(expertise2.isStandard == true) // should have promoted to standard
        #expect(expertise1.isStandard == expertise2.isStandard) // should be same, as this is a class
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
    }

}
