//
//  FetchAndProcessFile.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 17/05/2025.
//

import CoreData // for NSManagedObjectContext

/// Retrieves a data file from a remote source with a local bundle fallback and
/// forwards the raw text to a caller-supplied processor (to allow reuse for Level 0, 1, and 2).
///
/// The remote path is constructed from a base GitHub URL (`dataSourcePath`) and a
/// composed filename like `root.level1.json`. The fetch first attempts to read from
/// the network (unless `useOnlyInBundleFile` is true); if that fails, it falls back
/// to a resource embedded in the app bundle.
///
/// All work is scheduled on the provided Core Data background context via
/// `bgContext.perform { ... }`, so the `fileContentProcessor` closure is invoked on
/// that background queue.
struct FetchAndProcessFile {

    /// Base URL for remote data files hosted on GitHub raw content. The final remote
    /// URL is built as `dataSourcePath + fileName + "." + fileSubType + "." + fileType`,
    /// for example: `.../JSON/root.level1.json`.
    private static let dataSourcePath: String = """
                                                https://raw.githubusercontent.com/\
                                                vdhamer/Photo-Club-Hub/\
                                                main/JSON/
                                                """

    /// Creates a fetcher that loads a data file (remote with fallback to bundle) and
    /// passes its textual contents to `fileContentProcessor` on the background context.
    ///
    /// - Parameters:
    ///   - bgContext: Background `NSManagedObjectContext` on which the work is scheduled.
    ///   - fileSelector: Describes the logical file; `fileName` is used to compose the name.
    ///   - fileType: File extension to load (e.g., "json").
    ///   - fileSubType: Additional name component between base and extension (e.g., "level1").
    ///   - useOnlyInBundleFile: If true, skips the remote fetch and only reads from the bundle.
    ///   - isBeingTested: Flag forwarded to the processor to adjust behavior during tests.
    ///   - includeFilePath: level1.json files can include other level1.json files. Use to detect dependency loops.
    ///   - fileContentProcessor: Closure receiving `(bgContext, jsonData, fileSelector, ...)`.
    ///
    /// The initializer constructs the filename as `fileSelector.fileName + "." + fileSubType`,
    /// verifies the bundle resource exists, attempts to read from the remote URL unless
    /// `useOnlyInBundleFile` is true, then invokes `fileContentProcessor` with the loaded text.
    init(bgContext: NSManagedObjectContext,
         fileSelector: FileSelector,
         fileType: String, fileSubType: String,
         useOnlyInBundleFile: Bool,
         isBeingTested: Bool,
         includeFilePath: [String],
         fileContentProcessor: @Sendable @escaping (_ bgContext: NSManagedObjectContext,
                                                    _ jsonData: String,
                                                    _ selectFile: FileSelector,
                                                    _ useOnlyInBundleFile: Bool,
                                                    _ isBeingTested: Bool,
                                                    _ includeFilePath: [String]) -> Void) {
        bgContext.perform { [self] in // run on requested background thread
            let nameWithSubtype = (fileSelector.fileName) + "." + fileSubType // e.g. "root.level1"

            // The same source is shared by Photo Club Hub (where this compiles into the app target, so the
            // JSON sits directly in Bundle.main and Bundle.module does not exist) and Photo Club Hub HTML
            // (where this compiles into the Photo Club Hub Data SwiftPM package, so the JSON sits in a nested
            // `<Package>_<Target>.bundle`). Resolve at runtime across both layouts so both repos use the same code.
            let fileInBundleURL: URL? = Self.urlForBundledResource(nameWithSubtype, withExtension: fileType)

            guard fileInBundleURL != nil else {
                ifDebugFatalError("""
                                  Failed to find internal URL for \
                                  \(fileSelector.fileName).\(fileSubType).\(fileType). \
                                  Might be a filename or branch problem.
                                  """)
                print("ERROR: Couldn't load \(nameWithSubtype).\(fileType) from bundle.")
                return
            }

            let fileName = fileSelector.fileName
            let data = getData( // get the data from one of the two sources
                remoteFileURL: URL(string: Self.dataSourcePath + fileName // e.g., "fgDeGender" or "root"
                                   + "." + fileSubType // e.g., ".level0" or ".level1" or ".level2"
                                   + "." + fileType)!, // ".json"
                fileInBundleURL: fileInBundleURL!, // forced unwrap is safe (due to guard statement above)
                useOnlyInBundleFile: useOnlyInBundleFile
            )
            fileContentProcessor(bgContext, data, fileSelector, useOnlyInBundleFile, isBeingTested, includeFilePath)
        }
    }

    /// Locates a bundled resource regardless of whether it was packaged directly into the main
    /// bundle (app target) or into a nested/sibling SwiftPM resource bundle (package target).
    ///
    /// Search order:
    /// 1. `Bundle.main` itself — the Photo Club Hub app target adds the JSON files as app resources.
    /// 2. Any `*.bundle` nested inside `Bundle.main` — the Photo Club Hub HTML build embeds the
    ///    package's generated `Photo Club Hub Data_Photo Club Hub Data.bundle` here.
    /// 3. Any `*.bundle` sibling of `Bundle.main` — covers the separate test resource bundle when
    ///    running unit tests via SwiftPM.
    ///
    /// Returning the first match keeps a single source compatible with both repos without `#if`.
    private static func urlForBundledResource(_ name: String, // root.level0
                                              withExtension ext: String) -> URL? { // json as real extension
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url // Search oder #1
        }

        let searchDirs = [Bundle.main.resourceURL, // "../Build/Products/Debug/Photo%20Club%20Hub%20HTML.app"
                          Bundle.main.bundleURL.deletingLastPathComponent()]
                         .compactMap { $0 } // ..Build/Products/Debug"
        for dir in searchDirs {
            guard let entries = try? FileManager.default.contentsOfDirectory( at: dir,
                                                                              includingPropertiesForKeys: nil)
                else { continue }

            for entry in entries where entry.pathExtension == "bundle" {
                if let bundle = Bundle(url: entry),
                   let url = bundle.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
        }
        return nil
    }

    /// Attempts to read the file from the remote URL (unless `useOnlyInBundleFile` is true),
    /// falling back to the bundled resource if the network read fails.
    ///
    /// - Parameters:
    ///   - remoteFileURL: Fully constructed URL of the remote file (e.g., GitHub raw).
    ///   - fileInBundleURL: URL of the resource embedded in the app bundle.
    ///   - useOnlyInBundleFile: When true, bypasses the remote read and uses the bundle file.
    /// - Returns: The file contents as a UTF-8 `String`.
    /// - Note: If neither source can be read, the method terminates with `fatalError`.
    private func getData(remoteFileURL: URL,
                         fileInBundleURL: URL,
                         useOnlyInBundleFile: Bool) -> String {
        if let urlData = try? String(contentsOf: remoteFileURL, encoding: .utf8), !useOnlyInBundleFile {
            return urlData
        }
        print("Could not access online file \(remoteFileURL.relativeString). Trying in-app file instead.")

        if let bundleFileData = try? String(contentsOf: fileInBundleURL, encoding: .utf8) {
            return bundleFileData
        }
        // calling fatalError is ok for a compile-time constant (as defined above)
        fatalError("Cannot load JSON file \(remoteFileURL.relativeString)")
    }

}
