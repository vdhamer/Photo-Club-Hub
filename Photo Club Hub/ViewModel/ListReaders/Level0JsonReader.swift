//
//  Level0JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 12/03/2025.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct

// see root.level0.json for a syntax example

public class Level0JsonReader {

    public init(bgContext: NSManagedObjectContext,
                fileName: String = "root",  // can overrule the name for unit testing
                isBeingTested: Bool,
                useOnlyInBundleFile: Bool = false // true can be used to avoid publishing a test file to GitHub
               ) {
        _ = FetchAndProcessFile(
            bgContext: bgContext,
            fileSelector: FileSelector(fileName: fileName, isBeingTested: isBeingTested),
            fileType: "json", fileSubType: "level0", // "root.level0.json"
            useOnlyInBundleFile: useOnlyInBundleFile,
            isBeingTested: isBeingTested,
            fileContentProcessor: Level0JsonReader.readRootLevel0Json(bgContext:
                                                                      jsonData:
                                                                      fileSelector:
                                                                      isBeingTested:)
        )
    }

    // Marked as @Sendable to satisfy concurrency safety requirements.
    @Sendable static fileprivate func readRootLevel0Json(bgContext: NSManagedObjectContext,
                                                         jsonData: String,
                                                         fileSelector: FileSelector,
                                                         isBeingTested: Bool) {

        let fileName: String = fileSelector.fileName
        ifDebugPrint("\nStarting background read of \(fileName).level0.json to get standard Expertises and Languages.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // get entire JSON file

        // MARK: - process Experises section of Level0 file

        let jsonExpertises: [JSON] = jsonRoot["expertises"].arrayValue

        Level0JsonReader.parseExpertises(bgContext: bgContext, jsonExpertises: jsonExpertises)
        print("\(jsonExpertises.count) Expertises found")

        // MARK: - process Languages section of Level0 file

        let jsonLanguages: [JSON] = jsonRoot["languages"].arrayValue

        Level0JsonReader.parseLanguages(bgContext: bgContext, jsonLanguages: jsonLanguages)

        // MARK: - save Expertises and Languages

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire root.Level1.json file
            }
        } catch {
            ifDebugFatalError("Failed to save changes to Core Data: \(error)",
                              file: #fileID, line: #line)
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON Expertise changes in background")
            return
        }

        ifDebugPrint("Completed readRootLevel0Json() in background")
    }

    private static func parseExpertises(bgContext: NSManagedObjectContext, jsonExpertises: [JSON]) {
        for jsonExpertise in jsonExpertises {
            guard jsonExpertise["idString"].exists() else {
                ifDebugFatalError("JSON Expertise block is missing an idString field", file: #fileID, line: #line)
                continue  // if idString field doesn't exist, skip the Expertise
            }
            let idString = jsonExpertise["idString"].stringValue.canonicalCase

            guard jsonExpertise["name"].exists() else {
                ifDebugFatalError("JSON Expertise doesn't have any localized names", file: #fileID, line: #line)
                continue  // if name doesn't exist, skip the expertise
            }
            let jsonExpertiseNames = jsonExpertise["name"].arrayValue // dictionary of localized names for the expertise

            // Must insist on having at least one language for which jsonExpertise has a localized name
            guard jsonExpertiseNames.count > 0,
                  jsonExpertiseNames[0]["language"].exists(),
                  jsonExpertiseNames[0]["localizedString"].exists() else {
                ifDebugFatalError("Expertise doesn't have any localized representations", file: #fileID, line: #line)
                continue  // if it doesn't exist, skip the expertise (note that it even skips the "usage" array)
            }

            let jsonExpertiseOptionals = jsonExpertise["optional"] // rest will be empty if not found
            let jsonUsages = jsonExpertiseOptionals["usage"].arrayValue

            // Expertises from the root.level1.json file are by definition Standard
            let expertise = Expertise.findCreateUpdateStandard(context: bgContext,
                                                               id: idString,
                                                               names: jsonExpertiseNames,
                                                               usages: jsonUsages)
            print("Expertise <\(expertise.id)> with \(jsonExpertiseNames.count) localized name(s) found")
        }
    }

    private static func parseLanguages(bgContext: NSManagedObjectContext, jsonLanguages: [JSON]) {
        for jsonLanguage in jsonLanguages {
            guard jsonLanguage["isoCode"].exists(),
                  jsonLanguage["languageNameEN"].exists() else {
                ifDebugFatalError("Language doesn't have an isoCode or translated name", file: #fileID, line: #line)
                continue
            }

            let isoCode = jsonLanguage["isoCode"].stringValue
            let languageNameEN = jsonLanguage["languageNameEN"].stringValue

            let language = Language.findCreateUpdate(context: bgContext,
                                                     isoCode: isoCode,
                                                     nameENOptional: languageNameEN)
            print("Language <\(language.isoCode)> found")
        }
    }
}
