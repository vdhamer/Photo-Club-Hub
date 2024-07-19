//
//  LocationManager.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/11/2023.
//

import CoreLocation
import UIKit

@MainActor
@Observable
class LocationManager {
    var location: CLLocation?

    private let locationManager = CLLocationManager()

    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }

    func startCurrentLocationUpdates() async throws {
        for try await update in CLLocationUpdate.liveUpdates(.otherNavigation) { // doesn't need to stick to the roads
            if let location = update.location {
                self.location = location
            } else {
                if UIDevice.isIPhone { // avoid warning on iPad: it doesn't have GPS
                    ifDebugPrint("Core Location live update failed")
                }
            }
        }
    }
}
