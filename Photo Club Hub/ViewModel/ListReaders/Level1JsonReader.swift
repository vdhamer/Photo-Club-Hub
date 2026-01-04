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

//    static let level1Mutext = Level1Mutex()

    public init(bgContext: NSManagedObjectContext,
                fileName: String = "root",  // can overrule the name for unit testing
                isBeingTested: Bool,
                useOnlyInBundleFile: Bool = false // true can be used to avoid publishing a test file to GitHub
               ) {
        _ = FetchAndProcessFile(bgContext: bgContext,
                                fileSelector: FileSelector(fileName: fileName, isBeingTested: isBeingTested),
                                fileType: "json", fileSubType: "level1", // "root.level1.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                isBeingTested: isBeingTested,
                                fileContentProcessor: Level1JsonReader.readRootLevel1Json(bgContext:
                                                                                          jsonData:
                                                                                          fileSelector:
                                                                                          useOnlyInBundleFile:
                                                                                          isBeingTested:))
    }

    @Sendable static private func readRootLevel1Json(bgContext: NSManagedObjectContext,
                                                     jsonData: String,
                                                     fileSelector: FileSelector,
                                                     useOnlyInBundleFile: Bool,
                                                     isBeingTested: Bool = false) {

        let fileName = fileSelector.fileName
//        Task {
//            static let level1Mutex = Level1Mutex()
//            guard await level1Mutex.isBlockedBecauseRevisited(level1FileName: fileName) else { return }
//        }
        ifDebugPrint("\nWill read \(fileName).level1.json with a list of organizations in the background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // call to SwiftyJSON

        triggerProcessingOfLevel1URLIncludes(from: jsonRoot,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile)

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
        let contactEmail = jsonOrganizationOptionals["contactEmail"].stringValue
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
                                              contactEmail: contactEmail,
                                              localizedRemarks: localizedRemarks)
                                          )
    }

}

extension Level1JsonReader {

    /// Loads any files listed in the `level1URLIncludes` array in the Header of a level1.json file.
    ///
    /// Loading is done on a new NSManagedObjectContext.
    /// If an entry is not a valid URL, the function emits a debug fatal error if the app has been built in Debug mode.
    /// When the app is built in Release mode, errors cause the array element to be silently ignored.
    ///
    /// - Parameter jsonRoot: The parsed SwiftyJSON root object for a Level 1 JSON file.

    @Sendable static private func triggerProcessingOfLevel1URLIncludes(
        from jsonRoot: JSON,
        isBeingTested: Bool,
        useOnlyInBundleFile: Bool
    ) {
        let includeJSONs: [JSON] = jsonRoot["level1Header"]["level1URLIncludes"].arrayValue
        for includeJSON in includeJSONs {
            let includeURLoptional: URL? = URL(string: includeJSON.stringValue)
            guard let includeURL: URL = includeURLoptional else {
                ifDebugFatalError("Included level1URL <\(includeJSON.stringValue)> is not a valid URL")
                continue
            }
            let includeNameSegments: [Substring] = includeURL.lastPathComponent.split(separator: ".")
            guard !includeNameSegments.isEmpty else {
                ifDebugFatalError("level1URLIncludes contains an empty string")
                continue
            } // if it is empty string, just ignore
            let includeName: String = String(includeNameSegments[0]) // there has to be an element [0]
            guard includeNameSegments[1].lowercased() == "level1",
                  includeNameSegments[2].lowercased() == "json" else {
                ifDebugFatalError("level1URLIncludes does not end with level1.json")
                continue
            }
            print("Will load included file \(includeName).level1.json on a new background thread")

            let bgContext = PersistenceController.shared.container.newBackgroundContext()
            bgContext.name = "Level 1 loader for \(includeName)"
            if isDebug && Settings.errorOnCoreDataMerge {
                bgContext.mergePolicy = NSMergePolicy.error // to force detection of Core Data merge issues
            } else {
                bgContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // .mergeByPropertyObjectTrump better?
            }
            bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
            bgContext.undoManager = nil // no undo manager (for speed)

            _ = Level1JsonReader(
                bgContext: bgContext,
                fileName: includeName,
                isBeingTested: isBeingTested,
                useOnlyInBundleFile: useOnlyInBundleFile)
        }
    }

}

// actor Level1Mutex {
//    private var visitedLevel1Files: Set<String> = []
//
//    func isBlockedBecauseRevisited(level1FileName: String) async -> Bool {
//        if visitedLevel1Files.contains(level1FileName) {
//            return true
//        } else {
//            visitedLevel1Files.insert(level1FileName)
//            return false
//        }
//
//    }
// }
