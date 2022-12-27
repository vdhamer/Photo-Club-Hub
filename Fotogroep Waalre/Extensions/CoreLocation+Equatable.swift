//
//  CoreLocation+Equatable.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 28/12/2022.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        (lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude)
    }

}
