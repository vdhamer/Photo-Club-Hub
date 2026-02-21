//
//  SomeJsonReader.swift
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
        bgContext.perform { [self] in // run (both fetching and processing) on requested background thread
            let nameWithSubtype: String = (fileSelector.fileName) + "." + fileSubType // e.g. "root.level1"

            let bundle: Bundle = Bundle.main // There is a fancier version of this in Photo Club Hub Data package
            let fileInBundleURL: URL? = bundle.url(forResource: nameWithSubtype, withExtension: fileType)

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
                fileInBundleURL: fileInBundleURL!, // forced unwrap is safe due to guard above
                useOnlyInBundleFile: useOnlyInBundleFile
            )
            fileContentProcessor(bgContext, data, fileSelector, useOnlyInBundleFile, isBeingTested, includeFilePath)
        }
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
