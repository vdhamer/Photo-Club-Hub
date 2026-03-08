//
//  OrganizationTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 13/09/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Organization class") struct OrganizationTests {

    private let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    @Test("FullnameTown for Fotogroep Waalre in Aalst") func fotogroepWaalreInAalst() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotogroep Waalre testsuffix\(randomSuffix)"
        club.town = "Aalst"
        #expect(club.fullNameTown == "\(club.fullName) (\(club.town))")
    }

    @Test("FullnameTown for Fotogroep Waalre in Waalre") func fotogroepWaalreInWaalre() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotogroep Waalre testsuffix\(randomSuffix)"
        club.town = "Waalre"
        #expect(club.fullNameTown == "\(club.fullName)")
    }

    @Test("FullnameTown for Fotogroep Waalre in waalre") func fotogroepWaalreInwaalre() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotogroep Waalre testsuffix\(randomSuffix)"
        club.town = "waalre"
        #expect(club.fullNameTown == "\(club.fullName) (\(club.town))")
    }

    @Test("FullnameTown for Fotogroep Waalre in to") func fotogroepWaalreInto() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotogroep Waalre testsuffix\(randomSuffix)"
        club.town = "to" // why does this test exist?
        #expect(club.fullNameTown == "\(club.fullName) (\(club.town))")
    }

    @Test("FullnameTown for Fotogroep Waalre in Waal") func fotogroepWaalreWaal() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotogroep Waalre testsuffix\(randomSuffix)"
        club.town = "Waal" // this is why Natural Language Processing is needed
        #expect(club.fullNameTown == "\(club.fullName) (\(club.town))")
    }

    @Test("FullnameTown for Fotoclub Den Dungen in Den Dungen") func fotoclubDenDungenDD() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotoclub Den Dungen testsuffix\(randomSuffix)"
        club.town = "Den Dungen" // this is where Natural Language Processing is thinks town is 2 words
        #expect(club.fullNameTown == "\(club.fullName)")
    }

    @Test("FullnameTown for Fotokring Sint-Michielsgestel in Den Dungen") func fotokringSintMichielsgestelSM() throws {
        let randomSuffix = String.random(length: 10).canonicalCase
        let club = Organization(context: context)
        club.fullName = "Fotokring Sint-Michielsgestel testsuffix\(randomSuffix)"
        club.town = "Sint-Michielsgestel" // this is where Natural Language Processing is thinks town is 2 words
        #expect(club.fullNameTown == "\(club.fullName)")
    }

}
