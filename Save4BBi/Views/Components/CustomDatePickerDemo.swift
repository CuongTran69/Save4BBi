//
//  CustomDatePickerDemo.swift
//  MediFamily
//
//  Created by Cường Trần on 09/12/25.
//

import SwiftUI

/// Demo view to showcase CustomDatePicker functionality
struct CustomDatePickerDemo: View {
    @State private var visitDate = Date()
    @State private var birthDate = Date().addingTimeInterval(-365 * 24 * 60 * 60 * 25) // 25 years ago
    @State private var reminderDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Date Only Examples
                    dateOnlySection
                    
                    // Date with Range Examples
                    dateRangeSection
                    
                    // Date and Time Example
                    dateTimeSection
                    
                    // Current Values
                    currentValuesSection
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("CustomDatePicker Demo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.primary)
            
            Text("CustomDatePicker Component")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            Text("Modern, user-friendly date picker with beautiful UI")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Date Only Section
    
    private var dateOnlySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(
                title: "Date Only",
                icon: "calendar",
                description: "Simple date selection without time"
            )
            
            CustomDatePicker(
                "Visit Date",
                selection: $visitDate,
                mode: .date
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        let pastRange = Date(timeIntervalSince1970: 0)...Date()

        return VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(
                title: "Date with Range",
                icon: "calendar.badge.minus",
                description: "Date selection with past-only constraint"
            )

            CustomDatePicker(
                "Date of Birth",
                selection: $birthDate,
                mode: .date,
                in: pastRange
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Date and Time Section

    private var dateTimeSection: some View {
        let futureRange = Date()...Date(timeIntervalSinceNow: 365 * 24 * 60 * 60 * 10)

        return VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(
                title: "Date & Time",
                icon: "calendar.badge.clock",
                description: "Date and time selection with future-only constraint"
            )

            CustomDatePicker(
                "Reminder Time",
                selection: $reminderDate,
                mode: .dateAndTime,
                in: futureRange
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Current Values Section
    
    private var currentValuesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Current Selected Values")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            valueRow(label: "Visit Date", value: formatDate(visitDate, style: .long))
            valueRow(label: "Date of Birth", value: formatDate(birthDate, style: .long))
            valueRow(label: "Reminder Time", value: formatDateTime(reminderDate))
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.accent.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.large)
    }

    // MARK: - Helper Views

    private func sectionHeader(title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.primary)
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            Text(description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
    }

    private func valueRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.bodyBold)
                .foregroundColor(Theme.Colors.text)
            Spacer()
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.primary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    // MARK: - Formatters

    private func formatDate(_ date: Date, style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: lang.currentLanguage.rawValue)
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: lang.currentLanguage.rawValue)
        return formatter.string(from: date)
    }
}

