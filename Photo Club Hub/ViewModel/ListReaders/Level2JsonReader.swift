//
//  RootLevel2JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct

// see TemplateMin.level2.json and TemplateMax.level2.json for example data files

public class Level2JsonReader { // normally running on a background thread

    // init() does it all: it fetches the JSON data, parses it, and updates the data stored in Core Data.
    public init(bgContext: NSManagedObjectContext,
                organizationIdPlus: OrganizationIdPlus,
                isBeingTested: Bool,
                useOnlyInBundleFile: Bool = false, // true avoids fetching the latest version from GitHub
                includeFilePath: [String] = [] // captures recursion path like ["root","museums","museumsNL"]
               ) {
        _ = FetchAndProcessFile( // FetchAndProcessFile fetches jsonData and passes it to readRootLevel2Json()
                                bgContext: bgContext,
                                fileSelector: FileSelector(organizationIdPlus: organizationIdPlus,
                                                           isBeingTested: isBeingTested),
                                fileType: "json",
                                fileSubType: "level2", // "fgDeGender.level2.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                isBeingTested: isBeingTested,
                                includeFilePath: includeFilePath,
                                fileContentProcessor: Level2JsonReader.readRootLevel2Json
        )
    }

    // swiftlint:disable:next function_parameter_count
    @Sendable static private func readRootLevel2Json(bgContext: NSManagedObjectContext,
                                                     jsonData: String,
                                                     fileSelector: FileSelector,
                                                     useOnlyInBundleFile: Bool,
                                                     isBeingTested: Bool,
                                                     includeFilePath: [String]) {

        guard fileSelector.organizationIdPlus != nil else { // need expected id of a club
            fatalError("Missing `targetIdorganizationIdPlus` in readRootLevel2Json()")
        }
        let targetIdPlus: OrganizationIdPlus = fileSelector.organizationIdPlus! // safe due to preceding guard statement
        ifDebugPrint("Will try to Load members of club \(targetIdPlus.fullName) in background.")

        // MARK: - /
        let jsonRoot: JSON = JSON(parseJSON: jsonData) // pass the data to SwiftyJSON to parse

        // MARK: - /club
        guard jsonRoot["club"].exists() else {
            ifDebugFatalError("Cannot find `club` keyword for club \(targetIdPlus.fullName)")
            return
        }
        let jsonClub: JSON = jsonRoot["club"]

        // MARK: - /club/idPlus
        guard let idPlus = checkIdPlus(jsonClub: jsonClub,
                                       targetIdPlus: targetIdPlus,
                                       isBeingTested: isBeingTested) else {
            return // in the Debug version checkIdPlus forces a fatal error, so we never reach this point
        }

        // normally the club already exists, but if it somehow doesn't we will just have to create it
        let club: Organization = Organization.findCreateUpdate(context: bgContext,
                                                               organizationTypeEnum: OrganizationTypeEnum.club,
                                                               idPlus: idPlus)

        // MARK: - /club/coordinates
        if let coordinates = loadClubCoordinates(jsonClub: jsonClub, targetIdPlus: targetIdPlus) {
            if club.coordinates != coordinates {
                club.coordinates = coordinates
            }
        }

        // MARK: - /club/optional may not exist
        if jsonClub["optional"].exists() {
            loadClubOptionals(bgContext: bgContext,
                              jsonOptionals: jsonClub["optional"],
                              club: club)
        }

        // MARK: - /members
        if jsonRoot["members"].exists() { // could be empty (although level2.json file would only contain club data)
            let members: [JSON] = jsonRoot["members"].arrayValue
            for member in members {
                Level2JsonReader.loadMember(bgContext: bgContext, member: member, club: club)
            }
        }

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire Level2.json file
            }
        } catch {
            ifDebugFatalError("Error saving changes to Core Data: \(error)", file: #fileID, line: #line)
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON ClubList items in background")
            ifDebugFatalError("Error: failed to save Level 2 changes to Core Data")
       }

        ifDebugPrint("Completed mergeLevel2Json() in background")
    }

}
