//
//  LocalizedExpertiseResultList.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/06/2025.
//

import Foundation // for Bundle

public struct LocalizedExpertiseResultList {

    public init(isSupported: Bool, list: [LocalizedExpertiseResult]) {
        self.isSupported = isSupported
        self.list = list
    }

    public let isSupported: Bool
    public var list: [LocalizedExpertiseResult]

    public var icon: String {
        if isSupported {
            return String(localized: "🏵️", // mapping is to translate Unicode to escape codes for robustness
                          table: "PhotoClubHubData",
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Expertise icon when expertise is supported")
        } else {
            return String(localized: "🪲",
                          table: "PhotoClubHubData",
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Expertise icon when expertise is not supported aka temporary")
        }
    }

}
