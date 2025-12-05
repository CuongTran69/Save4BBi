//
//  MediFamilyApp.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData

@main
struct MediFamilyApp: App {
    @State private var showHome = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showHome {
                    HomeView()
                        .transition(.opacity)
                } else {
                    SplashScreenView(showHome: $showHome)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showHome)
        }
        .modelContainer(for: [MedicalVisit.self, FamilyMember.self, Reminder.self])
    }
}
