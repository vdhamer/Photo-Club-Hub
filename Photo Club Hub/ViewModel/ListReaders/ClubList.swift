//
//  ClubList.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/12/2023.
//

import SwiftyJSON
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D

let dataSourceURL: String = """
                            https://raw.githubusercontent.com/\
                            vdhamer/Photo-Club-Hub/\
                            main/\
                            Photo%20Club%20Hub/ViewModel/Lists/ClubList.json
                            """

/* Example of basic ClubList.json content
{
    "clubs": [
        {
            "idPlus": {
                "town": "Eindhoven",
                "fullName": "Fotogroep de Gender",
                "nickName": "FG deGender"
            },
            "coordinates": {
                "latitude": 51.42398,
                "longitude": 5.45010
            }
            "website": "https://www.fcdegender.nl",
            "memberList": "https://www.example.com/deGenderMemberList.json"
        }
    ],
    "museums": [
        {
            "idPlus": {
                "town": "New York",
                "fullName": "Fotografiska New York",
                "nickName": "Fotografiska NYC"
            },
            "coordinates": {
                "latitude": 40.739278,
                "longitude": -73.986722
            }
            "website": "https://www.fotografiska.com/nyc/",
            "wikipedia": "https://en.wikipedia.org/wiki/Fotografiska_New_York",
            "image": "https://commons.wikimedia.org/wiki/File:Fotografiska_New_York_(51710073919).jpg"
        }
    ]
}
*/

class ClubList {

    init(bgContext: NSManagedObjectContext) {

        bgContext.perform { // move to background thread
            self.readJSONClubList(bgContext: bgContext, organizationTypes: [.clubs, .musea])
        }
    }

    private func readJSONClubList(bgContext: NSManagedObjectContext, organizationTypes: [OrganizationType]) {

        ifDebugPrint("Starting readJSONClubList() in background")

        if let data = try? String(contentsOf: URL(string: dataSourceURL)!) {
            // give the data to SwiftyJSON to parse
            let jsonRoot = JSON(parseJSON: data) // call to SwiftyJSON

            // extract the Clubs part of JSON string
            for organizationType in organizationTypes {
                let jsonOrganizations: [JSON] = jsonRoot[organizationType.unlocalizedString].arrayValue
                ifDebugPrint("Found \(jsonOrganizations.count) \(organizationType.unlocalizedString) in file.")

                for jsonOrganization in jsonOrganizations {
                    let idPlus = PhotoClubIdPlus(fullName: jsonOrganization["idPlus"]["fullName"].stringValue,
                                                 town: jsonOrganization["idPlus"]["town"].stringValue,
                                                 nickname: jsonOrganization["idPlus"]["nickName"].stringValue)
                    ifDebugPrint("Adding organization \(idPlus.fullName), \(idPlus.town), aka \(idPlus.nickname)")
                    let jsonCoordinates = jsonOrganization["coordinates"]
                    let coordinates = CLLocationCoordinate2D(latitude: jsonCoordinates["latitude"].doubleValue,
                                                             longitude: jsonCoordinates["longitude"].doubleValue)
                    let photoClubWebsite = URL(string: jsonOrganization["website"].stringValue)
                    _ = PhotoClub.findCreateUpdate(context: bgContext,
                                                   photoClubIdPlus: idPlus,
                                                   photoClubWebsite: photoClubWebsite,
                                                   fotobondNumber: nil, kvkNumber: nil,
                                                   coordinates: coordinates)
                }
                do {
                    if bgContext.hasChanges {
                        try bgContext.save() // commit all changes
                    }
                    ifDebugPrint("Completed inserting/updated JSON ClubList in background")
                } catch {
                    ifDebugFatalError("Failed to save changes to Core Data",
                                      file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                    // in release mode, the failed database update is only logged. App doesn't stop.
                }
            }
        } else {
            ifDebugFatalError("Please check URL \(dataSourceURL)")
        }

    }

}
