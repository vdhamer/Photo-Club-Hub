//
//  Level1JsonReader+Include.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 06/01/2026.
//

import CoreData        // for NSManagedObjectContext
import SwiftyJSON      // for JSON struct
import Synchronization // for Mutex (only used on iOS 18 or above)

extension Level1JsonReader {

    @available(iOS 18, macOS 15, *)
    static let level1History = Level1History() // singleton to track Level 1 loading across all Level 1 reader threads

    /// Extracts and validates the file names listed in the `level1URLIncludes` array in the Header
    /// of a level1.json file. Pure parsing — no loading happens here. The split between extraction
    /// and loading exists because this runs inside the parent's synchronous `perform` block, where
    /// the concurrent include fan-out cannot be awaited (issue #760); `loadIncludes` does that part.
    ///
    /// If the app has been built in Debug mode, an entry that isn't a valid URL emits a debug fatal error.
    /// If the app has been built in Release mode, invalid URL → array element is silently ignored.
    ///
    /// - Parameter jsonRoot: The parsed SwiftyJSON root object that holds the content of a Level 1 JSON file.
    /// - Returns: The base names of the files to include (e.g. ["clubsNL", "museums"]).
    @Sendable static func extractIncludeNames(from jsonRoot: JSON) -> [String] {
        let includeJSONs: [JSON] = jsonRoot["level1Header"]["level1URLIncludes"].arrayValue
        var includeNames: [String] = []

        for includeJSON in includeJSONs {
            let includeURLoptional: URL? = URL(string: includeJSON.stringValue)
            guard let includeURL: URL = includeURLoptional else {
                ifDebugFatalError("Included level1URL <\(includeJSON.stringValue)> is not a valid URL")
                continue
            }
            let includeNameSegments: [Substring] = includeURL.lastPathComponent.split(separator: ".")
            guard includeNameSegments.isEmpty == false else {
                ifDebugFatalError("level1URLIncludes contains an empty string")
                continue
            } // if it is an empty string, just ignore
            guard includeNameSegments.count >= 3, // avoid index-out-of-bounds on e.g. "museums.json"
                  includeNameSegments[1].lowercased() == "level1",
                  includeNameSegments[2].lowercased() == "json" else {
                ifDebugFatalError("level1URLInclude does not end with level1.json")
                continue
            }
            includeNames.append(String(includeNameSegments[0])) // the guards ensure there must be an element [0]
        }
        return includeNames
    }

    /// Concurrently loads the given `Include`d files, each on its own new background context of
    /// `usedContainer`, and suspends until ALL of them — recursively including their own Includes —
    /// have finished. This __task group__ is the structured replacement for the old fire-and-forget
    /// recursion (issue #760): it keeps the includes loading concurrently AND gives `load(...)` a
    /// join point, so "a file's load isn't done until all its spawned child Includes are done".
    static func loadIncludes(_ includeNames: [String],
                             isBeingTested: Bool,
                             useOnlyInBundleFile: Bool,
                             includeFilePath: [String], // used to detect loops for error checking
                             /// Tests can inject a private in-memory store for isolation,
                             /// particularly to ensure all included files use the same Core Data store/database.
                             usedContainer: NSPersistentContainer) async {
        guard includeNames.isEmpty == false else { return }

        // NSPersistentContainer is Sendable (unlike NSManagedObjectContext), so the @Sendable
        // child-task closures may capture it directly; creating background contexts is thread-safe.
        // "A [task] group always waits for all of its child tasks to complete before it returns."
        await withDiscardingTaskGroup { group in // discarding: child tasks return no results
            for includeName in includeNames {
                group.addTask {
                    print("Will load included file \(includeName).level1.json on a new background task")

                    let bgContext = usedContainer.newBackgroundContext()
                    bgContext.name = "Level 1 loader for \(includeName)"
                    if inDebugMode && Settings.errorOnCoreDataMerge {
                        bgContext.mergePolicy = NSMergePolicy.error // to force detection of Core Data merge issues
                    } else {
                        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                        // ^ .mergeByPropertyObjectTrump better?
                    }
                    bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?

                    await Level1JsonReader.load( // recursively traverse Include tree
                        bgContext: bgContext,
                        fileName: includeName,
                        isBeingTested: isBeingTested,
                        useOnlyInBundleFile: useOnlyInBundleFile,
                        includeFilePath: includeFilePath,
                        usedContainer: usedContainer) // propagate so whole Include tree shares one storage container
                }
            }
        }
    }

}

@available(iOS 18, macOS 15, *)
final public class Level1History: Sendable {

    // https://www.avanderlee.com/concurrency/modern-swift-lock-mutex-the-synchronization-framework/
    // A Set suffices because we only need membership (not order): Set.insert reports whether the
    // element was already present, collapsing the old contains()/append() into one operation.
    private let level1History = Mutex<Set<String>>([])

    func isVisitedBefore(fileName: String) -> Bool {
        level1History.withLock { level1History in
            !level1History.insert(fileName).inserted // false the first time, true on later calls
        }
    }

    public func clear() {
        level1History.withLock { level1History in
            level1History.removeAll()
        }

    }

}
