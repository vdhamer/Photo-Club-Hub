//
//  OrganizationStatusPredicateTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 23/11/2026.
//

import Testing
import CoreData // for NSFetchRequest
import Photo_Club_Hub_Data // for PersistenceController, Organization, OrganizationStatus, etc.
@testable import Photo_Club_Hub

// Organizations that stopped, or may have stopped, are hidden unless "showInactiveOrganizations" is on (#891, #892).
// Rejected organizations are never shown. The Maps tab (organizationPredicate) and the Clubs tab (memberPredicate)
// must agree, so each test checks both.
@Suite("Settings hide inactive and rejected organizations")
@MainActor
struct OrganizationStatusPredicateTests {

    private let context = PersistenceController(inMemory: true).container.viewContext

    /// Creates one club per `OrganizationStatus`, with that status as its name,
    /// and gives each club one current member, with that status as the member's family name.
    private func createClubs() throws {
        for status in OrganizationStatus.allCases {
            let organization = Organization.findCreateUpdate(
                context: context,
                organizationTypeEnum: OrganizationTypeEnum.club,
                idPlus: OrganizationIdPlus(fullName: status.rawValue, // e.g. "active" or "possiblyInactive"
                                           town: "Testtown",
                                           nickname: status.rawValue) // e.g. "active" or "possiblyInactive"
            )
            organization.status_ = status.rawValue // the public init of OrganizationOptionalFields has no status
            let photographer = Photographer.findCreateUpdate(
                context: context,
                personName: PersonName(givenName: "Jan", infixName: "", familyName: status.rawValue)
            )
            _ = MemberPortfolio.findCreateUpdate(
                bgContext: context,
                organization: organization,
                photographer: photographer // different photographer for every clubs in the for-loop
            )
        }
        try context.save()
    }

    /// The default settings, with every setting these tests depend on set explicitly,
    /// so that a change to `SettingsStruct.defaultValue` can't change what they test.
    /// `allTypesShortcut` turns museums on as well as clubs, so that `organizationPredicate` takes its shortcut for
    /// "all types". Off, it builds a "clubs only" clause instead. The test data holds only clubs, so both give the same
    /// result, and the status clause gets tested on both paths.
    private func settings(showInactive: Bool, allTypesShortcut: Bool) -> SettingsStruct {
        var settings = SettingsStruct.defaultValue
        settings.showClubs = true // the test data holds only clubs
        settings.showCurrentMembers = true // the test data holds only current members
        settings.showInactiveOrganizations = showInactive
        settings.showMuseums = allTypesShortcut
        return settings
    }

    /// Names of the clubs on the Maps tab, and family names of the members on the Clubs tab.
    /// Both are status names, so the two sets can be compared directly.
    private func shown(_ settings: SettingsStruct) throws -> (clubs: Set<String>, members: Set<String>) {
        let organizationRequest = NSFetchRequest<Organization>(entityName: "Organization")
        organizationRequest.predicate = settings.organizationPredicate // fancily computed property

        let memberRequest = NSFetchRequest<MemberPortfolio>(entityName: "MemberPortfolio")
        memberRequest.predicate = settings.memberPredicate  // fancily computed property

        return (clubs: Set(try context.fetch(organizationRequest).map { $0.fullName }),
                members: Set(try context.fetch(memberRequest).map { $0.photographer.familyName }))
    }

    @Test("By default only active clubs and their members are shown", arguments: [true, false])
    func activeOnly(allTypesShortcut: Bool) throws {
        try createClubs()
        let shown = try shown(settings(showInactive: false, allTypesShortcut: allTypesShortcut))
        #expect(shown.clubs == ["active"])
        #expect(shown.members == ["active"])
    }

    @Test("The setting adds inactive and possibly inactive clubs, but never rejected ones", arguments: [true, false])
    func inactiveToo(allTypesShortcut: Bool) throws {
        try createClubs()
        let shown = try shown(settings(showInactive: true, allTypesShortcut: allTypesShortcut))
        #expect(shown.clubs == ["active", "inactive", "possiblyInactive"]) // order insensitive because these are Sets
        #expect(shown.members == ["active", "inactive", "possiblyInactive"])
    }

    // With clubs and museums off the maps show nothing, and `couldShowOrganizations` tells the Maps tab to explain why.
    // The Clubs tab ignores these two toggles, so its members stay.
    @Test("Clubs and museums off: no organizations, members still shown", arguments: [true, false])
    func organizationTypesOff(showInactive: Bool) {
        var settings = settings(showInactive: showInactive, allTypesShortcut: false) // current members on
        settings.showClubs = false
        settings.showMuseums = false
        #expect(settings.organizationPredicate == NSPredicate(format: "FALSEPREDICATE"))
        #expect(settings.couldShowOrganizations == false)
        #expect(settings.memberPredicate != NSPredicate(format: "FALSEPREDICATE"))
        #expect(settings.couldShowMembers == true)
    }

    // With every member category off the Clubs tab shows nothing, and `couldShowMembers` tells it to explain why.
    // The Maps tab doesn't depend on member categories, so its clubs stay.
    @Test("All member categories off: no members, organizations still shown", arguments: [true, false])
    func memberCategoriesOff(showInactive: Bool) {
        var settings = settings(showInactive: showInactive, allTypesShortcut: false) // clubs on
        settings.showCurrentMembers = false
        settings.showOfficers = false // set after showCurrentMembers, whose didSet also sets it
        settings.showAspiringMembers = false
        settings.showHonoraryMembers = false
        settings.showFormerMembers = false
        settings.showDeceasedMembers = false // set after showFormerMembers, whose didSet also sets it
        settings.showExternalCoaches = false
        #expect(settings.memberPredicate == NSPredicate(format: "FALSEPREDICATE"))
        #expect(settings.couldShowMembers == false)
        #expect(settings.organizationPredicate != NSPredicate(format: "FALSEPREDICATE"))
        #expect(settings.couldShowOrganizations == true)
    }

}
