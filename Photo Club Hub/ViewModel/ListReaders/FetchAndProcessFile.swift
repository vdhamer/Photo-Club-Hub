//
//  SomeJsonReader.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 17/05/2025.
//

import CoreData // for NSManagedObjectContext

struct FetchAndProcessFile {

    private static let dataSourcePath: String = """
                                                https://raw.githubusercontent.com/\
                                                vdhamer/Photo-Club-Hub/\
                                                main/JSON/
                                                """

    init(bgContext: NSManagedObjectContext,
         fileSelector: FileSelector,
         fileType: String, fileSubType: String,
         useOnlyInBundleFile: Bool,
         isBeingTested: Bool,
         fileContentProcessor: @Sendable @escaping (_ bgContext: NSManagedObjectContext,
                                                    _ jsonData: String,
                                                    _ selectFile: FileSelector,
                                                    _ isBeingTested: Bool) -> Void) {
        bgContext.perform { [self] in // run on requested background thread
            let nameWithSubtype = (fileSelector.fileName) + "." + fileSubType // e.g. "root.level0"

            let bundle: Bundle = Bundle.main // There is a fancier version of this in Photo Club Hub Data package
            let fileInBundleURL: URL? = bundle.url(forResource: nameWithSubtype, withExtension: fileType)
            guard fileInBundleURL != nil else {
                fatalError("""
                           Failed to find URL to the file \
                           \(fileSelector.fileName).\(fileSubType).\(fileType) because fileInBundleURL is nil.
                           """)
            }

            let fileName = fileSelector.fileName
            let data = getData( // get the data from one of the two sources
                remoteFileURL: URL(string: Self.dataSourcePath + fileName // e.g., "fgDeGender" or "root"
                                   + "." + fileSubType // ".level2" or ".level1"
                                   + "." + fileType)!, // ".json"
                fileInBundleURL: fileInBundleURL!, // forced unwrap is safe (due to guard statement above)
                useOnlyInBundleFile: useOnlyInBundleFile
            )
            fileContentProcessor(bgContext, data, fileSelector, isBeingTested)
        }
    }

    // try to fetch the online root.level0.json file, and if that fails fetch it from one of the app's bundles instead
    fileprivate func getData(remoteFileURL: URL,
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
        fatalError("Cannot load Level 0 file \(remoteFileURL.relativeString)")
    }

}
