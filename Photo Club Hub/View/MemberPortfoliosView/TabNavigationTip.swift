//
//  SettingsMovedTip.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/07/2026.
//

import TipKit // for Tip, MaxDisplayCount

/// One-shot tip shown at the top of the Clubs screen after the toolbar → tabs migration (issue #763).
/// It tells existing users that the old toolbar buttons are now tabs, and that Preferences is now
/// called Settings. Shown on the Clubs screen because that screen hosted the old toolbar buttons
/// and is the tab shown at app startup.
struct TabNavigationTip: Tip {

    var title: Text {
        Text("Navigation using tabs",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of one-time tip about Preferences having moved to the Settings tab")
    }

    var message: Text? {
        Text("We switched to tabs for navigating the screens. Tabs can save a few taps. Help is available via ⓘ,",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of one-time tip about tabs replacing toolbar buttons")
    }

    var image: Image? {
        Image(systemName: "signpost.right.and.left") // matches the icon of the Settings tab
    }

    var options: [any TipOption] {
        MaxDisplayCount(1) // show only once: the system invalidates the tip after its first display
    }

}
