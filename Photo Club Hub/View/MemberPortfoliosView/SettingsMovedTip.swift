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
struct SettingsMovedTip: Tip {

    var title: Text {
        Text("Preferences has moved",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of one-time tip about Preferences having moved to the Settings tab")
    }

    var message: Text? {
        Text("Preferences is now the Settings tab. People, Clubs and Maps are now tabs too.",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of one-time tip about Preferences having moved to the Settings tab")
    }

    var image: Image? {
        Image(systemName: "gearshape") // matches the icon of the Settings tab
    }

    var options: [any TipOption] {
        MaxDisplayCount(1) // show only once: the system invalidates the tip after its first display
    }

}
