//
//  RootLevel2JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

// import SwiftyJSON // now used as a single file
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D
import RegexBuilder // for Regex

/* Example of level2.json file with one member
 {
     "club":
         {
             "idPlus": {
                 "town": "Eindhoven",
                 "fullName": "Fotogroep de Gender",
                 "nickName": "FG deGender"
             },
             "coordinates": {
                 "latitude": 51.42398,
                 "longitude": 5.45010
             },
             "website": "https://www.fcdegender.nl",
             "level2URL": "https://www.example.com/deGender.level2.json"
         },
     "members": [
         {
             "name": {
                 "givenName": "Peter",
                 "infixName": "van den",
                 "familyName": "Hamer"
             },
             "roles": {
                 "isChairman": false,
                 "isViceChairman": false,
                 "isTreasurer": false,
                 "isSecretary": false,
                 "isAdmin": true
             },
             "status": {
                 "isDeceased": false,
                 "isFormerMember": false,
                 "isHonoraryMember": false,
                 "isMentor": false,
                 "isPropectiveMember": false
             },
             "birthday": "9999-10-18T00:00:00.000Z",
             "website": "https://glass.photo/vdhamer",
             "featuredImage": "http://www.vdhamer.com/wp-content/uploads/2023/11/PeterVanDenHamer.jpg",
             "level3URL": "https://www.example.com/FG_deGender/Peter_van_den_Hamer.imagelist.json"
         }
     ]
 }
 */

class Level2JsonReader { // normally running on a background thread

    // init() actually does all the work: fetches the JSON string, parses it, and updates the CoreData database
    init(bgContext: NSManagedObjectContext,
         urlComponents: UrlComponents, // what to parse
         club: Organization, // club who's data we are supposed to be receiving via this url
         useOnlyFile: Bool = false) {

        if let jsonData = getJsonData(urlComponents: urlComponents,
                                      useOnlyFile: useOnlyFile) { // fetch JSON level 2 as String

            let errorString = mergeLevel2Json(bgContext: bgContext, // for database access on this thread
                                              jsonData: jsonData, // string to parse
                                              club: club, // club that this level2.json file should describe
                                              urlComponents: urlComponents) // used for logging messages

            if errorString != nil { // there is probably a more Swift-y way to do this (using Error class and throw)
                print("Error reading Level 2 file \(urlComponents.shortName): \(errorString!)")
            }
        }

    }

    // fetch the JSON content and returns it as a String. But returns `nil` if there is an error.
    private func getJsonData(urlComponents: UrlComponents, useOnlyFile: Bool) -> String? {

        guard let url = URL(string: urlComponents.fullURLstring)
            else { return nil } // not a valid URL

        // if fetching online works, and is allowed, this has priority over fetching from app bundle
        if let jsonDataFetchedOnline: String = try? String(contentsOf: url), !useOnlyFile {
            guard !jsonDataFetchedOnline.isEmpty else { return nil }
            return jsonDataFetchedOnline // got the requested JSON from an online URL (preferred option)
        }

        print("""
              Could not access online file \(url.relativeString). \
              Trying local file \(urlComponents.shortName) instead.
              """)
        // last chance: fetch json data from app bundle
        guard let filePath: String = Bundle.main.path(forResource: urlComponents.dataSourceFile + "." +
                                                                   urlComponents.fileSubType,
                                                      ofType: urlComponents.fileType)
            else { return nil } // can't locate file within main app bundle

        // get the requested JSON from a file in the main app bundle
        if let fileData = try? String(contentsOfFile: filePath) {
            return fileData.isEmpty ? nil : fileData
        } else {
            // calling fatalError is ok for a compile-time constant (as defined above)
            ifDebugFatalError("Cannot load Level 2 file \(urlComponents.fullURLstring)")
            return nil
        }

    }

    private func mergeLevel2Json(bgContext: NSManagedObjectContext,
                                 jsonData: String,
                                 club: Organization,
                                 urlComponents: UrlComponents) -> String? { // string contains error

        ifDebugPrint("Loading members of \(club.fullNameTown) from \(urlComponents.shortName) in background.")

        let jsonRoot: JSON = JSON(parseJSON: jsonData) // pass the data to SwiftyJSON to parse

        guard jsonRoot["club"].exists() else { return "Cannot find club keyword in \(urlComponents.shortName)" }
        let jsonClub: JSON = jsonRoot["club"]

        guard jsonClub["idPlus"].exists() else { return "Cannot find idPlus keyword in \(urlComponents.shortName)" }
        let jsonIdPlus: JSON = jsonClub["idPlus"]
        guard jsonIdPlus["town"].stringValue == club.town && jsonIdPlus["fullName"].stringValue == club.fullName
            else { return "Error: mismatched Name/Town for club \(club.fullNameTown) in \(urlComponents.shortName)" }
        let idPlus = OrganizationIdPlus(fullName: jsonIdPlus["fullName"].stringValue,
                                        town: jsonIdPlus["town"].stringValue,
                                        nickname: jsonIdPlus["nickName"].stringValue)

        // optional fields
        let website = jsonClub["website"].exists() ? URL(string: jsonClub["website"].stringValue) : nil
        let wikipedia = jsonClub["wikipedia"].exists() ? URL(string: jsonClub["wikipedia"].stringValue) : nil
        let fotobondNumber = jsonClub["nlSpecific"]["fotobondNumber"].int16Value
        let coordinates: CLLocationCoordinate2D? = jsonClub["coordinates"].exists() ?
            CLLocationCoordinate2D(latitude: jsonClub["coordinates"]["latitude"].doubleValue,
                                   longitude: jsonClub["coordinates"]["longitude"].doubleValue) : nil
        let localizedRemarks = jsonClub["remark"].arrayValue

        _ = Organization.findCreateUpdate(context: bgContext,
                                          organizationTypeEnum: OrganizationTypeEnum.club,
                                          idPlus: idPlus,
                                          website: website,
                                          wikipedia: wikipedia,
                                          fotobondNumber: fotobondNumber, // int16
                                          coordinates: coordinates,
                                          localizedRemarks: localizedRemarks)

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire Level2.json file
            }
        } catch {
            ifDebugFatalError("Failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON ClubList items in background")
            return "Error: failed to save Level 2 changes to Core Data"
        }

        ifDebugPrint("Completed mergeLevel2Json() in background")
        return nil // no error
    }

}
