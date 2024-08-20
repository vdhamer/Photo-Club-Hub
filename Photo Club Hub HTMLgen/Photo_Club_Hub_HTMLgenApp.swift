//
//  Photo_Club_Hub_HTMLgenApp.swift
//  Photo Club Hub HTMLgen
//
//  Created by Peter van den Hamer on 20/08/2024.
//

import SwiftUI

@main
struct PhotoClubHubHtmlGenApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
