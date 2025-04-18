//
//  RootLevel2JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

// import SwiftyJSON // now used as a single file
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D
import SwiftyJSON // for JSON struct

// see xampleMin.level2.json and xampleMax.level2.json for syntax examples

class Level2JsonReader { // normally running on a background thread

    enum MergeError: Error {
        case invalidJsonData(String)
        case clubNotFound(String)
        case mismatchedNameTown(String)
        case saveFailed
    }

    // init() does all the work: it fetches the JSON data, parses it, and updates the data stored in Core Data.
    init(bgContext: NSManagedObjectContext,
         urlComponents: UrlComponents, // what to parse
         club: Organization, // club who's data we are supposed to be receiving via this url
         useOnlyFile: Bool = false) {

        if let jsonData = getJsonData(urlComponents: urlComponents,
                                      useOnlyFile: useOnlyFile) { // fetch JSON level 2 as String
            do {
                try mergeLevel2Json(bgContext: bgContext, // for database access on this thread
                                    jsonData: jsonData, // string to parse
                                    club: club, // club that this level2.json file should describe
                                    urlComponents: urlComponents) // used for logging messages
            } catch MergeError.invalidJsonData(let message) {
                ifDebugFatalError("Error reading file \(urlComponents.shortName): \(message)")
            } catch MergeError.mismatchedNameTown(let message) {
                ifDebugFatalError("Error reading file \(urlComponents.shortName): \(message)")
            } catch MergeError.saveFailed {
                ifDebugFatalError("Error: failed to save \(urlComponents.shortName) data to Core Data")
            } catch {
                ifDebugFatalError("An unexpected error occurred in Level2JsonReader: \(error)")
            }
        }

    }

    // Fetch the JSON content and returns it as a String. If there is an error, it returns `nil` instead.
    fileprivate func getJsonData(urlComponents: UrlComponents, useOnlyFile: Bool) -> String? {

        guard let url = URL(string: urlComponents.fullURLstring)
            else { return nil } // not a valid URL

        // if fetching online works, and is allowed, this has priority over fetching from app bundle
        if let jsonDataFetchedOnline: String = try? String(contentsOf: url, encoding: .utf8), !useOnlyFile {
            guard !jsonDataFetchedOnline.isEmpty else { return nil }
            return jsonDataFetchedOnline // got the requested JSON from an online URL (preferred option)
        }

        print("Could not access online file \(url.relativeString).")
        // last chance: fetch json data from app bundle
        guard let filePath: String = Bundle.main.path(forResource: urlComponents.dataSourceFile + "." +
                                                      urlComponents.fileSubType,
                                                      ofType: urlComponents.fileType)
        else {
            ifDebugFatalError("Could not access local file \(urlComponents.shortName).")
            return nil
        } // can't locate file within main app bundle

        // get the requested JSON from a file in the main app bundle
        if let fileData = try? String(contentsOfFile: filePath, encoding: .utf8) {
            return fileData.isEmpty ? nil : fileData
        } else {
            // calling fatalError is ok for a compile-time constant (as defined above)
            ifDebugFatalError("Cannot load Level 2 file \(urlComponents.fullURLstring)")
            return nil
        }
    }

    fileprivate func mergeLevel2Json(bgContext: NSManagedObjectContext,
                                     jsonData: String,
                                     club: Organization,
                                     urlComponents: UrlComponents) throws {

        ifDebugPrint("Loading members of \(club.fullNameTown) from \(urlComponents.shortName) in background.")

        let jsonRoot: JSON = JSON(parseJSON: jsonData) // pass the data to SwiftyJSON to parse
        guard jsonRoot["club"].exists() else {
            throw MergeError.invalidJsonData("Cannot find club keyword in \(urlComponents.shortName)") }

        let jsonClub: JSON = jsonRoot["club"]
        guard jsonClub["idPlus"].exists() else {
            throw MergeError.invalidJsonData("Cannot find idPlus keyword in \(urlComponents.shortName)") }

        let jsonIdPlus: JSON = jsonClub["idPlus"]
        if !isDebug() {
            // Only load Level2 files for clubs already listed in a Level1 file.
            // But skip this checking when in DEBUG mode (=developers).
            // And, when in RELEASE mode, this aborts mergeLevel2Json with a string printed - which nobody will see.
            guard jsonIdPlus["town"].stringValue == club.town && jsonIdPlus["fullName"].stringValue == club.fullName
                else { throw MergeError.mismatchedNameTown("""
                                                           Error: mismatched Name/Town for club \
                                                           \(club.fullNameTown) in \(urlComponents.shortName)
                                                           """) }
        }
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
                                              idPlus: idPlus,
                                              coordinates: CLLocationCoordinate2DMake(0, 0),
                                              optionalFields: OrganizationOptionalFields() // empty
                                             )
        }

        if jsonRoot["members"].exists() { // could be empty (although level2.json file would only contain club data)
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
            throw MergeError.saveFailed /*"Error: failed to save Level 2 changes to Core Data"*/
       }

        ifDebugPrint("Completed mergeLevel2Json() in background")
    }

    fileprivate func loadMember(bgContext: NSManagedObjectContext,
                                member: JSON,
                                club: Organization,
                                urlComponents: UrlComponents) { // for error messages only (data might come from bundle)
        guard member["name"].exists(),
              member["name"]["givenName"].exists(),
              // if member["name"]["givenName"] doesn't exist, SwiftyJSON returns ""
              member["name"]["familyName"].exists() else { // check for mandatory fields
            ifDebugFatalError("Missing or incomplete member/name data in \(urlComponents.shortName)")
            return
        }
        let givenName: String = member["name"]["givenName"].stringValue
        let infixName: String = member["name"]["infixName"].stringValue
        let familyName: String = member["name"]["familyName"].stringValue
        print("""
                  Member "\(givenName) \
                  \(infixName=="" ? "" : infixName + " ")\
                  \(familyName)" \
                  found in \(urlComponents.shortName)
                  """)
        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         personName: PersonName(
                                                            givenName: givenName,
                                                            infixName: infixName, // may be ""
                                                            familyName: familyName),
                                                         optionalFields: PhotographerOptionalFields()) // filled later

        let memberPortfolio: MemberPortfolio
        if member["optional"].exists() { // could contain photographerOptionalFields, memberOptionalFields, or both.
            memberPortfolio = loadPhotographerAndMemberOptionals(bgContext: bgContext,
                                                                 jsonOptionals: member["optional"],
                                                                 photographer: photographer, club: club)
        } else {
            memberPortfolio = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                                               organization: club,
                                                               photographer: photographer,
                                                               optionalFields: MemberOptionalFields(
                                                                    memberRolesAndStatus: MemberRolesAndStatus(
                                                                                                jsonRoles: [:],
                                                                                                jsonStatus: [:])
                                                               )
            )
        }
        memberPortfolio.refreshFirstImage()
    }

    fileprivate func loadClubOptionals(bgContext: NSManagedObjectContext,
                                       jsonOptionals: JSON,
                                       club: Organization) {
        let clubWebsite = jsonOptionals["website"].exists() ? URL(string: jsonOptionals["website"].stringValue) : nil
        let wikipedia: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "wikipedia")
        let fotobondNumber = jsonOptionals["nlSpecific"]["fotobondNumber"].exists()  ? // id of club
            jsonOptionals["nlSpecific"]["fotobondNumber"].int16Value : nil
        let contactEmail: String? = jsonOptionals["contactEmail"].exists() ?
            jsonOptionals["contactEmail"].stringValue : nil
        let coordinates: CLLocationCoordinate2D = jsonOptionals["coordinates"].exists() ?
            CLLocationCoordinate2D(latitude: jsonOptionals["coordinates"]["latitude"].doubleValue,
                                    longitude: jsonOptionals["coordinates"]["longitude"].doubleValue) :
            CLLocationCoordinate2DMake(0, 0) // for safety: Level 1 file should always contain coordinate fields
        let localizedRemarks: [JSON] = jsonOptionals["remark"].arrayValue // empty array if missing

        _ = Organization.findCreateUpdate(context: bgContext,
                                          organizationTypeEnum: OrganizationTypeEnum.club,
                                          idPlus: OrganizationIdPlus(id: OrganizationID(fullName: club.fullName,
                                                                                     town: club.town),
                                                                     nickname: club.nickname),
                                          coordinates: coordinates,
                                          optionalFields: OrganizationOptionalFields(
                                              organizationWebsite: clubWebsite,
                                              wikipedia: wikipedia,
                                              fotobondNumber: fotobondNumber,
                                              contactEmail: contactEmail,
                                              localizedRemarks: localizedRemarks
                                              )
        )
    }

    fileprivate func loadPhotographerAndMemberOptionals(bgContext: NSManagedObjectContext,
                                                        jsonOptionals: JSON,
                                                        photographer: Photographer,
                                                        club: Organization) -> MemberPortfolio {

        let memberRolesAndStatus = MemberRolesAndStatus(jsonRoles: jsonOptionals["roles"],
                                                        jsonStatus: jsonOptionals["status"])

        let birthday: String? = jsonOptionals["birthday"].exists() ? jsonOptionals["birthday"].stringValue : nil
        let photographerWebsite: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "website")
        let photographerImage: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "photographerImage")
        let featuredImage: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "featuredImage")
        let level3URL: URL? = jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "level3URL")

        let membershipStartDate: Date? = jsonOptionals["membershipStartDate"].exists() ?
            jsonOptionals["membershipStartDate"].stringValue.extractDate() : nil
        let membershipEndDate: Date? = jsonOptionals["membershipEndDate"].exists() ?
            jsonOptionals["membershipEndDate"].stringValue.extractDate() : nil

        let photographerKeywords: [JSON] = jsonOptionals["keywords"].arrayValue

        let fotobondNumber: Int32? = jsonOptionals["nlSpecific"]["fotobondNumber"].exists() ?
            jsonOptionals["nlSpecific"]["fotobondNumber"].int32Value : nil

        // some attributes are at the Photographer level...
        _ = Photographer.findCreateUpdate(context: bgContext,
                                          personName: PersonName(givenName: photographer.givenName,
                                                                 infixName: photographer.infixName,
                                                                 familyName: photographer.familyName),
                                          optionalFields: PhotographerOptionalFields(
                                              bornDT: birthday?.extractDate(),
                                              isDeceased: memberRolesAndStatus.isDeceased(),
                                              photographerWebsite: photographerWebsite,
                                              photographerImage: photographerImage,
                                              photographerKeywords: photographerKeywords
                                              )
                                          )

        // ...while some attributes are at the Photographer-as-Member-of-club level (instead of Photographer level)
        return MemberPortfolio.findCreateUpdate(
            bgContext: bgContext,
            organization: club,
            photographer: photographer,
            removeMember: false, // remove records for members that no longer on list
            optionalFields: MemberOptionalFields(
                featuredImage: featuredImage,
                featuredImageThumbnail: featuredImage,
                level3URL: level3URL, // address of portfolio data for this member
                memberRolesAndStatus: memberRolesAndStatus,
                fotobondNumber: fotobondNumber,
                membershipStartDate: membershipStartDate,
                membershipEndDate: membershipEndDate
            )
        )

    }

    fileprivate func jsonOptionalsToURL(jsonOptionals: JSON, key: String) -> URL? {
        guard jsonOptionals[key].exists() else { return nil }
        guard let string = jsonOptionals[key].string else { return nil }
        return URL(string: string) // returns nil if the string doesn’t represent a valid URL
    }

}
