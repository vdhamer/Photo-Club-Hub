//
//  OrganizationFindCreateUpdateTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 29/06/2026.
//
//  Covers Organization.findCreateUpdate idempotency and the throwing Organization.find(...) lookups.
//  The other test file OrganizationTest.swift covers the fullNameTown computed property.
//

import Testing // for macros like `expect`
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests Organization.findCreateUpdate & Organization.find") struct OrganizationFindCreateUpdateTests {

    private let testPersistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    init () {
        // Use a private in-memory store rather than PersistenceController.shared. Sharing the singleton
        // coordinator across parallel suites deadlocks (main-queue performAndWait fetches contending with
        // background-context saves) and lets suites pollute each other's records. See issue #756.
        testPersistenceController = PersistenceController(inMemory: true)
        viewContext = testPersistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // Counts Organization records matching the (fullName, town) identity.
    private func count(_ id: OrganizationID) -> Int {
        let predicate = NSPredicate(format: "fullName_ = %@ AND town_ = %@", // avoid localization
                                    argumentArray: [id.fullName, id.town])
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        return ((try? viewContext.fetch(fetchRequest)) ?? []).count
    }

    // Builds an OrganizationIdPlus that is unique to this test run.
    private func randomIdPlus() -> OrganizationIdPlus {
        OrganizationIdPlus(fullName: "UnitTest Club \(String.random(length: 10))",
                           town: "UnitTestTown\(String.random(length: 10))",
                           nickname: "nick\(String.random(length: 10))")
    }

    // MARK: - idempotency

    // Calling findCreateUpdate twice with the same identity must return the same object (no duplicate).
    @Test("findCreateUpdate is idempotent for an identical idPlus") func idempotentForSameIdPlus() {
        let idPlus = randomIdPlus()

        let org1 = Organization.findCreateUpdate(context: viewContext, organizationTypeEnum: .club, idPlus: idPlus)
        let org2 = Organization.findCreateUpdate(context: viewContext, organizationTypeEnum: .club, idPlus: idPlus)

        #expect(org1 === org2) // same managed object, not a second copy
        #expect(count(idPlus.id) == 1) // exactly one record exists for this identity
        #expect(org1.fullName == idPlus.fullName)
        #expect(org1.town == idPlus.town)
    }

    // MARK: - organizationType is non-identifying

    // Identity is (fullName, town); organizationType is not part of it, and is only set when the
    // organization is first created (never changed on a later update). So a second findCreateUpdate
    // with the same name+town but a different type returns the SAME object with its ORIGINAL type -
    // you cannot have a club and a museum with the same name in the same town.
    @Test("same name+town cannot become a second organization of a different type")
    func sameNameTownDifferentTypeIsSameObject() {
        let idPlus = randomIdPlus()

        let asClub = Organization.findCreateUpdate(context: viewContext,
                                                   organizationTypeEnum: .club,
                                                   idPlus: idPlus)
        let asMuseum = Organization.findCreateUpdate(context: viewContext,
                                                     organizationTypeEnum: .museum,
                                                     idPlus: idPlus)

        #expect(asMuseum === asClub) // same object, not a second row
        #expect(count(idPlus.id) == 1) // still exactly one organization
        // type stayed as first created (.club); the requested .museum was silently ignored
        #expect(asClub.organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
    }

    // MARK: - nickname is non-identifying

    // The data model constrains identity on (fullName, town), NOT on nickName, so two distinct
    // organizations are allowed to share a nickname. This pins down that intended behaviour.
    // Note: we deliberately do NOT call Organization.find(nickname:) here - with duplicate
    // nicknames it hits ifDebugFatalError, which would crash this (debug) test run.
    @Test("two organizations may share a nickname (nickname is non-identifying)")
    func duplicateNicknameAllowed() {
        let sharedNickname = "dup\(String.random(length: 10))" // both organizations will use this nickname

        let org1 = Organization.findCreateUpdate(
            context: viewContext,
            organizationTypeEnum: .club,
            idPlus: OrganizationIdPlus(fullName: "UnitTest Club A \(String.random(length: 8))",
                                       town: "UnitTestTownA\(String.random(length: 8))",
                                       nickname: sharedNickname))
        let org2 = Organization.findCreateUpdate(
            context: viewContext,
            organizationTypeEnum: .club,
            idPlus: OrganizationIdPlus(fullName: "UnitTest Club B \(String.random(length: 8))",
                                       town: "UnitTestTownB\(String.random(length: 8))",
                                       nickname: sharedNickname))

        #expect(org1 !== org2) // genuinely two different organizations
        #expect(org1.nickName == sharedNickname)
        #expect(org2.nickName == sharedNickname)

        // both records coexist: no uniqueness constraint on nickName
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nickName_ = %@", argumentArray: [sharedNickname])
        #expect(((try? viewContext.fetch(fetchRequest)) ?? []).count == 2)
    }

    // MARK: - nil update semantics

    // A nil optional field must leave an already-set value untouched.
    @Test("nil optional field does not overwrite an existing value") func nilOptionalFieldDoesNotOverwrite() {
        let idPlus = randomIdPlus()
        let email = "test-\(String.random(length: 6))@example.com"

        let org1 = Organization.findCreateUpdate(
            context: viewContext,
            organizationTypeEnum: .club,
            idPlus: idPlus,
            optionalFields: OrganizationOptionalFields(maintainerEmail: email))
        #expect(org1.maintainerEmail == email)

        // default optionalFields has maintainerEmail == nil
        let org2 = Organization.findCreateUpdate(context: viewContext, organizationTypeEnum: .club, idPlus: idPlus)
        #expect(org2 === org1) // same object
        #expect(org2.maintainerEmail == email) // unchanged by the nil call
    }

    // MARK: - throwing find(...) lookups

    @Test("find(organizationID:) returns a known organization") func findKnownOrganizationID() throws {
        let idPlus = randomIdPlus()
        let created = Organization.findCreateUpdate(context: viewContext, organizationTypeEnum: .club, idPlus: idPlus)

        let found = try Organization.find(context: viewContext, organizationID: idPlus.id)
        #expect(found === created) // same object
    }

    @Test("find(organizationID:) throws for an unknown organization") func findUnknownOrganizationIDThrows() {
        let unknownID = OrganizationID(fullName: "NoSuch Club \(String.random(length: 10))",
                                       town: "NoSuchTown\(String.random(length: 10))")
        #expect(throws: (any Error).self) {
            _ = try Organization.find(context: viewContext, organizationID: unknownID)
        }
    }

    @Test("find(nickname:) returns a known organization") func findKnownNickname() throws {
        let idPlus = randomIdPlus()
        let created = Organization.findCreateUpdate(context: viewContext, organizationTypeEnum: .club, idPlus: idPlus)

        let found = try Organization.find(context: viewContext, nickname: idPlus.nickname)
        #expect(found === created)
    }

    @Test("find(nickname:) throws for an unknown nickname") func findUnknownNicknameThrows() {
        let unknownNickname = "noSuchNick\(String.random(length: 10))"
        #expect(throws: (any Error).self) {
            _ = try Organization.find(context: viewContext, nickname: unknownNickname)
        }
    }

}
