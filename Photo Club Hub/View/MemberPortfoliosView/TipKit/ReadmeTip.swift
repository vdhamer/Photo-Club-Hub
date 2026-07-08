//
//  ReadmeTip.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/07/2026.
//

import TipKit // for Tip, MaxDisplayCount

/// One-shot tip shown at the top of the Clubs screen after the toolbar → tabs migration (issue #763).
/// It tells existing users that the old toolbar button for Readme is now behind the ⓘ button.
/// Shown on the Clubs screen because that screen hosted the old toolbar buttons and is the tab shown at app startup.
struct ReadmeTip: Tip {

    var title: Text {
        Text("Built-in Readme",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Title of one-time tip about the Readme button")
    }

    var message: Text? {
        Text("Readme button key",
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Message of one-time tip about the Readme button")
    }

    var image: Image? {
        Image(systemName: "info.circle") // matches the icon of the button
    }

    var options: [any TipOption] {
        MaxDisplayCount(2) // stop showing the tip after displaying it 2 times
        if #available(iOS 18.0, *) {
            let seconds = 90
            MaxDisplayDuration(TimeInterval(seconds)) // or showing the tip in total this long
        }
    }

}
