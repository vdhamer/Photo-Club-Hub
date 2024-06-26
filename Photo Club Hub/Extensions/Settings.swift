//
//  Settings.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/06/2024.
//

import Foundation

struct Settings {

    static var manualDataLoading: Bool { // controlled by toggle in Settings
        // Setting this to true clears the existing database and skips loading any data on app startup.
        // It displays "Manual loading" in the Prelude startup screen as a warning that the mode is set.
        // The missing club/museum/member data can be loaded manually by swiping down on e.g., the Portfolio screen.
        get {
            UserDefaults.standard.bool(forKey: "manualDataLoading") // returns false if missing
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "manualDataLoading")
        }
    }

    static var extraCoreDataSaves: Bool { // controlled by toggle in Settings
        // Important setting that should normally be kept false,
        // It adds additional ManagedObjectContext.save() transactions between the absolute minimum set.
        // It is needed for testing purposes only.
        get {
            UserDefaults.standard.bool(forKey: "extraCoreDataSaves") // returns false if missing
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "extraCoreDataSaves")
        }
    }

}
