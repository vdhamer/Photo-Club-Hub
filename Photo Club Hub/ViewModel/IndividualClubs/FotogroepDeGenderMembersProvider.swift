//
//  FotogroepDeGenderMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import CoreData // for PersistenceController
import CoreLocation // for CLLocationCoordinate2DMake

class FotogroepDeGenderMembersProvider {

    init(bgContext: NSManagedObjectContext, townOverruleTo: String? = nil) {
        insertOnlineMemberData(bgContext: bgContext, overrulingTown: townOverruleTo)
    }

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, overrulingTown: String?) {

	let overruledTown: String = overrulingTown != nil ? overrulingTown! : "Eindhoven"
        let fotogroepDeGenderIdPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                                         town: overruledTown,
                                                         nickname: "fgDeGender")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepDeGenderIdPlus,
                                                     // real coordinates added in fgDeGender.level2.json
                                                     coordinates: CLLocationCoordinate2DMake(0, 0),
                                                     optionalFields: OrganizationOptionalFields() // empty fields
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.deGender,
                                 club: club,
                                 useOnlyFile: false)
            do {
                try bgContext.save()
            } catch {
                ifDebugFatalError("Failed to save club fgDeGender", file: #file, line: #line)
            }

        }
    }

}
