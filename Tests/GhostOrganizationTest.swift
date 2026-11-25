//
//  GhostOrganizationTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 24/11/2026.
//

import Testing
import CoreData // for NSManagedObjectContext
import Photo_Club_Hub_Data // for PersistenceController, Organization, OrganizationStatus, Language
@testable import Photo_Club_Hub

// With "Show inactive organizations" on, an inactive or possibly inactive organization is shown as a "ghost":
// a ghost marker on the maps, and a line saying so on its Maps card and its Clubs tab section header (#892).
@Suite("Inactive organizations are shown as ghosts")
@MainActor
struct GhostOrganizationTests {

    private let context = PersistenceController(inMemory: true).container.viewContext

    @Test("Only inactive and possibly inactive organizations are ghosts",
          arguments: OrganizationStatus.allCases)
    func ghostStatuses(status: OrganizationStatus) {
        #expect(status.isGhost == [.inactive, .possiblyInactive].contains(status))
    }

    // The ghost marker and the line below the town are decided separately: by `isGhost` and by the Data package's
    // `displayNameForAppUI`. They must agree, or a card could get a ghost without saying why, or the other way round.
    @Test("A ghost, and only a ghost, gets a line saying it may have stopped", arguments: OrganizationStatus.allCases)
    func ghostsHaveALabel(status: OrganizationStatus) {
        #expect(status.isGhost == (status.displayNameForAppUI != nil))
    }

    @Test("The Clubs tab section title carries the club's status", arguments: OrganizationStatus.allCases)
    func sectionTitleCarriesStatus(status: OrganizationStatus) throws {
        Language.initConstants(context: context) // creates the Language rows, including "en"
        let uiLanguage = try #require(Language.find(context: context, isoCode: "en"))
        let club = Organization.findCreateUpdate(
            context: context,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: "Fotogroep de Gender", town: "Eindhoven", nickname: "Test")
        )
        club.status_ = status.rawValue // the public init of OrganizationOptionalFields has no status

        let title = FilteredMemberPortfoliosView.sectionTitle(for: club, uiLanguage: uiLanguage)
        #expect(title.status == status)
    }

}
