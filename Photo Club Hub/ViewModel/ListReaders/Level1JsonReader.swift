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

// see XampleMin.level1.json and XampleMax.level1.json for syntax examples

public class Level1JsonReader {

    public init(bgContext: NSManagedObjectContext,
                fileName: String = "root",  // can overrule the name for unit testing
                isInTestBundle: Bool,
                useOnlyInBundleFile: Bool = false // true can be used to avoid publishing a test file to GitHub
               ) {
        _ = FetchAndProcessFile(bgContext: bgContext,
                                fileSelector: FileSelector(fileName: fileName, isInTestBundle: isInTestBundle),
                                fileType: "json", fileSubType: "level1", // "root.level1.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                fileContentProcessor: readRootLevel1Json(bgContext:
                                                                         jsonData:
                                                                         fileSelector:))
    }

    fileprivate func readRootLevel1Json(bgContext: NSManagedObjectContext,
                                        jsonData: String,
                                        fileSelector: FileSelector) {

        let fileName = fileSelector.fileName
        ifDebugPrint("/nWill read (\(fileName)).level1.json with a list of organizations in the background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // call to SwiftyJSON

        // extract the `organizationTypes` in `organizationTypeEnumsToLoad` one-by-one from `jsonRoot`
        for organizationTypeEnum in organizationTypesToLoad {

            let jsonOrganizationsOfOneType: [JSON] = jsonRoot[organizationTypeEnum.unlocalizedPlural].arrayValue
            ifDebugPrint("Found \(jsonOrganizationsOfOneType.count) \(organizationTypeEnum.unlocalizedPlural) " +
                         "in \(fileName).")

            // extract the requested items (clubs, museums) of that organizationType one-by-one from the json file
            for jsonOrganization in jsonOrganizationsOfOneType {
                let idPlus = OrganizationIdPlus(fullName: jsonOrganization["idPlus"]["fullName"].stringValue,
                                                town: jsonOrganization["idPlus"]["town"].stringValue,
                                                nickname: jsonOrganization["idPlus"]["nickName"].stringValue)
                ifDebugPrint("Adding organization \(idPlus.fullName), \(idPlus.town), aka \(idPlus.nickname).")

                let jsonCoordinates = jsonOrganization["coordinates"]
                let coordinates = CLLocationCoordinate2D(latitude: jsonCoordinates["latitude"].doubleValue,
                                                         longitude: jsonCoordinates["longitude"].doubleValue)

                let jsonOrganizationOptionals = jsonOrganization["optional"] // rest will be empty if not found
                let organizationWebsite = URL(string: jsonOrganizationOptionals["website"].stringValue)
                let wikipedia = URL(string: jsonOrganizationOptionals["wikipedia"].stringValue)
                let fotobondNumber = jsonOrganizationOptionals["nlSpecific"]["fotobondNumber"].int16Value
                let contactEmail = jsonOrganizationOptionals["contactEmail"].stringValue
                let localizedRemarks = jsonOrganizationOptionals["remark"].arrayValue
                _ = Organization.findCreateUpdate(context: bgContext,
                                                  organizationTypeEnum: organizationTypeEnum,
                                                  idPlus: idPlus,
                                                  coordinates: coordinates,
                                                  optionalFields: OrganizationOptionalFields(
                                                      organizationWebsite: organizationWebsite,
                                                      wikipedia: wikipedia,
                                                      fotobondNumber: fotobondNumber, // Int16
                                                      contactEmail: contactEmail,
                                                      localizedRemarks: localizedRemarks)
                                                  )
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

}
