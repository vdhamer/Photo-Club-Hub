//
//  Level1JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/12/2023.
//

import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D
import SwiftyJSON // for JSON struct

private let dataSourcePath: String = """
                                     https://raw.githubusercontent.com/\
                                     vdhamer/Photo-Club-Hub/\
                                     main/JSON/
                                     """
private let dataSourceFile: String = "root"
private let fileSubType = "level1" // level1 is part of file name, not the extension
private let fileType = "json"
private let organizationTypesToLoad: [OrganizationTypeEnum] = [.club, .museum]

// see xampleMin.level1.json and xampleMax.level1.json for syntax examples

class Level1JsonReader {

    init(bgContext: NSManagedObjectContext,
         useOnlyFile: Bool = false) {

        bgContext.perform { // switch to supplied background thread
            guard let filePath = Bundle.main.path(forResource: dataSourceFile + "." + fileSubType,
                                                  ofType: fileType) else {
                fatalError("""
                           Internal file \(dataSourceFile + "." + fileSubType + "." + fileType) \
                           not found. Check file name.
                           """)
            }
            let data = self.getData(
                fileURL: URL(string: dataSourcePath + dataSourceFile + "." +
                             fileSubType + "." + fileType)!,
                filePath: filePath,
                useOnlyFile: useOnlyFile
            )
            self.readRootLevel1Json(bgContext: bgContext,
                                    data: data,
                                    for: organizationTypesToLoad)
        }
    }

    // try to fetch the online root.level1.json file, and if that fails use a copy from the app's bundle instead
    fileprivate func getData(fileURL: URL,
                             filePath: String,
                             useOnlyFile: Bool) -> String {
        if let urlData = try? String(contentsOf: fileURL, encoding: .utf8), !useOnlyFile {
            return urlData
        }
        print("Could not access online file \(fileURL.relativeString). Trying in-app file \(filePath) instead.")
        if let fileData = try? String(contentsOfFile: filePath, encoding: .utf8) {
            return fileData
        }
        // calling fatalError is ok for a compile-time constant (as defined above)
        fatalError("Cannot load Level 1 file \(filePath)")
    }

    fileprivate func readRootLevel1Json(bgContext: NSManagedObjectContext,
                                        data: String,
                                        for organizationTypeEnumsToLoad: [OrganizationTypeEnum]) {

        ifDebugPrint("\nWill read Level 1 file (\(dataSourceFile)) with a list of organizations in the background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: data) // call to SwiftyJSON

        // extract the `organizationTypes` in `organizationTypeEnumsToLoad` one-by-one from `jsonRoot`
        for organizationTypeEnum in organizationTypeEnumsToLoad {

            let jsonOrganizationsOfOneType: [JSON] = jsonRoot[organizationTypeEnum.unlocalizedPlural].arrayValue
            ifDebugPrint("Found \(jsonOrganizationsOfOneType.count) \(organizationTypeEnum.unlocalizedPlural) " +
                         "in \(dataSourceFile).")

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
