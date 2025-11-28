//
//  Organization+Comparable.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/11/2025.
//

import Foundation

extension Organization: Comparable {

    public static func < (lhs: Organization, rhs: Organization) -> Bool {
        return lhs.fullName < rhs.fullName
    }

}
