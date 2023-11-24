//
//  LocationManager.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 24/11/2023.
//

import Foundation
import CoreLocation

@Observable
class LocationManager {
    var location: CLLocation?

    private let locationManager = CLLocationManager()

    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }

    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }

            self.location = location
        }
    }
}
