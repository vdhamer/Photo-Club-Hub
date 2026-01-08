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

    @Test("Refresh featured image") func urlOfImageIndex_unknownClub() {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "RefreshFeaturedImageTests"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        let randomTownForTesting = String.random(length: 10)
        _ = XampleMinMembersProvider(bgContext: bgContext,
                                     isBeingTested: true,
                                     useOnlyInBundleFile: false,
                                     randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Xample Club With Minimal Data",
                                        town: randomTownForTesting, // new town to distinguish from normal club data
                                        nickname: "XampleMin")

        let club = Organization.findCreateUpdate(context: bgContext, organizationTypeEnum: .club, idPlus: idPlus)

        let photographer = Photographer.findCreateUpdate(context: bgContext, personName: PersonName(givenName: "John",
                                                                                                    infixName: "",
                                                                                                    familyName: "Doe"))

        let memberPortfolio = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                                               organization: club,
                                                               photographer: photographer)

        let result: URL? = memberPortfolio.urlOfImageIndex
        #expect(result?.absoluteString == imageForUnknownClub)
    }

}
