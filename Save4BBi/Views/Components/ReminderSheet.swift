//
//  ReminderSheet.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import SwiftUI
import SwiftData

struct ReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    let visit: MedicalVisit
    let member: FamilyMember?
    
    @State private var selectedOption: ReminderOption = .oneWeek
    @State private var customDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var showCustomPicker = false
    @State private var showSuccess = false
    @State private var showPermissionAlert = false
    @State private var scheduledDate: Date?
    
    enum ReminderOption: CaseIterable {
        case oneWeek, twoWeeks, oneMonth, threeMonths, custom
        
        var days: Int {
            switch self {
            case .oneWeek: return 7
            case .twoWeeks: return 14
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .custom: return 0
            }
        }
        
        func localizationKey() -> String {
            switch self {
            case .oneWeek: return "reminder.in_1_week"
            case .twoWeeks: return "reminder.in_2_weeks"
            case .oneMonth: return "reminder.in_1_month"
            case .threeMonths: return "reminder.in_3_months"
            case .custom: return "reminder.custom"
            }
        }
        
        var icon: String {
            switch self {
            case .oneWeek: return "1.circle.fill"
            case .twoWeeks: return "2.circle.fill"
            case .oneMonth: return "calendar.circle.fill"
            case .threeMonths: return "calendar.badge.clock"
            case .custom: return "calendar.badge.plus"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                // Header info
                headerSection
                
                // Options
                optionsSection
                
                // Custom date picker
                if showCustomPicker {
                    customDateSection
                }
                
                Spacer()
                
                // Set reminder button
                setReminderButton
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("reminder.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(lang.localized("reminder.cancel")) { dismiss() }
                }
            }
            .alert(lang.localized("reminder.success"), isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                if let date = scheduledDate {
                    Text("\(lang.localized("reminder.success_message")) \(formatDate(date))")
                }
            }
            .alert(lang.localized("reminder.permission_required"), isPresented: $showPermissionAlert) {
                Button(lang.localized("reminder.open_settings")) { openSettings() }
                Button(lang.localized("reminder.cancel"), role: .cancel) { }
            } message: {
                Text(lang.localized("reminder.permission_message"))
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 50))
                .foregroundColor(Theme.Colors.primary)
            
            Text(lang.localized("reminder.follow_up"))
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            Text(visit.displayTitle)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text.opacity(0.7))
            
            if let member = member {
                Text(member.name)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.small)
            }
        }
        .padding(.vertical, Theme.Spacing.md)
    }
    
    // MARK: - Options Section
    private var optionsSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(lang.localized("reminder.select_time"))
                .font(Theme.Typography.bodyBold)
                .foregroundColor(Theme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(ReminderOption.allCases, id: \.self) { option in
                optionRow(option)
            }
        }
    }
    
    private func optionRow(_ option: ReminderOption) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedOption = option
                showCustomPicker = option == .custom
            }
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: option.icon)
                    .font(.title2)
                    .foregroundColor(selectedOption == option ? Theme.Colors.primary : Theme.Colors.text.opacity(0.5))
                    .frame(width: 30)
                
                Text(lang.localized(option.localizationKey()))
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                if selectedOption == option {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .padding(Theme.Spacing.md)
            .background(selectedOption == option ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(selectedOption == option ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }

    // MARK: - Custom Date Section
    private var customDateSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            DatePicker(
                "",
                selection: $customDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(Theme.Colors.primary)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Set Reminder Button
    private var setReminderButton: some View {
        Button {
            Task {
                await setReminder()
            }
        } label: {
            HStack {
                Image(systemName: "bell.badge.fill")
                Text(lang.localized("reminder.set"))
            }
            .font(Theme.Typography.bodyBold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.large)
        }
    }

    // MARK: - Actions

    private func setReminder() async {
        // Calculate reminder date
        let reminderDate: Date
        if selectedOption == .custom {
            reminderDate = customDate
        } else {
            reminderDate = Calendar.current.date(
                byAdding: .day,
                value: selectedOption.days,
                to: Date()
            ) ?? Date()
        }

        // Create reminder
        let reminder = Reminder(
            title: lang.localized("reminder.notification_title"),
            message: "\(visit.displayTitle) - \(member?.name ?? "")",
            scheduledDate: reminderDate,
            visitId: visit.id,
            visitTitle: visit.displayTitle,
            memberId: member?.id,
            memberName: member?.name
        )

        // Schedule notification
        let success = await notificationManager.scheduleReminder(reminder)

        if success {
            // Save to SwiftData
            modelContext.insert(reminder)
            try? modelContext.save()

            scheduledDate = reminderDate
            showSuccess = true
        } else {
            showPermissionAlert = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ReminderSheet(
        visit: MedicalVisit(title: "Checkup", condition: "Fever", doctorName: "Dr. Smith"),
        member: nil
    )
}

