//
//  LocationManager.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 24/11/2023.
//

import Foundation
import CoreLocation

// TODO: should this be tied to the MainActor like in WWDC23 location tracking sample code??

@Observable
class LocationManager {
    var location: CLLocation?

    private let locationManager = CLLocationManager()

    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }

    func startCurrentLocationUpdates() async throws {
        for try await update in CLLocationUpdate.liveUpdates(.default   ) {
            if let location = update.location {
                self.location = location
            } else {
                print("LOCATION update failed")
                return
            }
        }
    }
}