//
//  LocationManager.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/11/2023.
//

import CoreLocation
import UIKit
import Photo_Club_Hub_Data // for ifDebugPrint

/// Asks for location access, tracks device's location, and tracks whether the app may use the location (#889).
@MainActor
@Observable
class LocationManager {
    var location: CLLocation?

    /// Whether the app may use the location. Without access, the Maps tab hides the location button, which would
    /// otherwise spin forever (#889). Where the value comes from depends on the iOS version; the views don't care.
    private(set) var access: LocationAccess = .notDetermined

    /// iOS 18 and later: keeps the request for "While Using the App" access alive while the updates run.
    /// Typed `Any` because `CLServiceSession` does not exist on iOS 17.
    @ObservationIgnored private var serviceSession: Any?

    /// iOS 17 only: reports changes of the access. Kept for the lifetime of this object, so a change made in
    /// iOS Settings while the Maps tab was not shown is still picked up. Delete when iOS 17 support is dropped.
    @ObservationIgnored private var authorizationObserver1717: AnyObject?

    /// Asks for location access if needed, then follows the location until the calling task is cancelled.
    /// Nothing after the call runs before then.
    func startCurrentLocationUpdates() async throws {
        if #unavailable(iOS 18) {
            startAuthorizationObserver1717()
        } else {
            serviceSession = CLServiceSession(authorization: .whenInUse) // shows iOS's question if not yet answered
        }
        defer { serviceSession = nil } // ends the session when the Maps tab goes away

        for try await update in CLLocationUpdate.liveUpdates(.otherNavigation) { // doesn't need to stick to the roads
            if #available(iOS 18, *) { // iOS 17 updates carry no diagnostics: the observer reports the access there
                setAccess(LocationAccess(authorizationRestricted: update.authorizationRestricted,
                                         authorizationDeniedGlobally: update.authorizationDeniedGlobally,
                                         authorizationDenied: update.authorizationDenied,
                                         authorizationRequestInProgress: update.authorizationRequestInProgress))
            }
            if let location = update.location {
                self.location = location
            } else {
                // Without access there is never a location; that is not a failure.
                if access == .allowed && UIDevice.isIPhone { // avoid warning on iPad: it doesn't have GPS
                    ifDebugPrint("Core Location live update failed")
                }
            }
        }
    }

    /// Changes `access` only when it differs, so the views are not invalidated by every location update.
    /// Also tells the Maps tab's tip, which then appears or disappears by itself.
    private func setAccess(_ newAccess: LocationAccess) {
        if access != newAccess {
            access = newAccess
            LocationDeniedTip.isLocationDenied = newAccess.showsLocationDeniedTip
        }
    }

    /// iOS 17: creates the observer once, which reports the current access right away, and asks for access.
    @available(iOS, obsoleted: 18.0)
    private func startAuthorizationObserver1717() {
        if authorizationObserver1717 == nil {
            authorizationObserver1717 = LocationAuthorizationObserver1717 { [weak self] newAccess in
                self?.setAccess(newAccess)
            }
        }
        (authorizationObserver1717 as? LocationAuthorizationObserver1717)?.requestAuthorization()
    }

}
