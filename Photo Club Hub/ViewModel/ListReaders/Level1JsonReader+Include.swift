//
//  Level1JsonReader+Include.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 06/01/2026.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON struct
import Synchronization // for Mutex (only used on iOS 18 or above)

extension Level1JsonReader {

    @available(iOS 18, macOS 15, *)
    static let level1History = Level1History() // singleton to tack Level 1 loading across all Level 1 reader threads

    /// Loads any files listed in the `level1URLIncludes` array in the Header of a level1.json file.
    ///
    /// Loading is done on a new NSManagedObjectContext.
    /// If an entry is not a valid URL, the function emits a debug fatal error if the app has been built in Debug mode.
    /// When the app is built in Release mode, invalid URL errors cause the array element to be silently ignored.
    ///
    /// - Parameter jsonRoot: The parsed SwiftyJSON root object for a Level 1 JSON file.

    @Sendable static func triggerProcessingOfLevel1URLIncludes(
        from jsonRoot: JSON,
        isBeingTested: Bool,
        useOnlyInBundleFile: Bool,
        includeFilePath: [String]
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
                useOnlyInBundleFile: useOnlyInBundleFile,
                includeFilePath: includeFilePath)
        }
    }

}

@available(iOS 18, macOS 15, *)
final public class Level1History: Sendable {

    // https://www.avanderlee.com/concurrency/modern-swift-lock-mutex-the-synchronization-framework/
    private let level1History = Mutex<[String]>([])

    func isVisited(fileName: String) -> Bool {
        level1History.withLock { level1History in
            if level1History.contains(fileName) {
                return true
            } else {
                level1History.append(fileName)
                return false
            }
        }
    }

    public func clear() {
        level1History.withLock { level1History in
            level1History.removeAll()
        }

    }

}
