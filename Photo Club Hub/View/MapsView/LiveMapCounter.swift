//
//  LiveMapCounter.swift
//  Photo Club Hub
//
//  Created by Claude Code and guided by Peter van den Hamer on 30/09/2026.
//

import SwiftUI

/// Controls how a Maps card creates its live map (#870) or its image of a locked map (#867).
/// Switchable (only if the device has a Debug build).
/// It is switched via the debug section of the Settings tab,  so the modes can be compared using a single build.
/// A Release build has no way to change these values, and sticks to using the defaults settings below.
///
/// Stored with `@AppStorage` rather than in `SettingsStruct`:
/// those settings only apply after tapping Save, while a before/after comparison needs instant mode switching.
enum MapsTestMode: String, CaseIterable {
    case original // every card creates its live map as soon as the card appears, as before #870
    case phase1Delay // a locked map becomes live only after the card has been on screen for the delay
    case phase2Snapshot // a locked map is an image, made after the same delay; only an unlocked map is live

    static let storageKey = "mapsTestMode"
    // Phase 2 used the least memory on the iPhone and both iPads; Original crashed on iPadOS 26 at 4.4 GB (#867)
    static let defaultValue: MapsTestMode = .phase2Snapshot

    static let delayStorageKey = "mapsTestDelayMilliseconds"
    // #870 started at ⅓ s, which felt slow on a slow scroll; 150 and 200 ms kept memory as low (iPhone, 1 Oct 2026)
    static let delayChoicesMilliseconds = [150, 175, 200, 333, 500, 1000] // to tune the delay on the iPhone and iPads
    static let defaultDelayMilliseconds = 175 // overruled as soon as user select another value (saved in UserDefaults)
}

#if DEBUG
/// Debug-only counts of live maps on the Maps screen, shown in the debug section of the Settings tab (#870).
///
/// A map counts as created each time `MapsViewMap` appears. SwiftUI offers no hook for the moment MapKit builds its
/// own view, so this is a proxy, but it counts the same way in every test mode, which is what a comparison needs.
@Observable @MainActor
final class LiveMapCounter {

    static let shared = LiveMapCounter()

    private(set) var created = 0 // total since launch or since the last stats reset
    private(set) var maxAtOnce = 0 // max live maps that existed at the same moment: closest to what drives memory
    private var currentAtOnce = 0 // number of live maps right now

    func mapAppeared(_ organizationName: String) {
        created += 1
        currentAtOnce += 1
        maxAtOnce = max(maxAtOnce, currentAtOnce)
        print("Live map #\(created) (\(currentAtOnce) at once): \(organizationName)")
    }

    func mapDisappeared() {
        currentAtOnce = max(0, currentAtOnce - 1)
    }

    /// Starts a new measurement. The maps still on screen stay live, so the peak restarts from their number.
    func reset() {
        created = 0
        maxAtOnce = currentAtOnce
    }
}
#endif
