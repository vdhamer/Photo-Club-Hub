//
//  RootLevel2JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

// import SwiftyJSON // now used as a single file
import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct
import CoreLocation // for CLLocationCoordinate2D

// see XampleMin.level2.json or XampleMax.level2.json for syntax examples

public class Level2JsonReader { // normally running on a background thread

    // init() does it all: it fetches the JSON data, parses it, and updates the data stored in Core Data.
    public init(bgContext: NSManagedObjectContext,
                organizationIdPlus: OrganizationIdPlus,
                isInTestBundle: Bool,
                useOnlyInBundleFile: Bool = false // true avoids fetching the latest version from GitHub
               ) {
        _ = FetchAndProcessFile( // FetchAndProcessFile fetches jsonData and passes it to readRootLevel2Json()
                                bgContext: bgContext,
                                fileSelector: FileSelector(organizationIdPlus: organizationIdPlus,
                                                           isInTestBundle: isInTestBundle),
                                fileType: "json",
                                fileSubType: "level2", // "fgDeGender.level2.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                fileContentProcessor: readRootLevel2Json(bgContext:jsonData:fileSelector:)
                               )
    }

    fileprivate func readRootLevel2Json(bgContext: NSManagedObjectContext,
                                        jsonData: String,
                                        fileSelector: FileSelector) {

        guard fileSelector.organizationIdPlus != nil else { // need id of a club
            fatalError("Missing `targetIdorganizationIdPlus` in readRootLevel2Json()")
        }
        let targetIdPlus: OrganizationIdPlus = fileSelector.organizationIdPlus! // safe due to preceding guard statement
        ifDebugPrint("Loading members of club \(targetIdPlus.fullName) in background.")

        let jsonRoot: JSON = JSON(parseJSON: jsonData) // pass the data to SwiftyJSON to parse
        guard jsonRoot["club"].exists() else {
            ifDebugFatalError("Cannot find `club` keyword for club \(targetIdPlus.fullName)")
            return
        }

        let jsonClub: JSON = jsonRoot["club"]
        guard jsonClub["idPlus"].exists() else {
            ifDebugFatalError("Cannot find `idPlus` keyword for club \(targetIdPlus.fullName)")
            return
        }

        let jsonIdPlus: JSON = jsonClub["idPlus"]
        let idPlus = OrganizationIdPlus(fullName: jsonIdPlus["fullName"].stringValue, // idPlus found inside JSON file
                                        town: jsonIdPlus["town"].stringValue,
                                        nickname: jsonIdPlus["nickName"].stringValue)

        guard idPlus.fullName == targetIdPlus.fullName else { // does fine contain the right club?
            ifDebugFatalError("""
                              Warning: JSON file for club \(targetIdPlus.fullName) \
                              contains club \(idPlus.fullName) instead.
                              """)
            return // in non-debug software, just don't load the file
        }

        // normally  the club already exists, but if not.. create it
        let club: Organization = Organization.findCreateUpdate(context: bgContext,
                                                               organizationTypeEnum: OrganizationTypeEnum.club,
                                                               idPlus: idPlus)

        // optional fields within jsonClub
        if jsonClub["optional"].exists() {
            loadClubOptionals(bgContext: bgContext,
                              jsonOptionals: jsonClub["optional"],
                              club: club)
        }

        if jsonRoot["members"].exists() { // could be empty (although level2.json file would only contain club data)
            let members: [JSON] = jsonRoot["members"].arrayValue
            for member in members {
                loadMember(bgContext: bgContext, member: member, club: club)
            }
        }

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire Level2.json file
            }
        } catch {
            ifDebugFatalError("Failed to save changes to Core Data", file: #fileID, line: #line)
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON ClubList items in background")
            ifDebugFatalError("Error: failed to save Level 2 changes to Core Data")
       }

        ifDebugPrint("Completed mergeLevel2Json() in background")
    }

    fileprivate func loadMember(bgContext: NSManagedObjectContext,
                                member: JSON,
                                club: Organization) {
        guard member["name"].exists(),
              member["name"]["givenName"].exists(),
              // if member["name"]["givenName"] doesn't exist, SwiftyJSON returns ""
              member["name"]["familyName"].exists() else { // check for mandatory fields
            ifDebugFatalError("Missing or incomplete member/name data in \(club.id.fullName)")
            return
        }
        let givenName: String = member["name"]["givenName"].stringValue
        let infixName: String = member["name"]["infixName"].stringValue
        let familyName: String = member["name"]["familyName"].stringValue
        print("""
                  Member "\(givenName) \
                  \(infixName=="" ? "" : infixName + " ")\
                  \(familyName)" found in \(club.id.fullName)
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
                                          idPlus: OrganizationIdPlus(fullName: club.fullName, town: club.town,
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
