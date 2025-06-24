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
                isInTestBundle: Bool,
                useOnlyInBundleFile: Bool = false // true can be used to avoid publishing a test file to GitHub
               ) {
        _ = FetchAndProcessFile(bgContext: bgContext,
                                fileSelector: FileSelector(fileName: fileName, isInTestBundle: isInTestBundle),
                                fileType: "json", fileSubType: "level0", // "root.level0.json"
                                useOnlyInBundleFile: useOnlyInBundleFile,
                                fileContentProcessor: readRootLevel0Json(bgContext:
                                                                         jsonData:
                                                                         fileSelector:))
    }

    fileprivate func readRootLevel0Json(bgContext: NSManagedObjectContext,
                                        jsonData: String,
                                        fileSelector: FileSelector) {

        let fileName: String = fileSelector.fileName
        ifDebugPrint("\nWill read Level 0 file (\(fileName)) with standard expertises and languages in background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // get entire JSON file

        // parse Experises section of file
        let jsonExpertises: [JSON] = jsonRoot["expertises"].arrayValue

        parseExpertises(bgContext: bgContext, jsonExpertises: jsonExpertises)
        print("\(jsonExpertises.count) Expertises found")

        // parse Language section of file
        let jsonLanguages: [JSON] = jsonRoot["languages"].arrayValue

        parseLanguages(bgContext: bgContext, jsonLanguages: jsonLanguages)

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

    private func parseLanguages(bgContext: NSManagedObjectContext, jsonLanguages: [JSON]) {
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
            print("Language <\(language.isoCodeAllCaps)> found")
        }
    }

    private func parseExpertises(bgContext: NSManagedObjectContext, jsonExpertises: [JSON]) {
        for jsonExpertise in jsonExpertises {
            guard jsonExpertise["idString"].exists() else {
                ifDebugFatalError("Expertise doesn't have an idString", file: #fileID, line: #line)
                continue  // if it doesn't exist, skip the expertise
            }
            let idString = jsonExpertise["idString"].stringValue

            guard jsonExpertise["name"].exists() else {
                ifDebugFatalError("Expertise doesn't have localized representations", file: #fileID, line: #line)
                continue  // if it doesn't exist, skip the expertise
            }
            let jsonExpertiseName = jsonExpertise["name"].arrayValue // dictionary of localized names for the expertise

            // we insist on having at least one language for which jsonExpertise has a localized name
            guard jsonExpertiseName.count > 0,
                  jsonExpertiseName[0]["language"].exists(),
                  jsonExpertiseName[0]["localizedString"].exists() else {
                ifDebugFatalError("Expertise doesn't have any localized representations", file: #fileID, line: #line)
                continue  // if it doesn't exist, skip the expertise (note that it even skips the "usage" array)
            }

            let jsonExpertiseOptionals = jsonExpertise["optional"] // rest will be empty if not found
            let jsonUsage = jsonExpertiseOptionals["usage"].arrayValue

            let expertise = Expertise.findCreateUpdateStandard(context: bgContext,
                                                               id: idString,
                                                               name: jsonExpertiseName,
                                                               usage: jsonUsage)
            print("Expertise <\(expertise.id)> with \(jsonExpertiseName.count) localized name(s) found")
        }
    }

}
