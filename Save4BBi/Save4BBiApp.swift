//
//  Save4BBiApp.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData

@main
struct Save4BBiApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MedicalVisit.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var showHome = false

    var body: some Scene {
        WindowGroup {
            if showHome {
                HomeView()
                    .modelContainer(sharedModelContainer)
            } else {
                SplashScreenView(showHome: $showHome)
            }
        }
    }
}
