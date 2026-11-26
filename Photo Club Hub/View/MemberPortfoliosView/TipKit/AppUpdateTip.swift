//
//  AppUpdateTip.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 25/11/2026.
//

import TipKit // for Tip, MaxDisplayCount
import UIKit  // for UIApplication

/// Tip at the top of the Clubs tab asking the user to update the app, because the club data needs a newer one (#899).
///
/// A Level 1 file can name in its header the oldest Photo Club Hub Data version that reads it as intended
/// (`minimumDataPackageVersion`, Data#107). When the Data package inside this build is older, the file still loads,
/// and Data reports the request in `LevelLoader.newerPackageRequest`, which `ClubLoadCoordinator` copies into
/// `dataNeedsNewerApp` after each load pass. The first planned use: once the club data moves to a new layout in 3.0.7
/// (Data#106), apps 3.0.5 and 3.0.6 keep reading the old files, which are then frozen and carry such
/// an app update request.
///
/// The tip is a hint, and does not block the user: the app keeps working with the data it has.
///
/// No check that this device can install the update: the device already runs this version, so it can install any
/// version with the same deployment target. The release checklist (#896) keeps the data from asking for
/// an app version that dropped support for an iOS version that the asking apps still run on.
struct AppUpdateTip: Tip {

    /// Set by `ClubLoadCoordinator` after each load pass. Transient, so a launch whose data no longer asks for a newer
    /// app never shows the tip from a stale value.
    /// Note: no trailing comment allowed on the next line. See `TabNavigationTip.isInvalidated`.
    @Parameter(.transient)
    static var dataNeedsNewerApp: Bool = false

    /// Set by `RootView` once the splash screen (Prelude) is gone. The Clubs tab sits underneath the splash, and TipKit
    /// counts a tip as shown there even while the splash covers it: without this, launches where the user lingers on
    /// the splash would use up the `MaxDisplayCount` unseen.
    /// Note: no trailing comment allowed on the next line. See `TabNavigationTip.isInvalidated`.
    @Parameter(.transient)
    static var isPreludeGone: Bool = false

    /// TipKit stores what it knows about a tip (times shown, closed with ✕) under its id, so a new id is a fresh tip.
    /// The id names the app version and the calendar month: a later release that is still too old for the data asks
    /// again, and so does this version every month, for a user who hasn't updated yet. A ✕ lasts until the next month.
    var id: String {
        Self.id(appVersion: Bundle.main.shortVersion, date: .now) // such as "AppUpdateTip-3.0.5-2026-12"
    }

    /// The id for `appVersion` during the month that contains `date`, such as "AppUpdateTip-3.0.5-2026-12".
    /// Uses the Gregorian calendar whatever the user's own, so that the id does not depend on a setting.
    static func id(appVersion: String, date: Date) -> String {
        let month = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: date)
        return String(format: "AppUpdateTip-%@-%04d-%02d", appVersion, month.year ?? 0, month.month ?? 0)
    }

    var title: Text {
        Text("Please update the app",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of the tip on the Clubs tab, shown when the club data needs a newer version of the app")
    }

    /// Worded so as not to promise a tip like this for every new version: it appears only when the data needs one.
    var message: Text? {
        Text("""
             A newer version of Photo Club Hub is available. \
             That version includes a change that lets the app show the most recent online data. \
             You can install the latest version via the App Store.
             """,
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of the tip on the Clubs tab, shown when the club data asks for a newer app version")
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.down") // a download icon chosen from SF Symbols
    }

    /// The tip shows only while the last load pass found data asking for a newer app, and the splash screen is gone.
    /// TipKit requires all rules to hold; see `LocationDeniedTip.rules`.
    var rules: [Rule] {
        #Rule(Self.$dataNeedsNewerApp) { $0 == true }
        #Rule(Self.$isPreludeGone) { $0 == true }
    }

    /// iOS draws each action as a full-width button in the tint color; `MemberPortfolioView` tints this tip orange.
    var actions: [Action] {
        Action(perform: Self.openAppStore) {
            Text("Open App Store",
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "Button in the tip on the Clubs tab that opens the app's page in the App Store")
        }
    }

    var options: [any TipOption] {
        MaxDisplayCount(3) // per app version and month, thanks to `id`
        // Not held back by the app's one-tip-per-day limit (`Tips.configure`), which the Clubs tab's other tips may
        // already have used up that day.
        IgnoresDisplayFrequency(true)
    }

    /// Opens the app's page in the App Store. Without a country in the URL, the App Store opens the user's own
    /// storefront.
    @MainActor
    private static func openAppStore() {
        guard let url = URL(string: "https://apps.apple.com/app/id1178324330") else { return }
        UIApplication.shared.open(url)
    }

}

extension View {

    /// Draws a tip's icon in the primary color (black, or white in Dark Mode) even when the tip has a tint, as
    /// `AppUpdateTip` has for its button. iOS 17 has no `tipImageStyle`, so there the icon takes the tint's color.
    @ViewBuilder
    func primaryTipImage() -> some View {
        if #available(iOS 18.0, *) {
            tipImageStyle(Color.primary)
        } else {
            self
        }
    }

}
