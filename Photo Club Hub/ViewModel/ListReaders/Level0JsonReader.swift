//
//  Level0JsonReader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 12/03/2025.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct

private let dataSourcePath: String = """
                                     https://raw.githubusercontent.com/\
                                     vdhamer/Photo-Club-Hub/\
                                     main/JSON/
                                     """
private let dataSourceFile: String = "root"
private let fileSubType = "level0" // level0 is part of file name, the extension is "json" rather than "level0"
private let fileType = "json"

// see root.level0.json for a syntax example

class Level0JsonReader {

    init(bgContext: NSManagedObjectContext, useOnlyFile: Bool = false, overrulingDataSourceFile: String? = nil) {

        bgContext.perform { // switch to supplied background thread
            let overruledDataSourceFile = overrulingDataSourceFile ?? dataSourceFile
            guard let filePath = Bundle.main.path(forResource: overruledDataSourceFile + "." + fileSubType,
                                                  ofType: fileType) else {
                fatalError("""
                           Internal file \(overruledDataSourceFile + "." + fileSubType + "." + fileType) \
                           not found. Check file name.
                           """)
            }
            let data = self.getData( // get the data from one of the two sources
                fileURL: URL(string: dataSourcePath + dataSourceFile + "." +
                             fileSubType + "." + fileType)!,
                filePath: filePath,
                useOnlyFile: useOnlyFile
            )
            self.readRootLevel0Json(bgContext: bgContext,
                                    jsonData: data)
        }

    }

    // try to fetch the online root.level0.json file, and if that fails use a copy from the app's bundle instead
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
        fatalError("Cannot load Level 0 file \(filePath)")
    }

    fileprivate func readRootLevel0Json(bgContext: NSManagedObjectContext,
                                        jsonData: String) {

        ifDebugPrint("\nWill read Level 0 file (\(dataSourceFile)) with standard keywords and languages in background.")

        // hand the data to SwiftyJSON to parse
        let jsonRoot = JSON(parseJSON: jsonData) // get entire JSON file

        let jsonKeywords: [JSON] = jsonRoot["keywords"].arrayValue

        for jsonKeyword in jsonKeywords {
            guard jsonKeyword["idString"].exists() else {
                ifDebugFatalError("Keyword doesn't have an idString", file: #file, line: #line)
                continue  // if it doesn't exist, skip the keyword
            }
            let idString = jsonKeyword["idString"].stringValue

            guard jsonKeyword["name"].exists() else {
                ifDebugFatalError("Keyword doesn't have localized representations", file: #file, line: #line)
                continue  // if it doesn't exist, skip the keyword
            }
            let jsonName = jsonKeyword["name"].arrayValue // entire dictionary of localized names for the keyword

            // we insist on having at least one language for which jsonKeyword has a localized name
            guard jsonName.count > 0, jsonName[0]["language"].exists(), jsonName[0]["localizedString"].exists() else {
                ifDebugFatalError("Keyword doesn't have any localized representations", file: #file, line: #line)
                continue  // if it doesn't exist, skip the keyword (note that it even skips the "usage" array)
            }

            let jsonKeywordOptionals = jsonKeyword["optional"] // rest will be empty if not found
            let jsonUsage = jsonKeywordOptionals["usage"].arrayValue

            _ = Keyword.findCreateUpdateStandard(context: bgContext, id: idString, name: jsonName, usage: jsonUsage)
        }
        print("\(jsonKeywords.count) Keywords found")

        do { // saving may not be necessary because every organization is saved separately
            if bgContext.hasChanges { // optimization recommended by Apple
                try bgContext.save() // persist contents of entire root.Level1.json file
            }
        } catch {
            ifDebugFatalError("Failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
            ifDebugPrint("Failed to save JSON Keyword changes in background")
            return
        }

        ifDebugPrint("Completed readRootLevel0Json() in background")
    }

}
