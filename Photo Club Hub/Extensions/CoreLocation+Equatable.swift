//
//  CoreLocation+Equatable.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/12/2022.
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0364-retroactive-conformance-warning.md

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        (lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude)
    }
}
