//
//  Placemark+Address.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 18/12/2023.
//

import CoreLocation

extension CLPlacemark { // TODO

    var address: String? {
        if let name {
            var result = name

            if let street = thoroughfare {
                result += ", \(street)"
            }

            if let city = locality {
                result += ", \(city)"
            }

            if let country = country {
                result += ", \(country)"
            }

            return country ?? "No country"
        }

        return nil
    }

}
