//
//  LocationAccess.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 11/11/2026.
//

import CoreLocation // for CLAuthorizationStatus
import SwiftUI      // for EnvironmentValues, @Entry

/// Whether the app is allowed to use the device's location.
/// The Maps tab needs to know this in order to control presentation of the Location button (#889).
///
/// `LocationManager` holds the current value and the views read it.
/// `LocationAccess` provides two initializer variants for different iOS versions (iOS17 and iOS18+)..
enum LocationAccess: Equatable, Sendable {
    case notDetermined   // the user has not answered the question yet
    case allowed         // "While Using the App" (or "Always")
    case denied          // "Never" for this app: the user can change it on the app's page in iOS Settings
    case deniedGlobally  // Location Services are off for the whole device
    case restricted      // parental controls or device management: the user cannot change it

    /// Whether the map shows MapKit's location button. Without access, the button would spin forever (#889).
    /// `.notDetermined` keeps it, because iOS asks the question before the button needs an answer.
    var showsLocationButton: Bool {
        self == .notDetermined || self == .allowed
    }

    /// Whether the Maps tab shows the tooltip that leads to the app's page in iOS Settings.
    /// Only for `.denied`: the app's page offers no switch for `.deniedGlobally`,
    /// and the user can't change `.restricted`.
    var showsLocationDeniedTip: Bool {
        self == .denied
    }

    /// iOS 18 and later: the access that the diagnostics of a `CLLocationUpdate` imply.
    ///
    /// The arguments are that update's properties of the same name; they are passed one by one because a
    /// `CLLocationUpdate` cannot be created in a test. An update without any of these flags means access is allowed,
    /// even without a location: the location may only be unavailable for the moment (`locationUnavailable`).
    init(authorizationRestricted: Bool,
         authorizationDeniedGlobally: Bool,
         authorizationDenied: Bool,
         authorizationRequestInProgress: Bool) {
        if authorizationRestricted {
            self = .restricted
        } else if authorizationDeniedGlobally { // checked before `authorizationDenied`, which may be set too
            self = .deniedGlobally
        } else if authorizationDenied {
            self = .denied
        } else if authorizationRequestInProgress {
            self = .notDetermined
        } else {
            self = .allowed
        }
    }

    /// iOS 17: the access that `CLLocationManager` reports. Used only by `LocationAuthorizationObserver1717`,
    /// and deleted together with it when iOS 17 support is dropped.
    ///
    /// - Parameters:
    ///   - status: `CLLocationManager.authorizationStatus`. It reads `.denied` when Location Services are off for the
    ///     whole device, so `servicesEnabled` is needed to tell the two apart.
    ///   - servicesEnabled: `CLLocationManager.locationServicesEnabled()`.
    @available(iOS, obsoleted: 18.0)
    init(status: CLAuthorizationStatus,
         servicesEnabled: Bool) {
        if status == .restricted { // the user cannot change it, whatever the device-wide switch says
            self = .restricted
        } else if !servicesEnabled {
            self = .deniedGlobally
        } else {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse: self = .allowed
            case .denied: self = .denied
            case .notDetermined: self = .notDetermined
            default: self = .notDetermined // .restricted is handled above; also any future case
            }
        }
    }

}

extension EnvironmentValues {

    /// The app's location access, set by `MapsView` from its `LocationManager`. `MapsViewMap` reads it and shows the
    /// Location button only if `showsLocationButton` is true (#889). Previews get `.notDetermined`, which shows it.
    @Entry var locationAccess: LocationAccess = .notDetermined

}
