//
//  LocationDeniedTip.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 11/11/2026.
//

import TipKit   // for Tip, MaxDisplayCount
import UIKit    // for UIApplication.openSettingsURLString

/// Tip shown at the top of the Maps tab while the user has denied this app the use of the location (#889).
///
/// iOS asks for location access only once, so a single "Don't Allow" leaves the maps without the user's position for
/// as long as the app is installed. The tip says why, and its button opens the app's own page in the Settings app.
/// It is inline rather than a popover, because the location button it would point at is hidden then.
/// Not shown when Location Services are off for the whole device, or when access is restricted: see
/// `LocationAccess.showsLocationDeniedTip`.
struct LocationDeniedTip: Tip {

    /// Set by `LocationManager` whenever the location access changes. Transient: not stored between launches, so a
    /// user who allowed access in Settings while the app was not running never sees the tip from a stale value.
    /// Note: no trailing comment allowed on the next line, see `TabNavigationTip.isInvalidated`.
    @Parameter(.transient)
    static var isLocationDenied: Bool = false

    var title: Text {
        Text("Your location is off",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of the tip on the Maps tab, shown when the user denied this app the use of the location")
    }

    var message: Text? {
        Text("Location_denied_key", // underscores to make sure it doesn't look like an actual display text
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of the tip on the Maps tab, shown when the user denied this app the use of the location")
    }

    var image: Image? {
        Image(systemName: "location.slash")
    }

    /// TipKit shows a tip only while all of its rules hold, and re-checks them whenever a parameter they watch changes.
    /// This single rule watches `isLocationDenied` (`$isLocationDenied` is the parameter itself; the closure gets its
    /// current value). So the tip appears as soon as `LocationManager` reports a denial, and disappears again once the
    /// user allows access in Settings. Closing the tip with its ✕ button ends it for good, whatever the rule says.
    var rules: [Rule] {
        #Rule(Self.$isLocationDenied) { $0 == true }
    }

    var actions: [Action] {
        Action(perform: Self.openAppSettings) {
            Text("Open the Settings app",
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "Button in the tip on the Maps tab that opens this app's page in the iOS Settings app")
        }
    }

    var options: [any TipOption] {
        MaxDisplayCount(2) // a user who chose "Never" on purpose is not nagged
        // Not held back by the app's one-tip-per-day limit (`Tips.configure`): after a fresh install, the Clubs tab's
        // tips use up that day's tip, and this one belongs on the very day the user answered "Don't Allow".
        IgnoresDisplayFrequency(true)
    }

    /// Opens this app's own page in the iOS Settings app, where the user can allow the use of the location.
    @MainActor
    private static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

}
