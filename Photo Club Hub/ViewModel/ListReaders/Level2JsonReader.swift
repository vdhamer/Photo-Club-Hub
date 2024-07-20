//
//  RootLevel2JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

// import SwiftyJSON // now used as a single file
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D

/* Example of level2.json file with one member but will a complete set of optional fields
 {
     "club":
         {
             "idPlus": {
                 "town": "Eindhoven",
                 "fullName": "Fotogroep de Gender",
                 "nickName": "FG deGender"
             },
             "optional": {
                 "coordinates": {
                     "latitude": 51.42398,
                     "longitude": 5.45010
                 },
                 "website": "https://www.fcdegender.nl",
                 "wikipedia": "https://nl.wikipedia.org/wiki/Gender_(beek)",
                 "level2URL": "https://www.example.com/deGender.level2.json",
                 "remark": [
                     {
                         "language": "EN",
                         "value": "Note that Fotogroep de Gender is abbreviated fcdegender.nl for historical reasons."
                     }
                 ],
                 "nlSpecific": {
                     "fotobondNumber": 1620
                 }
            }
         },
     "members": [
         {
             "name": {
                 "givenName": "Peter",
                 "infixName": "van den",
                 "familyName": "Hamer"
             },
             "optional": {
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
                 "birthday": "9999-10-18",
                 "website": "https://glass.photo/vdhamer",
                 "featuredImage": "http://www.vdhamer.com/wp-content/uploads/2023/11/PeterVanDenHamer.jpg",
                 "level3URL": "https://www.example.com/FG_deGender/Peter_van_den_Hamer.level3.json"
             }
         }
     ]
 }
 */

class Level2JsonReader { // normally running on a background thread

    // init() does all the work here: it fetches the JSON data, parses it, and updates the CoreData database.
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

    // Fetch the JSON content and returns it as a String. If there is an error, it returns `nil` instead.
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

    // returned String is nil or describes error
    private func mergeLevel2Json(bgContext: NSManagedObjectContext,
                                 jsonData: String,
                                 club: Organization,
                                 urlComponents: UrlComponents) -> String? {

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

        // optional fields within jsonClub
        if jsonClub["optional"].exists() {
            loadClubOptionals(bgContext: bgContext,
                              jsonOptionals: jsonClub["optional"],
                              club: club)
        } else {
            // no club/optional fields, so just create a basic club - for what it's worth.
            _ = Organization.findCreateUpdate(context: bgContext,
                                              organizationTypeEnum: OrganizationTypeEnum.club,
                                              idPlus: idPlus
                                              // , // following fields are filled with nil or empty array as defaults
                                              // website: nil,
                                              // wikipedia: nil,
                                              // fotobondNumber: nil,
                                              // coordinates: nil,
                                              // localizedRemarks: [JSON]()
                                             )
        }

        if jsonRoot["members"].exists() { // could conceivably be empty (although it wouldn't be too useful)
            let members: [JSON] = jsonRoot["members"].arrayValue
            for member in members {
                loadMember(bgContext: bgContext, member: member, club: club, urlComponents: urlComponents)
            }
        }

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

    private func loadMember(bgContext: NSManagedObjectContext,
                            member: JSON,
                            club: Organization,
                            urlComponents: UrlComponents) { // for error messages
        guard member["name"].exists(),
              member["name"]["givenName"].exists(),
              member["name"]["familyName"].exists() else { // check for mandatory fields
            ifDebugFatalError("Missing or incomplete member/name data in \(urlComponents.shortName)")
            return
        }
        let givenName: String = member["name"]["givenName"].stringValue
        let infixName: String = member["name"]["infixName"].stringValue
        let familyName: String = member["name"]["familyName"].stringValue
        print("""
                  Member \(givenName) \
                  \(infixName=="" ? "" : infixName + " ")\
                  \(familyName) \
                  found in \(urlComponents.shortName)
                  """)
        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         personName: PersonName(
                                                            givenName: givenName,
                                                            infixName: infixName, // may be ""
                                                            familyName: familyName),
                                                         organization: club) // club used only in print()
        if member["optional"].exists() {
            loadMemberOptionals(bgContext: bgContext,
                                jsonOptionals: member["optional"],
                                photographer: photographer, club: club)
        } else {
            _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                                 organization: club,
                                                 photographer: photographer,
                                                 memberRolesAndStatus: MemberRolesAndStatus(role: [:], status: [:])
            )
        }
    }

    private func loadClubOptionals(bgContext: NSManagedObjectContext,
                                   jsonOptionals: JSON,
                                   club: Organization) {
        let website = jsonOptionals["website"].exists() ? URL(string: jsonOptionals["website"].stringValue) : nil
        let wikipedia: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "wikipedia")
        let fotobondNumber = jsonOptionals["nlSpecific"]["fotobondNumber"].exists()  ?
        jsonOptionals["nlSpecific"]["fotobondNumber"].int16Value : nil
        let coordinates: CLLocationCoordinate2D? = jsonOptionals["coordinates"].exists() ?
             CLLocationCoordinate2D(latitude: jsonOptionals["coordinates"]["latitude"].doubleValue,
                                    longitude: jsonOptionals["coordinates"]["longitude"].doubleValue) : nil
        let localizedRemarks = jsonOptionals["remark"].arrayValue // empty array if missing

        _ = Organization.findCreateUpdate(context: bgContext,
                                          organizationTypeEnum: OrganizationTypeEnum.club,
                                          idPlus: OrganizationIdPlus(id: PhotoClubId(fullName: club.fullName,
                                                                                     town: club.town),
                                                                     nickname: club.nickName),
                                          website: website,
                                          wikipedia: wikipedia,
                                          fotobondNumber: fotobondNumber,
                                          coordinates: coordinates,
                                          localizedRemarks: localizedRemarks)
    }

    private func loadMemberOptionals(bgContext: NSManagedObjectContext,
                                     jsonOptionals: JSON,
                                     photographer: Photographer,
                                     club: Organization) {
        let birthday: String? = jsonOptionals["birthday"].exists() ? jsonOptionals["birthday"].stringValue : nil

        let website: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "website")
        let featuredImage: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "featuredImage")
        let level3URL: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "level3URL")

        // some attributes are at the Photographer level...
        _ = Photographer.findCreateUpdate(context: bgContext,
                                          personName: PersonName(givenName: photographer.givenName,
                                                                 infixName: photographer.infixName,
                                                                 familyName: photographer.familyName),
                                          memberRolesAndStatus: MemberRolesAndStatus(role: [:], status: [:]), // TODO ??
                                          website: website,
                                          bornDT: birthday?.extractDate(),
                                          organization: club ) // club is only shown on console for debug purposes

        // ...while some attributes are at the Photographer as Member of club level
        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                            organization: club,
                                            photographer: photographer,
                                            memberRolesAndStatus: MemberRolesAndStatus(role: [:],
                                                                                       status: [:]),
                                            dateInterval: nil,
                                            memberWebsite: nil,
                                            latestImage: featuredImage,
                                            latestThumbnail: nil
                                           )

    }

    private func jsonOptionalsToURL(jsonOptionals: JSON, key: String) -> URL? {
        guard jsonOptionals[key].exists() else { return nil }
        guard let string = jsonOptionals[key].string else { return nil }
        return URL(string: string) // returns nil if the string doesn’t represent a valid URL
    }

}
