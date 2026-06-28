//
//  MemberPortfolio+refreshFirstImageTest.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 26/05/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSMergePolicy

@MainActor @Suite("Tests MemberPortfolio+refreshFirstImage") struct RefreshFirstImageTests {

    let imageForUnknownClub: String = "http://www.vdHamer.com/fgWaalre/Empty_Website/config.xml"

    @Test("Refresh featured image") func urlOfImageIndex_unknownClub() async {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "RefreshFeaturedImageTests"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        let randomTownForTesting = String.random(length: 10)
        _ = TemplateMinMembersProvider(bgContext: bgContext,
                                       isBeingTested: true,
                                       useOnlyInBundleFile: false,
                                       randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Template Club With Minimal Data",
                                        town: randomTownForTesting, // new town to distinguish from normal club data
                                        nickname: "TemplateMin")

        // All access to the private-queue bgContext must run on that context's own queue. Both the
        // findCreateUpdate() calls and the urlOfImageIndex property read (via level3URL) touch bgContext,
        // so wrap them in bgContext.perform { } to avoid a Core Data multi-threaded access trap (issue #708).
        let result: URL? = await bgContext.perform {
            let club = Organization.findCreateUpdate(context: bgContext, organizationTypeEnum: .club, idPlus: idPlus)

            let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                             personName: PersonName(givenName: "John",
                                                                                    infixName: "",
                                                                                    familyName: "Doe"))

            let memberPortfolio = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                                                   organization: club,
                                                                   photographer: photographer)

            return memberPortfolio.urlOfImageIndex
        }

        #expect(result?.absoluteString == imageForUnknownClub)
    }

}
