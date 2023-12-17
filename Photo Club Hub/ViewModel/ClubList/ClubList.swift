//
//  ClubList.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/12/2023.
//

import SwiftyJSON
import CoreData // for NSManagedObjectContext

let dataSourceURL: String = """
                            https://raw.githubusercontent.com/\
                            vdhamer/Photo-Club-Hub/\
                            main/\
                            Photo%20Club%20Hub/JsonFiles/ClubList.json
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

        bgContext.perform {
            self.readJSONClubList(bgContext: bgContext) // move to background thread
        }
    }

    private func readJSONClubList(bgContext: NSManagedObjectContext) {

        if let data = try? String(contentsOf: URL(string: dataSourceURL)!) {
            // give the data to SwiftyJSON to parse
            let jsonRoot = JSON(parseJSON: data) // call to SwiftyJSON

            // read the commits back out
            let jsonClubs = jsonRoot["clubs"].arrayValue

//            DispatchQueue.main.async { [unowned self] in
            var count = 1
            for jsonClub in jsonClubs {
                print("""
                      Club#\(count): \
                      \(jsonClub["idPlus"]["fullName"]), \
                      \(jsonClub["idPlus"]["town"])
                      """)
                count += 1
//                    let commit = Commit(context: self.container.viewContext) // create Commit object commit
//                    self.fillCommitFields(commit: commit, usingJSON: jsonGithubCommit) // populate Commit object fields
                }

//                saveRecordsToDatabase()
//            }
        } else {
            fatalError("Please check URL \(dataSourceURL)")
        }

    }

}
