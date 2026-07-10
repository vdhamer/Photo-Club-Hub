//
//  TabNavigationTip.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/07/2026.
//

import TipKit // for Tip, MaxDisplayCount

/// One-shot tip shown at the top of the Clubs screen after the toolbar → tabs migration (issue #763).
/// It tells existing users that the old toolbar buttons are now tabs, and that Readme is now behind the ⓘ button.
/// Shown on the Clubs screen because that screen hosted the old toolbar buttons and is the tab shown at app startup.
struct TabNavigationTip: Tip {

    /// Becomes true once this tip is invalidated; used as a gate to sequence ReadmeTip after this one.
    /// Note: no trailing comment allowed on the next line — the @Parameter macro copies the
    /// initializer expression into a function call, and a `//` comment there currently breaks the expansion.
    @Parameter
    static var isInvalidated: Bool = false

    var title: Text {
        Text("Navigation using tabs",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of one-time tip about Preferences having moved to the Settings tab")
    }

    var message: Text? {
        Text("Tab-based navigation key",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of one-time tip about tabs replacing toolbar buttons")
    }

    var image: Image? {
        Image(systemName: "signpost.right.and.left") // matches the icon of the Settings tab
    }

    var options: [any TipOption] {
        MaxDisplayCount(2) // stop showing the tip after displaying it 2 times
        if #available(iOS 18.0, *) {
            let seconds = 90
            MaxDisplayDuration(TimeInterval(seconds)) // or showing the tip in total this long
        }
    }

}
