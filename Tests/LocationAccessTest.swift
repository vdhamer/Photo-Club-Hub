//
//  LocationAccessTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 11/11/2026.
//

import Testing
import CoreLocation // for CLAuthorizationStatus
@testable import Photo_Club_Hub

// The Maps tab hides the location button, which otherwise spins forever, when the app may not use the location,
// and shows a tip only when the user can fix that on the app's own page in iOS Settings (#889).
// These tests cover how iOS's answers become a `LocationAccess`, and what each value shows.
// The live CoreLocation calls are not testable here; they are checked in the Simulator.
@Suite("Location access decides the location button and the tip")
struct LocationAccessTests {

    // MARK: - What each value shows

    @Test("Only allowed and not-yet-asked keep the location button", arguments: [
        (LocationAccess.notDetermined, true),
        (.allowed, true),
        (.denied, false),
        (.deniedGlobally, false),
        (.restricted, false)
    ])
    func showsLocationButton(access: LocationAccess, expected: Bool) {
        #expect(access.showsLocationButton == expected)
    }

    @Test("Only a user who denied this app gets the tip", arguments: [
        (LocationAccess.notDetermined, false),
        (.allowed, false),
        (.denied, true),
        (.deniedGlobally, false), // the app's page in iOS Settings has no switch then
        (.restricted, false) // the user cannot change it
    ])
    func showsLocationDeniedTip(access: LocationAccess, expected: Bool) {
        #expect(access.showsLocationDeniedTip == expected)
    }

    // MARK: - iOS 18 and later: diagnostics of a CLLocationUpdate

    /// Shorthand for the iOS 18 initializer; every flag is off unless named.
    private func fromDiagnostics(restricted: Bool = false,
                                 deniedGlobally: Bool = false,
                                 denied: Bool = false,
                                 requestInProgress: Bool = false) -> LocationAccess {
        LocationAccess(authorizationRestricted: restricted,
                       authorizationDeniedGlobally: deniedGlobally,
                       authorizationDenied: denied,
                       authorizationRequestInProgress: requestInProgress)
    }

    @Test("An update without diagnostics means access is allowed")
    func noDiagnosticsIsAllowed() {
        #expect(fromDiagnostics() == .allowed)
    }

    @Test("A question on screen means not determined yet")
    func requestInProgressIsNotDetermined() {
        #expect(fromDiagnostics(requestInProgress: true) == .notDetermined)
    }

    @Test("Denied for this app")
    func deniedIsDenied() {
        #expect(fromDiagnostics(denied: true) == .denied)
    }

    @Test("Location Services off for the device wins over denied for the app")
    func deniedGloballyWinsOverDenied() {
        #expect(fromDiagnostics(deniedGlobally: true) == .deniedGlobally)
        #expect(fromDiagnostics(deniedGlobally: true, denied: true) == .deniedGlobally)
    }

    @Test("Restricted wins over everything else")
    func restrictedWins() {
        #expect(fromDiagnostics(restricted: true) == .restricted)
        #expect(fromDiagnostics(restricted: true, deniedGlobally: true, denied: true, requestInProgress: true)
                == .restricted)
    }

    // MARK: - iOS 17: CLLocationManager's authorization status

    @Test("With Location Services on, the app's own status decides", arguments: [
        (CLAuthorizationStatus.notDetermined, LocationAccess.notDetermined),
        (.authorizedWhenInUse, .allowed),
        (.authorizedAlways, .allowed),
        (.denied, .denied),
        (.restricted, .restricted)
    ])
    func statusWithServicesOn(status: CLAuthorizationStatus, expected: LocationAccess) {
        #expect(LocationAccess(status: status, servicesEnabled: true) == expected)
    }

    @Test("With Location Services off, only restricted keeps its own value", arguments: [
        (CLAuthorizationStatus.notDetermined, LocationAccess.deniedGlobally),
        (.authorizedWhenInUse, .deniedGlobally),
        (.authorizedAlways, .deniedGlobally),
        (.denied, .deniedGlobally), // what iOS actually reports when Location Services are off
        (.restricted, .restricted)
    ])
    func statusWithServicesOff(status: CLAuthorizationStatus, expected: LocationAccess) {
        #expect(LocationAccess(status: status, servicesEnabled: false) == expected)
    }

}
