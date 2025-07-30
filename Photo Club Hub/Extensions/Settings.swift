//
//  Settings.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/06/2024.
//

import Foundation

struct Settings {

    @available(*, unavailable)
    init() {
        fatalError("init() is not available. Settings only holds a few static computer properties.")
    }

    static let userDefaultsKey: String = "dataResetPending282b4646" // must match id of Settings toggle in Root.plist
    private static let prevUserDefaultsKeys: Set<String> = ["dataResetPending280b4644",
                                                            "dataResetPending280",
                                                            "dataResetPending272",
                                                            "dataResetPending"]

    // Doesn't really work in Photo Club Hub HTML until the version numbers are synchronized
    static var dataResetPending: Bool { // stored as a string shown in Settings
        // returns true only when read for the first time

        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            UserDefaults.standard.set(true, forKey: userDefaultsKey) // if key missing, set value to true
        }

        let prevValue = UserDefaults.standard.bool(forKey: userDefaultsKey) // return whether reset needed

        if prevValue {
            UserDefaults.standard.set(false, forKey: userDefaultsKey) // return true only once
            for key in prevUserDefaultsKeys { // also remove all previously used dataResetPending keys from UserDefaults
                UserDefaults.standard.removeObject(forKey: key) // not important, just a cleanup
            }
        }

        return prevValue // if true, app will immediately do a data reset
    } // implicit getter only

    static var manualDataLoading: Bool { // controlled by toggle in Settings
        // Setting this to true clears the existing database and skips loading any data on app startup.
        // It displays "Manual loading" in the Prelude startup screen as a warning that the mode is set.
        // The missing club/museum/member data can be loaded manually by swiping down on e.g., the Portfolio screen.
        UserDefaults.standard.bool(forKey: "manualDataLoading") // here we are happy with missing key -> false
    }

    static var extraCoreDataSaves: Bool { // controlled by toggle in Settings
        // Important setting that should normally be kept false.
        // It adds extra ManagedObjectContext.save() transactions to the minimal set of save's.
        // It is needed for testing purposes only.
        UserDefaults.standard.bool(forKey: "extraCoreDataSaves") // here we are happy with missing key -> false
    }

    static var loadTestClubs: Bool { // controlled by toggle in Settings
        // Instructs the app whether to load XampleMax.level2.json and XampleMin.level2.json
        // It will typically be used by people creating new level2.json files to see what the example files look like
        UserDefaults.standard.bool(forKey: "loadTestClubs") // if the key is missing, this returns false
    }

}
