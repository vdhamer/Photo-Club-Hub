//
//  MemberPredicateTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 09/10/2026.
//

import Testing
import CoreData // for NSFetchRequest
import CoreLocation // for CLLocationCoordinate2D
import Photo_Club_Hub_Data // for PersistenceController, MemberPortfolio, etc.
@testable import Photo_Club_Hub

// Each member-related toggle in Settings adds a set of members, and the Clubs tab shows the union of those sets (#609).
// The conditions are essentially OR'd, so enabling more toggles are on, can only grow the selected set of members.
//
// Officers are regarded as current members with an extra responsibility.
// A role flag in the JSON records the role held now, or when the member left the club (left, or passed away),
// so the Officers set must exclude former and deceased members.
// Otherwise a deceased former chairman would show up with only "Show current members" on,
// because that toggle also turns on the officers toggle.
@Suite("Settings toggles select the right members")
@MainActor
struct MemberPredicateTests {

    private let context = PersistenceController(inMemory: true).container.viewContext

    /// Creates one club with these members, all given name "Jan" and identified by their family name:
    /// - Chairman: current member and chairman
    /// - Standard: current member without a role
    /// - FormerTreasurer: former member who was treasurer when leaving
    /// - DeceasedChairman: former member, deceased, who was chairman when dying (as in TemplateMax)
    /// - DeceasedViceChairman: deceased, who was vice-chairman when dying, but not marked as former.
    ///   This happens to a member of two clubs who is marked deceased in only one club's file:
    ///   deceased is stored per photographer, former per club membership (Photo-Club-Hub-Data#73).
    private func createClub() throws {
        let organization = Organization.findCreateUpdate( // create a club
            context: context,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: "Test Club", town: "Testtown", nickname: "TestClub"),
            coordinates: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), // not strictly needed
            optionalFields: OrganizationOptionalFields() // not strictly needed
        )
        struct TestMember {
            let familyName: String
            let isDeceased: Bool
            let roles: [MemberRole: Bool]
            let status: [MemberStatus: Bool]
        }
        let members = [
            TestMember(familyName: "Chairman",
                       isDeceased: false, roles: [.chairman: true], status: [:]),

            TestMember(familyName: "Standard",
                       isDeceased: false, roles: [:], status: [:]),

            TestMember(familyName: "FormerTreasurer",
                       isDeceased: false, roles: [.treasurer: true], status: [.former: true]),

            TestMember(familyName: "DeceasedChairman",
                       isDeceased: true, roles: [.chairman: true], status: [.former: true]),

            TestMember(familyName: "DeceasedViceChairman", // note: .former is false
                       isDeceased: true, roles: [.viceChairman: true], status: [:])
        ]
        for member in members {
            let photographer = Photographer.findCreateUpdate(
                context: context,
                personName: PersonName(givenName: "Jan", infixName: "", familyName: member.familyName),
                optionalFields: PhotographerOptionalFields(isDeceased: member.isDeceased)
            )
            _ = MemberPortfolio.findCreateUpdate(
                bgContext: context,
                organization: organization,
                photographer: photographer,
                optionalFields: MemberOptionalFields(
                    memberRolesAndStatus: MemberRolesAndStatus(roles: member.roles, status: member.status)
                )
            )
        }
        try context.save()
    }

    /// Settings with every member toggle off, then the requested ones on.
    /// Turning on current members also turns on officers, and former members also deceased members (as in the UI).
    private func settings(currentMembers: Bool = false,
                          officers: Bool = false,
                          formerMembers: Bool = false,
                          deceasedMembers: Bool = false) -> SettingsStruct {
        var settings = SettingsStruct.defaultValue
        settings.showCurrentMembers = currentMembers // didSet copies this into showOfficers
        settings.showOfficers = officers || currentMembers
        settings.showAspiringMembers = false
        settings.showHonoraryMembers = false
        settings.showFormerMembers = formerMembers // didSet copies this into showDeceasedMembers
        settings.showDeceasedMembers = deceasedMembers || formerMembers
        settings.showExternalCoaches = false
        return settings
    }

    /// Family names of the members that the settings select.
    private func selectedFamilyNames(_ settings: SettingsStruct) throws -> Set<String> {
        let fetchRequest = NSFetchRequest<MemberPortfolio>(entityName: "MemberPortfolio")
        fetchRequest.predicate = settings.memberPredicate
        return Set(try context.fetch(fetchRequest).map { $0.photographer.familyName })
    }

    @Test("Current members (which include officers) leave out former and deceased officers")
    func currentMembers() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings(currentMembers: true)) == ["Chairman", "Standard"])
    }

    @Test("Current club officers alone leave out former and deceased officers")
    func officersOnly() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings(officers: true)) == ["Chairman"])
    }

    @Test("Deceased members are shown when only that toggle is on, whatever their role")
    func deceasedOnly() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings(deceasedMembers: true))
                == ["DeceasedChairman", "DeceasedViceChairman"])
    }

    @Test("Former members include deceased ones, whatever their role")
    func formerMembers() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings(formerMembers: true))
                == ["FormerTreasurer", "DeceasedChairman", "DeceasedViceChairman"])
    }

    @Test("All toggles together show everyone: no toggle acts as a veto")
    func everything() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings(currentMembers: true, formerMembers: true))
                == ["Chairman", "Standard", "FormerTreasurer", "DeceasedChairman", "DeceasedViceChairman"])
    }

    @Test("A deceased officer not marked as former is no current officer, is treated as former")
    func deceasedOfficerNotMarkedFormer() throws {
        try createClub()
        #expect(try !selectedFamilyNames(settings(currentMembers: true)).contains("DeceasedViceChairman"))
        #expect(try !selectedFamilyNames(settings(officers: true)).contains("DeceasedViceChairman"))
        #expect(try selectedFamilyNames(settings(deceasedMembers: true)).contains("DeceasedViceChairman"))
        #expect(try selectedFamilyNames(settings(formerMembers: true)).contains("DeceasedViceChairman"))
    }

    @Test("No toggles on selects no members")
    func nothing() throws {
        try createClub()
        #expect(try selectedFamilyNames(settings()).isEmpty)
    }

}
