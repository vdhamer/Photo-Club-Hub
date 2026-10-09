//
//  DeletedMembershipViewsTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 08/10/2026.
//

import Testing
import SwiftUI // for Binding
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D
import Photo_Club_Hub_Data // for PersistenceController, MemberPortfolio, etc.
@testable import Photo_Club_Hub

// Deleting a MemberPortfolio lets SwiftUI build or redraw a view for it after its relationships were nullified
// (#802, #874). Today the deleter is pull-to-refresh, which wipes the store;
// in a future release it is the pruning of obsolete records (Photo-Club-Hub-Data#39), on whichever context that runs.
//
// Every view that observes a MemberPortfolio must therefore survive being given a deleted MemberPortfolio,
// both in `init` and in `body`.
// A regression here does not fail one test: the `photographer` accessor calls fatalError and stops the run.
// The scroll-then-refresh timing that triggered #874 is not reproduced here; it needs a real List on a device.
@Suite("Views that observe a MemberPortfolio survive a deleted membership")
@MainActor
struct DeletedMembershipViewsTests {

    private let context = PersistenceController(inMemory: true).container.viewContext

    /// Creates a club, a photographer and a membership linking them, then deletes the membership and saves.
    /// Returns the deleted membership and its former photographer, which is still alive.
    private func deletedMembership() throws -> (MemberPortfolio, Photographer) {
        let photographer = Photographer.findCreateUpdate( // create a photographer
            context: context,
            personName: PersonName(givenName: "Jan", infixName: "van der", familyName: "Test"),
            optionalFields: PhotographerOptionalFields()
        )
        let organization = Organization.findCreateUpdate( // create a club
            context: context,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: "Test Club", town: "Testtown", nickname: "TestClub"),
            coordinates: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            optionalFields: OrganizationOptionalFields()
        )
        let member = MemberPortfolio.findCreateUpdate( // enrol photographer into club
            bgContext: context,
            organization: organization,
            photographer: photographer,
            optionalFields: MemberOptionalFields()
        )
        try context.save()

        context.delete(member)
        try context.save()
        return (member, photographer)
    }

    @Test("A deleted membership is in the state that crashed #874")
    func deletedMembershipHasNoPhotographer() throws {
        let (member, _) = try deletedMembership()
        #expect(member.isUsable == false)
        #expect(member.photographer_ == nil)
    }

    @Test("MemberPortfolioRow can be created and drawn for a deleted membership")
    func memberPortfolioRow() throws {
        let (member, _) = try deletedMembership()
        let row = MemberPortfolioRow(member: member, selectedPortfolio: .constant(nil))
        _ = row.body
    }

    @Test("MemberPortfolioRowContent can be rendered for a deleted membership")
    func memberPortfolioRowContent() throws {
        let (member, photographer) = try deletedMembership()
        let content = MemberPortfolioRowContent(member: member,
                                                photographer: photographer,
                                                selectedPortfolio: .constant(nil))
        _ = content.body
    }

    @Test("DualImageWithCaptionAndControls can be created and rendered for a deleted membership")
    func dualImageWithCaptionAndControls() throws {
        let (member, photographer) = try deletedMembership()
        let dualImage = DualImageWithCaptionAndControls(member: member,
                                                        photographer: photographer,
                                                        settings: SettingsStruct.defaultValue,
                                                        squareSize: 80,
                                                        caption: false,
                                                        flipImageFlag: .constant(false),
                                                        selectedPortfolio: .constant(nil))
        _ = dualImage.body
    }

    @Test("PhotographersThumbnail can be created and rendered for a deleted membership")
    func photographersThumbnail() throws {
        let (member, _) = try deletedMembership()
        let thumbnail = PhotographersThumbnail(member: member,
                                               settings: SettingsStruct.defaultValue,
                                               selectedPortfolio: .constant(nil))
        _ = thumbnail.body
    }

}
