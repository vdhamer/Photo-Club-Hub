//
//  Level2JsonReaders+Helpers.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/01/2026.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct
import CoreLocation // for CLLocationCoordinate2D

extension Level2JsonReader {

    static func loadMember(bgContext: NSManagedObjectContext,
                           member: JSON,
                           club: Organization) {
        // MARK: - /members/member/name
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
                                                             familyName: familyName
                                                         ),
                                                         optionalFields: PhotographerOptionalFields()) // filled later

        let memberPortfolio: MemberPortfolio
        if member["optional"].exists() { // could contain photographerOptionalFields, memberOptionalFields, or both.
            memberPortfolio = Level2JsonReader.loadPhotographerAndMemberOptionals(bgContext: bgContext,
                                                                                  jsonOptionals: member["optional"],
                                                                                  photographer: photographer,
                                                                                  club: club)
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

    static func loadClubOptionals(bgContext: NSManagedObjectContext,
                                  jsonOptionals: JSON,
                                  club: Organization) {
        let clubWebsite = jsonOptionals["website"].exists() ? URL(string: jsonOptionals["website"].stringValue) : nil
        let wikipedia: URL? = Level2JsonReader.jsonOptionalsToURL(jsonOptionals: jsonOptionals, key: "wikipedia")
        // level2URL is deliberately ignoring to avoid possibility of overruling what is stated in Level 1 file
        let localizedRemarks: [JSON] = jsonOptionals["remark"].arrayValue // empty array if missing
        let maintainerEmail: String? = jsonOptionals["maintainerEmail"].exists() ?
            jsonOptionals["maintainerEmail"].stringValue : nil
        let fotobondClubNumberID: Int16? = jsonOptionals["nlSpecific"]["fotobondNumber"].exists() ? // FotobondNL clubid
            jsonOptionals["nlSpecific"]["fotobondNumber"].int16Value : nil

        _ = Organization.findCreateUpdate(context: bgContext,
                                          organizationTypeEnum: OrganizationTypeEnum.club,
                                          idPlus: OrganizationIdPlus(fullName: club.fullName, town: club.town,
                                                                     nickname: club.nickName),
                                          coordinates: club.coordinates,
                                          optionalFields: OrganizationOptionalFields(
                                              organizationWebsite: clubWebsite,
                                              wikipedia: wikipedia,
                                              fotobondClubNumber: FotobondClubNumber(id: fotobondClubNumberID),
                                              maintainerEmail: maintainerEmail,
                                              localizedRemarks: localizedRemarks
                                              )
        )
    }

    private static func loadPhotographerAndMemberOptionals(bgContext: NSManagedObjectContext,
                                                           jsonOptionals: JSON,
                                                           photographer: Photographer,
                                                           club: Organization) -> MemberPortfolio {

        let memberRolesAndStatus = MemberRolesAndStatus(jsonRoles: jsonOptionals["roles"],
                                                        jsonStatus: jsonOptionals["status"])

        let birthday: String? = jsonOptionals["birthday"].exists() ? jsonOptionals["birthday"].stringValue : nil
        let photographerWebsite: URL? = Level2JsonReader.jsonOptionalsToURL(jsonOptionals: jsonOptionals,
                                                                            key: "website")
        let photographerImage: URL? = Level2JsonReader.jsonOptionalsToURL(jsonOptionals: jsonOptionals,
                                                                          key: "photographerImage")
        let featuredImage: URL? = Level2JsonReader.jsonOptionalsToURL(jsonOptionals: jsonOptionals,
                                                                      key: "featuredImage")
        let level3URL: URL? = Level2JsonReader.jsonOptionalsToURL(jsonOptionals: jsonOptionals,
                                                                  key: "level3URL")

        let membershipStartDate: Date? = jsonOptionals["membershipStartDate"].exists() ?
            jsonOptionals["membershipStartDate"].stringValue.extractDate() : nil
        let membershipEndDate: Date? = jsonOptionals["membershipEndDate"].exists() ?
            jsonOptionals["membershipEndDate"].stringValue.extractDate() : nil

        let photographerExpertises: [JSON] = jsonOptionals["expertises"].arrayValue

        let fotobondMemberNumber: FotobondMemberNumber? = jsonOptionals["nlSpecific"]["fotobondNumber"].exists() ?
            FotobondMemberNumber(id: jsonOptionals["nlSpecific"]["fotobondNumber"].int32Value) : nil

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
                                              photographerExpertises: photographerExpertises
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
                fotobondMemberNumber: fotobondMemberNumber,
                membershipStartDate: membershipStartDate,
                membershipEndDate: membershipEndDate
            )
        )

    }

    private static func jsonOptionalsToURL(jsonOptionals: JSON, key: String) -> URL? {
        guard jsonOptionals[key].exists() else { return nil }
        guard let string = jsonOptionals[key].string else { return nil }
        return URL(string: string) // returns nil if the string doesn’t represent a valid URL
    }

    /// Checks the completeness of the IdPlus part of a level2.json file and its value against the expected value..
    /// - Parameters:
    ///   - jsonClub: The JSON object representing the club data.
    ///   - targetIdPlus: The expected value for OrganizationIdPlus.
    ///   - isBeingTested: if true, disable check on town.
    /// - Returns: The validated OrganizationIdPlus if all fields exist and match, or nil otherwise.
    static func checkIdPlus(jsonClub: JSON,
                            targetIdPlus: OrganizationIdPlus,
                            isBeingTested: Bool) -> OrganizationIdPlus? {

        // MARK: - /club/idPlus loading
        guard jsonClub["idPlus"].exists() else {
            ifDebugFatalError("Cannot find `idPlus` keyword for club \(targetIdPlus.fullName)")
            return nil
        }
        let jsonIdPlus: JSON = jsonClub["idPlus"]

        // MARK: - /club/idPlus/fullName
        guard jsonIdPlus["fullName"].exists() else {
            ifDebugFatalError("Cannot find `fullName` keyword in idPlus for club \(targetIdPlus.fullName)")
            return nil
        }
        // MARK: - /club/idPlus/town
        guard jsonIdPlus["town"].exists() else {
            ifDebugFatalError("Cannot find `town` keyword in idPlus for club \(targetIdPlus.fullName)")
            return nil
        }
        // MARK: - /club/idPlus/nickName
        guard jsonIdPlus["nickName"].exists() else {
            ifDebugFatalError("Cannot find `nickName` keyword in idPlus for club \(targetIdPlus.fullName)")
            return nil
        }
        // MARK: - /club/idPlus check if this is the club we were expecting
        let idPlus = OrganizationIdPlus(fullName: jsonIdPlus["fullName"].stringValue, // idPlus found _inside_ JSON file
                                        town: jsonIdPlus["town"].stringValue,
                                        nickname: jsonIdPlus["nickName"].stringValue)
        guard idPlus.fullName == targetIdPlus.fullName &&
              idPlus.nickname == targetIdPlus.nickname else {// does file contain the expected club?
            ifDebugFatalError("""
                              Warning: JSON file expecting to contain club \
                              \(targetIdPlus.fullName) (\(targetIdPlus.nickname)) \
                              contains club \(idPlus.fullName) (\(idPlus.nickname)) instead.
                              """)
            return nil // in non-debug software, just skip loading this Level 2 file
        }

        if isBeingTested == false {
            guard idPlus.town == targetIdPlus.town else { // expected town?
                ifDebugFatalError("""
                                  Warning: there is a mismatch for the Town of \(targetIdPlus.fullName): \
                                  the in-file town is \(idPlus.town) but \(targetIdPlus.town) was expected.
                                  """)
                return nil // in non-debug software, just skip loading this Level 2 file
            }
        }

        return idPlus
    }

    static func loadClubCoordinates(jsonClub: JSON, targetIdPlus: OrganizationIdPlus) ->
        CLLocationCoordinate2D? {

        guard jsonClub["coordinates"].exists() else {
            ifDebugFatalError("Cannot find `coordinates` keyword for club \(targetIdPlus.fullName)")
            return nil
        }

        guard jsonClub["coordinates"]["latitude"].exists() && jsonClub["coordinates"]["longitude"].exists() else {
            ifDebugFatalError("`coordinates` keyword missing `latitude` or `longitude` for \(targetIdPlus.fullName)")
            return nil
        }

        let coordinates: CLLocationCoordinate2D =
            CLLocationCoordinate2D(latitude: jsonClub["coordinates"]["latitude"].doubleValue,
                                   longitude: jsonClub["coordinates"]["longitude"].doubleValue)
        return coordinates
    }

}
