//
//  SettingsView.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager.shared

    var body: some View {
        NavigationStack {
            List {
                languageSection
                aboutSection
                appLogoSection
            }
            .navigationTitle(languageManager.localized("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localized("button.done")) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Language Section
    private var languageSection: some View {
        Section {
            ForEach(AppLanguage.allCases, id: \.self) { language in
                languageRow(language)
            }
        } header: {
            Text(languageManager.localized("settings.language"))
                .textCase(nil)
        }
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        Button {
            withAnimation {
                languageManager.setLanguage(language)
            }
        } label: {
            HStack {
                Text(language.flag)
                    .font(.title2)

                Text(language.displayName)
                    .foregroundColor(Theme.Colors.text)

                Spacer()

                if languageManager.currentLanguage == language {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section {
            versionRow
            authorRow
            copyrightRow
        } header: {
            Text(languageManager.localized("settings.about"))
                .textCase(nil)
        }
    }

    private var versionRow: some View {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        return HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Theme.Colors.primary)
            Text(languageManager.localized("settings.version"))
            Spacer()
            Text("\(appVersion) (\(buildNumber))")
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
    }

    private var authorRow: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(Theme.Colors.accent)
            Text(languageManager.localized("settings.author"))
            Spacer()
            Text("Cường Trần")
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
    }

    private var copyrightRow: some View {
        HStack {
            Image(systemName: "c.circle.fill")
                .foregroundColor(Theme.Colors.success)
            Text(languageManager.localized("settings.copyright"))
            Spacer()
            Text("© 2025")
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
    }

    // MARK: - App Logo Section
    private var appLogoSection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.primary)

                Text("Save4BBi")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.text)

                Text("Medical Visit Tracker for Your Little One")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    SettingsView()
}

