//
//  LocationAuthorizationObserver1717.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 11/11/2026.
//

import CoreLocation // for CLLocationManager, CLLocationManagerDelegate

/// iOS 17 only: asks for location access and reports every change of it to `LocationManager` (#889).
///
/// On iOS 18 and later, `LocationManager` reads the same information from the diagnostics of its location updates,
/// which iOS 17 does not provide. When iOS 17 support is dropped, delete this file, its use in `LocationManager`,
/// and `LocationAccess.init(status:servicesEnabled:)`.
///
/// iOS calls the delegate on the thread that created the `CLLocationManager`: here the main thread, because this
/// object is main-actor isolated. The callback is `nonisolated` all the same, because the protocol does not promise
/// the main actor. It reads the status from its argument, never from `self.manager`, and reports back on the main
/// actor.
@available(iOS, obsoleted: 18.0)
@MainActor
final class LocationAuthorizationObserver1717: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private let onChange: @MainActor @Sendable (LocationAccess) -> Void

    /// - Parameter onChange: called with the current access soon after creation, and after every change, including
    ///   one made in iOS Settings while the app was in the background.
    init(onChange: @escaping @MainActor @Sendable (LocationAccess) -> Void) {
        self.onChange = onChange
        super.init()
        manager.delegate = self // iOS then calls locationManagerDidChangeAuthorization once with the current status
    }

    /// Shows iOS's question "Allow Photo Club Hub to use your location?" if the user has not answered it yet.
    /// Does nothing once they have: iOS asks only once.
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        let onChange = self.onChange
        // `locationServicesEnabled()` can block, and Xcode warns when it runs on the main thread.
        Task.detached {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            await onChange(LocationAccess(status: status, servicesEnabled: servicesEnabled))
        }
    }

}
