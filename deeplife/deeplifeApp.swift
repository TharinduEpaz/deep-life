//
//  deeplifeApp.swift
//  deeplife
//
//  Created by Tharindu Epasingha on 2026-04-28.
//

import SwiftUI
import SwiftData

@main
struct deeplifeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
        .defaultSize(width: 460, height: 520)

        MenuBarExtra("Deep Life", systemImage: "chart.bar.fill") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
    }
}
