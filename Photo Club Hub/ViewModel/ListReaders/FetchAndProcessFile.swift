//
//  FetchAndProcessFile.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 17/05/2025.
//

import CoreData // for NSManagedObjectContext

/// Groups the file-description + fetch-behavior parameters shared by every FetchAndProcessFile
/// entry point (issue #760 left these as a 5-way parameter spread across three signatures).
struct FileFetchOptions: Sendable {
    let fileType: String          // file extension to load, e.g. "json"
    let fileSubType: String       // name component between base and extension, e.g. "level1"
    let useOnlyInBundleFile: Bool // if true, skip the remote fetch and only read from the bundle
    let isBeingTested: Bool       // forwarded to the processor to adjust behavior during tests
    let includeFilePath: [String] // recursion path like ["root","museums"]; used to detect loops
}

/// Retrieves a data file from a remote source with a local bundle fallback and
/// forwards the raw text to a caller-supplied processor (to allow reuse for Level 0, 1, and 2).
///
/// The remote path is constructed from a base GitHub URL (`dataSourcePath`) and a
/// composed filename like `root.level1.json`. The fetch first attempts to read from
/// the network (unless `fileFetchOptions.useOnlyInBundleFile` is true); if that fails,
/// it falls back to a resource embedded in the app bundle.
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
    ///   - fileFetchOptions: File type, subtype, and fetch-behavior flags (see `FileFetchOptions`).
    ///   - fileContentProcessor: Closure receiving `(bgContext, jsonData, fileSelector, ...)`.
    ///
    /// The initializer constructs the filename as `fileSelector.fileName + "." + fileFetchOptions.fileSubType`,
    /// verifies the bundle resource exists, attempts to read from the remote URL unless
    /// `fileFetchOptions.useOnlyInBundleFile` is true, then invokes `fileContentProcessor` with the loaded text.
    ///
    /// This is the fire-and-forget path: it schedules the work and returns immediately.
    /// For an awaitable variant see `fetchAndProcess(...) async` below (issue #760).
    init(bgContext: NSManagedObjectContext,
         fileSelector: FileSelector,
         fileFetchOptions: FileFetchOptions,
         fileContentProcessor: @Sendable @escaping (_ bgContext: NSManagedObjectContext,
                                                    _ jsonData: String,
                                                    _ selectFile: FileSelector,
                                                    _ useOnlyInBundleFile: Bool,
                                                    _ isBeingTested: Bool,
                                                    _ includeFilePath: [String]) -> Void) {
        bgContext.perform { // run on requested background thread; closure form returns immediately
            _ = Self.fetchAndProcess(bgContext: bgContext,
                                     fileSelector: fileSelector,
                                     fileFetchOptions: fileFetchOptions,
                                     fileContentProcessor: fileContentProcessor)
        }
    }

    /// Awaitable variant of `init` (issue #760). Runs the same fetch-and-process work via the async
    /// `bgContext.perform { }` overload, so the caller suspends until the block — including the
    /// `fileContentProcessor` call — has completed on the context's queue.
    ///
    /// - Returns: The value produced by `fileContentProcessor` (e.g. a list of included file names
    ///   for Level 1), or nil if the bundle resource could not be found.
    static func fetchAndProcess<Result: Sendable>(
        bgContext: NSManagedObjectContext,
        fileSelector: FileSelector,
        fileFetchOptions: FileFetchOptions,
        fileContentProcessor: @Sendable @escaping (_ bgContext: NSManagedObjectContext,
                                                   _ jsonData: String,
                                                   _ selectFile: FileSelector,
                                                   _ useOnlyInBundleFile: Bool,
                                                   _ isBeingTested: Bool,
                                                   _ includeFilePath: [String]) -> Result) async -> Result? {
        await bgContext.perform { // async overload: suspends until the block completes
            Self.fetchAndProcess(bgContext: bgContext,
                                 fileSelector: fileSelector,
                                 fileFetchOptions: fileFetchOptions,
                                 fileContentProcessor: fileContentProcessor)
        }
    }

    /// Shared core of both paths above. Must be called on `bgContext`'s queue (i.e. from within
    /// a `perform` block). Returns `fileContentProcessor`'s result, or nil if the bundle resource could not be found.
    /// Returning nil emits a fatalError when in Debug mode, to ensure getting developer attention.
    private static func fetchAndProcess<Result>(
        bgContext: NSManagedObjectContext,
        fileSelector: FileSelector,
        fileFetchOptions: FileFetchOptions,
        fileContentProcessor: (_ bgContext: NSManagedObjectContext,
                               _ jsonData: String,
                               _ selectFile: FileSelector,
                               _ useOnlyInBundleFile: Bool,
                               _ isBeingTested: Bool,
                               _ includeFilePath: [String]) -> Result) -> Result? {

        let fileType = fileFetchOptions.fileType
        let fileSubType = fileFetchOptions.fileSubType // e.g. "level1"
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
            return nil
        }

        let fileName = fileSelector.fileName
        let data = getData( // get the data from one of the two sources
            remoteFileURL: URL(string: Self.dataSourcePath + fileName // e.g., "fgDeGender" or "root"
                               + "." + fileSubType // e.g., ".level0" or ".level1" or ".level2"
                               + "." + fileType)!, // ".json"
            fileInBundleURL: fileInBundleURL!, // forced unwrap is safe (due to guard statement above)
            useOnlyInBundleFile: fileFetchOptions.useOnlyInBundleFile
        )
        return fileContentProcessor(bgContext, data, fileSelector,
                                    fileFetchOptions.useOnlyInBundleFile,
                                    fileFetchOptions.isBeingTested,
                                    fileFetchOptions.includeFilePath)

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
    /// 4. The hosted unit-test `*.xctest` bundle in `Bundle.main`'s PlugIns — covers test-only
    ///    JSON files (e.g. IncludeParent/IncludeChild.level1.json) that are members of the test
    ///    target rather than the app target, so they aren't shipped in the production app.
    ///
    /// Returning the first match keeps a single source compatible with both repos without `#if`.
    private static func urlForBundledResource(_ name: String, // root.level0
                                              withExtension ext: String) -> URL? { // json as real extension
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url // Search oder #1
        }

        let searchDirs = [Bundle.main.resourceURL, // "../Build/Products/Debug/Photo%20Club%20Hub%20HTML.app"
                          Bundle.main.bundleURL.deletingLastPathComponent(), // ..Build/Products/Debug"
                          Bundle.main.builtInPlugInsURL] // "../Photo Club Hub.app/PlugIns" (hosted tests)
                         .compactMap { $0 }
        for dir in searchDirs {
            guard let entries = try? FileManager.default.contentsOfDirectory( at: dir,
                                                                              includingPropertiesForKeys: nil)
                else { continue }

            // *.bundle: SwiftPM resource bundle. *.xctest: hosted unit-test bundle (see search order #4).
            for entry in entries where entry.pathExtension == "bundle" || entry.pathExtension == "xctest" {
                if let bundle = Bundle(url: entry),
                   let url = bundle.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
        }
        return nil
    }

    /// Attempts to read the file from the remote URL (unless `useOnlyInBundleFile` is true),
    /// and falling back to the bundled resource if the network read fails.
    ///
    /// - Parameters:
    ///   - remoteFileURL: Fully constructed URL of the remote file (e.g., GitHub raw).
    ///   - fileInBundleURL: URL of the resource embedded in the app bundle.
    ///   - useOnlyInBundleFile: When true, bypasses the remote read and uses the bundle file.
    /// - Returns: The file contents as a UTF-8 `String`.
    /// - Note: If neither source can be read, the method terminates with a true `fatalError` (also in non-debug mode).
    private static func getData(remoteFileURL: URL,
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
