//
//  Level1JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/12/2023.
//

import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D
import SwiftyJSON // for JSON struct

private let organizationTypesToLoad: [OrganizationTypeEnum] = [.club, .museum] // types are loaded one-by-one

public class Level1JsonReader {

    public init(bgContext: NSManagedObjectContext,
                fileName: String = "root",  // can overrule the name in tests or in top-level app code
                isBeingTested: Bool,
                useOnlyInBundleFile: Bool, // true can be used to avoid publishing a test file to GitHub
                includeFilePath: [String] = [] // captures recursion path like ["root","museums","museumsNL"]
               ) {
        var extendedIncludeFilePath: [String] = includeFilePath // copy because parameter itself is `let`
        extendedIncludeFilePath.append(fileName) // extend with extra name
        _ = FetchAndProcessFile(bgContext: bgContext,
                                fileSelector: FileSelector(fileName: fileName, isBeingTested: isBeingTested),
                                fileType: "json", fileSubType: "level1", // "root.level1.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                isBeingTested: isBeingTested,
                                includeFilePath: extendedIncludeFilePath,
                                fileContentProcessor: Level1JsonReader.readRootLevel1Json
        )
    }

    @Sendable static private func readRootLevel1Json(bgContext: NSManagedObjectContext,
                                                     jsonData: String,
                                                     fileSelector: FileSelector,
                                                     useOnlyInBundleFile: Bool,
                                                     isBeingTested: Bool = false,
                                                     includeFilePath: [String]) {

        let fileName = fileSelector.fileName
        if #available(iOS 18, macOS 15, *) {
            // If we've already visited `filename`, avoid loading it twice. For performance and against infinite loops.
            // Under iOS 18, 26 and beyond use Level1History which uses Mutex - introduced in iOS 18.
            if Level1JsonReader.level1History.isVisited(fileName: fileName) {
                ifDebugFatalError("Infinite loop or duplicate file in Include tree: \(includeFilePath)")
                return
            }
        } else {
            // Under iOS 17 limit the nesting depth of includeFilePath to prevent executing infinite loops.
            if includeFilePath.count >= 10 {
                ifDebugFatalError("Excessive branch depth in Include tree: \(includeFilePath)")
                return
            }
        }
        ifDebugPrint("\nWill read \(fileName).level1.json with a list of organizations in the background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // call to SwiftyJSON

        triggerProcessingOfLevel1URLIncludes(from: jsonRoot,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile,
                                             includeFilePath: includeFilePath)

        // extract the `organizationTypes` in `organizationTypeEnumsToLoad` one-by-one from `jsonRoot`
        for organizationTypeEnum in organizationTypesToLoad {

            let jsonOrganizationsOfOneType: [JSON] = jsonRoot[organizationTypeEnum.unlocalizedPlural].arrayValue
            ifDebugPrint("Found \(jsonOrganizationsOfOneType.count) \(organizationTypeEnum.unlocalizedPlural) " +
                         "in \(fileName).")

            // extract the requested items (clubs, museums) of that organizationType one-by-one from the json file
            for jsonOrganization in jsonOrganizationsOfOneType {
                processOrganization(bgContext: bgContext,
                                         organizationTypeEnum: organizationTypeEnum,
                                         jsonOrganization: jsonOrganization)
            }

        } // end of loop that scans organizationTypeEnumsToLoad

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire root.Level1.json file
            }
        } catch {
            ifDebugFatalError("Failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON ClubList items in background")
            return
        }

        ifDebugPrint("Completed readRootLevel1Json() in background")
    }

    /// Processes a single JSON Organizatio, and creates or updates the corresponding Organization record in Core Data.
    /// - Parameters:
    ///    - bgContext: The managed object context used for Core Data operations.
    ///    - organizationTypeEnum: The type of organization being processed (e.g., Club or Museum).
    ///    - jsonOrganization: The JSON object containing the data for the Organization to process.
    @Sendable static private func processOrganization(bgContext: NSManagedObjectContext,
                                                      organizationTypeEnum: OrganizationTypeEnum,
                                                      jsonOrganization: JSON) {
        let idPlus = OrganizationIdPlus(fullName: jsonOrganization["idPlus"]["fullName"].stringValue,
                                        town: jsonOrganization["idPlus"]["town"].stringValue,
                                        nickname: jsonOrganization["idPlus"]["nickName"].stringValue)
        ifDebugPrint("Adding organization \(idPlus.fullName), \(idPlus.town), aka \(idPlus.nickname).")

        let jsonCoordinates = jsonOrganization["coordinates"]
        let coordinates = CLLocationCoordinate2D(latitude: jsonCoordinates["latitude"].doubleValue,
                                                 longitude: jsonCoordinates["longitude"].doubleValue)

        let jsonOrganizationOptionals = jsonOrganization["optional"] // rest will be empty if not found
        let organizationWebsite = URL(string: jsonOrganizationOptionals["website"].stringValue)
        let level2URL = URL(string: jsonOrganizationOptionals["level2URL"].stringValue)
        let wikipedia = URL(string: jsonOrganizationOptionals["wikipedia"].stringValue)
        let fotobondClubNumberID: Int16? = jsonOrganizationOptionals["nlSpecific"]["fotobondNumber"].exists() ?
            jsonOrganizationOptionals["nlSpecific"]["fotobondNumber"].int16Value : nil
        let maintainerEmail = jsonOrganizationOptionals["maintainerEmail"].stringValue
        let localizedRemarks = jsonOrganizationOptionals["remark"].arrayValue
        _ = Organization.findCreateUpdate(context: bgContext,
                                          organizationTypeEnum: organizationTypeEnum,
                                          idPlus: idPlus,
                                          coordinates: coordinates,
                                          optionalFields: OrganizationOptionalFields(
                                              organizationWebsite: organizationWebsite,
                                              level2URL: level2URL,
                                              wikipedia: wikipedia,
                                              fotobondClubNumber: FotobondClubNumber(id: fotobondClubNumberID),
                                              maintainerEmail: maintainerEmail,
                                              localizedRemarks: localizedRemarks)
                                          )
    }

}
