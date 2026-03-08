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

    private let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    @Test("Add a supported expertise") func addSupportedExpertise() throws {
        let expertiseID = String.random(length: 10).canonicalCase
        let expertise = Expertise.findCreateUpdateSupported(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID.canonicalCase)
        #expect(expertise.isSupported == true)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Add a temporary expertise") func addTemporaryExpertise() throws {
        let expertiseID = String.random(length: 10).canonicalCase
        let expertise = Expertise.findCreateUpdateTemporary(context: context, id: expertiseID, names: [], usages: [])
        #expect(expertise.id == expertiseID)
        #expect(expertise.isSupported == false)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(expertiseID)\"")
        #expect(Expertise.count(context: context, expertiseID: expertiseID) == 1)
    }

    @Test("Check capitalization of incoming ID strings") func checkIdCaplitalization() throws {
        let expertiseID = "a " + String.random(length: 8)
        let expertise = Expertise.findCreateUpdateSupported(context: context, id: expertiseID.canonicalCase,
                                                           names: [], usages: [])
        #expect(expertise.id == expertiseID.canonicalCase)
    }

    @Test("Supported expertise cannot be changed back to Temporary") func expertiseSupported2Temporary() {
        var id = String.random(length: 10) // findCreateUpdate() converts this to .canonicalCase
        let expertise1 = Expertise.findCreateUpdateSupported(context: context, id: id, names: [], usages: [])
        #expect(expertise1.isSupported == true)
        #expect(id.canonicalCase == expertise1.id)
        id = id.canonicalCase
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"")
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)

        let expertise2 = Expertise.findCreateUpdateTemporary(context: context, id: id, names: [], usages: [])
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(expertise2.isSupported == true) // supported never reverts back to temporary (latching)
        #expect(expertise1.isSupported == expertise2.isSupported) // should be same, as this is a class
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
    }

    @Test("Temporary expertise can be promoted to Supported") func expertiseTemporary2Supported() {
        var id = String.random(length: 10) // findCreateUpdate() converts this to .canonicalCase
        let expertise1 = Expertise.findCreateUpdateTemporary(context: context, id: id, names: [], usages: [])
        #expect(expertise1.isSupported == false)
        #expect(id.canonicalCase == expertise1.id)
        id = id.canonicalCase
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"")
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(Expertise.count(context: context, expertiseID: id.canonicalCase) == 1)

        let expertise2 = Expertise.findCreateUpdateSupported(context: context, id: id, names: [], usages: [])
        Expertise.save(context: context, errorText: "Error saving expertise \"\(id)\"") // shouldn't create a new record
        #expect(expertise2.isSupported == true) // should have promoted to Supported
        #expect(expertise1.isSupported == expertise2.isSupported) // should be same, as this is a class
        #expect(Expertise.count(context: context, expertiseID: id) == 1)
    }

}
