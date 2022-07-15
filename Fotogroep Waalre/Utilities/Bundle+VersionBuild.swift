//
//  Bundle+VersionBuild.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/05/2022.
//

import Foundation

extension Bundle {

    var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    var fullVersion: String {
        return "\(shortVersion) (\(buildVersion))"
    }
}
