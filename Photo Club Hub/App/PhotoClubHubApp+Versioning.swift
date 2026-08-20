//
//  PhotoClubHubApp+Versioning.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/08/2026.
//

import Foundation // for Bundle

extension PhotoClubHubApp {

    // update version numbers shown in iOS Settings
    func fetchVersioning() {
        let noStamp = String(localized: "?",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Stands in for an absent build date or commit")
        // "N/A" rather than "?" for the library commit: a local checkout or an unreadable pin means
        // there is no commit to name, which is a different thing from a stamp having gone missing.
        let notApplicable = String(localized: "N/A",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Stands in for the library commit when there is none to show")

        BuildStampKey.appVersion.set(Bundle.main.fullVersion)
        BuildStampKey.appBuildDate.set(Bundle.main.buildDate ?? noStamp)
        BuildStampKey.appGitCommit.set(Bundle.main.gitCommit ?? noStamp)
        BuildStampKey.libraryVersion.set(Bundle.main.libraryVersion ?? noStamp)
        BuildStampKey.libraryCommit.set(Bundle.main.libraryCommit ?? notApplicable)
        BuildStampKey.libraryCommitDate.set(Bundle.main.libraryCommitDate ?? notApplicable)

        BuildStampKey.removeDeprecatedKeys() // sweep the obsolete `_preference` names once (#820)
    }

}
