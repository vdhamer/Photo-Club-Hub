//
//  RootLevel1JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/12/2023.
//

// import SwiftyJSON // now used as a single file
import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2D

private let dataSourcePath: String = """
                                     https://raw.githubusercontent.com/\
                                     vdhamer/Photo-Club-Hub/\
                                     main/\
                                     Photo%20Club%20Hub/ViewModel/Lists/
                                     """
private let dataSourceFile: String = "test2Club2Museum" // alternative file for testing TODO
// private let dataSourceFile: String = "root"
private let fileSubType = "level1" // level1 is part of file name, not the extension
private let fileType = "json"
private let organizationTypesToLoad: [OrganizationTypeEnum] = [.club, .museum]

/* Example of minimal root.level1.json file content
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
            "level2URL": "https://www.example.com/fgDeGender.level2.json"
            "remark": [
                {
                    "language": "NL",
                    "value": "In dit museum zijn scenes van het TV programma 'Het Perfecte Plaatje' opgenomen."
                }
            ]
        },
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
            "remark": [
                {
                    "language": "EN",
                    "value": "Associated with the original Fotografiska Museum in Stockholm"
                }
            ]
        }
    ]
}
*/

class RootLevel1JsonReader {

    init(bgContext: NSManagedObjectContext, useOnlyFile: Bool = false) {

        bgContext.perform { // switch to supplied background thread
            guard let filePath = Bundle.main.path(forResource: dataSourceFile + "." + fileSubType,
                                                  ofType: fileType) else {
                fatalError("""
                           Internal file \(dataSourceFile + "." + fileSubType + "." + fileType) \
                           not found. Check file name.
                           """)
            }
            self.readRootLevel1Json(bgContext: bgContext,
                                          data: getData(
                                                    fileURL: URL(string: dataSourcePath + dataSourceFile + "." +
                                                                         fileSubType + "." + fileType)!,
                                                    filePath: filePath
                                          ),
                                          for: organizationTypesToLoad)
        }

        func getData(fileURL: URL,
                     filePath: String) -> String {
            if let urlData = try? String(contentsOf: fileURL), !useOnlyFile {
                return urlData
            }
            print("Could not access online file \(fileURL.relativeString). Trying local file \(filePath) instead.")
            if let fileData = try? String(contentsOfFile: filePath) {
                return fileData
            }
            // calling fatalError is ok for a compile-time constant (as defined above)
            fatalError("Cannot load Level 1 file \(filePath)")
        }
    }

    private func readRootLevel1Json(bgContext: NSManagedObjectContext,
                                    data: String,
                                    for organizationTypeEnumsToLoad: [OrganizationTypeEnum]) {

        ifDebugPrint("\nGoing to read Level 1 file (\(dataSourceFile)) with a list of organizations - in background.")

        // give the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: data) // call to SwiftyJSON

        // extract the requested organizationType one-by-one from the json file
        for organizationTypeEnum in organizationTypeEnumsToLoad {
            Organization.hackOrganizationTypeEnum = organizationTypeEnum

            let jsonOrganizationsOfOneType: [JSON] = jsonRoot[organizationTypeEnum.unlocalizedPlural].arrayValue
            ifDebugPrint("Found \(jsonOrganizationsOfOneType.count) \(organizationTypeEnum.unlocalizedPlural) " +
                         "in \(dataSourceFile).")

            // extract the requested items (clubs, museums) of that organizationType one-by-one from the json file
            for jsonOrganization in jsonOrganizationsOfOneType {
                let idPlus = OrganizationIdPlus(fullName: jsonOrganization["idPlus"]["fullName"].stringValue,
                                                town: jsonOrganization["idPlus"]["town"].stringValue,
                                                nickname: jsonOrganization["idPlus"]["nickName"].stringValue)
                ifDebugPrint("Adding organization \(idPlus.fullName), \(idPlus.town), aka \(idPlus.nickname)")
                let jsonCoordinates = jsonOrganization["coordinates"]
                let coordinates = CLLocationCoordinate2D(latitude: jsonCoordinates["latitude"].doubleValue,
                                                         longitude: jsonCoordinates["longitude"].doubleValue)
                let website = URL(string: jsonOrganization["website"].stringValue)
                let wikipedia = URL(string: jsonOrganization["wikipedia"].stringValue)
                let localizedRemarks = jsonOrganization["remark"].arrayValue
                let fotobondNumber = jsonOrganization["nlSpecific"]["fotobondNumber"].int16Value
                _ = Organization.findCreateUpdate(context: bgContext,
                                                  organizationTypeEum: organizationTypeEnum,
                                                  idPlus: idPlus,
                                                  website: website,
                                                  wikipedia: wikipedia,
                                                  fotobondNumber: fotobondNumber, // int16
                                                  coordinates: coordinates,
                                                  localizedRemarks: localizedRemarks)
            }
            do {
                if bgContext.hasChanges { // optimization recommended by Apple
                    try bgContext.save() // persist contents of root.Level1.json file
                }
            } catch {
                ifDebugFatalError("Failed to save changes to Core Data",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the failed database update is only logged. App doesn't stop.
                ifDebugPrint("Failed to save JSON ClubList items in background")
                return
            }
        } // end of loop that scans organizationTypeEnumsToLoad
        ifDebugPrint("Completed readRootLevel1Json() in background")
    }

}
