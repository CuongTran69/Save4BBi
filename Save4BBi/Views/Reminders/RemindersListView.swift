//
//  RemindersListView.swift
//  MediFamily
//
//  Created by Cường Trần on 08/12/25.
//

import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @Query(sort: \Reminder.scheduledDate) private var allReminders: [Reminder]
    
    @State private var showDeleteAlert = false
    @State private var reminderToDelete: Reminder?
    @State private var showEditSheet = false
    @State private var reminderToEdit: Reminder?
    @State private var editedDate: Date = Date()
    @State private var showAddSheet = false
    
    // Filter to show only upcoming (not completed, not past)
    private var upcomingReminders: [Reminder] {
        allReminders.filter { !$0.isCompleted && !$0.isPast }
    }
    
    private var pastReminders: [Reminder] {
        allReminders.filter { $0.isPast && !$0.isCompleted }
    }
    
    private var completedReminders: [Reminder] {
        allReminders.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if allReminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("reminder.upcoming"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.done")) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primary)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }
            .customDialog(
                isPresented: $showDeleteAlert,
                title: lang.localized("reminder.delete"),
                message: lang.localized("reminder.delete_confirm"),
                primaryButton: DialogButton(title: lang.localized("button.delete"), isDestructive: true) {
                    if let reminder = reminderToDelete {
                        deleteReminder(reminder)
                    }
                },
                secondaryButton: DialogButton(title: lang.localized("button.cancel")) {}
            )
            .sheet(isPresented: $showEditSheet) {
                editReminderSheet
            }
            .sheet(isPresented: $showAddSheet) {
                AddReminderSheet()
            }
        }
    }

    // MARK: - Edit Reminder Sheet
    private var editReminderSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                // Reminder info
                if let reminder = reminderToEdit {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text(reminder.visitTitle ?? reminder.title)
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.Colors.text)

                        if let memberName = reminder.memberName {
                            Text(memberName)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                }

                // Date picker
                CustomDatePicker(
                    lang.localized("reminder.date"),
                    selection: $editedDate,
                    mode: .dateAndTime
                )

                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("reminder.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { showEditSheet = false }
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.save")) { saveEditedReminder() }
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.text.opacity(0.3))
            
            Text(lang.localized("reminder.no_reminders"))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
            
            Text(lang.localized("reminder.tip"))
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Reminders List
    private var remindersList: some View {
        List {
            // Upcoming section
            if !upcomingReminders.isEmpty {
                Section {
                    ForEach(upcomingReminders) { reminder in
                        reminderRow(reminder, isUpcoming: true)
                    }
                } header: {
                    Label(lang.localized("reminder.upcoming"), systemImage: "clock.badge")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            
            // Past (missed) section
            if !pastReminders.isEmpty {
                Section {
                    ForEach(pastReminders) { reminder in
                        reminderRow(reminder, isUpcoming: false)
                    }
                } header: {
                    Label(lang.localized("reminder.past"), systemImage: "clock.badge.exclamationmark")
                        .foregroundColor(Theme.Colors.secondary)
                }
            }
            
            // Completed section
            if !completedReminders.isEmpty {
                Section {
                    ForEach(completedReminders) { reminder in
                        completedReminderRow(reminder)
                    }
                } header: {
                    Label(lang.localized("reminder.completed"), systemImage: "checkmark.circle")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Reminder Row
    private func reminderRow(_ reminder: Reminder, isUpcoming: Bool) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Bell icon with color
            Image(systemName: isUpcoming ? "bell.fill" : "bell.badge.fill")
                .font(.title2)
                .foregroundColor(isUpcoming ? Theme.Colors.primary : Theme.Colors.secondary)
                .frame(width: 40, height: 40)
                .background((isUpcoming ? Theme.Colors.primary : Theme.Colors.secondary).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.visitTitle ?? reminder.title)
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(Theme.Colors.text)
                
                if let memberName = reminder.memberName {
                    Text(memberName)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(reminder.formattedDate)
                        .font(Theme.Typography.caption)
                }
                .foregroundColor(Theme.Colors.text.opacity(0.6))
            }
            
            Spacer()

            // Days until badge
            if isUpcoming && reminder.daysUntil > 0 {
                Text("\(reminder.daysUntil)d")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.small)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                reminderToDelete = reminder
                showDeleteAlert = true
            } label: {
                Label(lang.localized("button.delete"), systemImage: "trash")
            }

            Button {
                reminderToEdit = reminder
                editedDate = reminder.scheduledDate
                showEditSheet = true
            } label: {
                Label(lang.localized("button.edit"), systemImage: "pencil")
            }
            .tint(Theme.Colors.primary)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                markAsCompleted(reminder)
            } label: {
                Label(lang.localized("reminder.mark_done"), systemImage: "checkmark.circle")
            }
            .tint(Theme.Colors.accent)
        }
    }

    // MARK: - Completed Reminder Row
    private func completedReminderRow(_ reminder: Reminder) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.accent.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.visitTitle ?? reminder.title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                    .strikethrough()

                Text(reminder.formattedDate)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.4))
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                reminderToDelete = reminder
                showDeleteAlert = true
            } label: {
                Label(lang.localized("button.delete"), systemImage: "trash")
            }
        }
    }

    // MARK: - Actions

    private func deleteReminder(_ reminder: Reminder) {
        // Cancel the notification
        notificationManager.cancelReminder(reminder)

        // Delete from database
        modelContext.delete(reminder)
        try? modelContext.save()
    }

    private func markAsCompleted(_ reminder: Reminder) {
        reminder.isCompleted = true

        // Cancel the notification since it's done
        notificationManager.cancelReminder(reminder)

        try? modelContext.save()
    }

    private func saveEditedReminder() {
        guard let reminder = reminderToEdit else { return }

        // Cancel old notification
        notificationManager.cancelReminder(reminder)

        // Update the date
        reminder.scheduledDate = editedDate

        // Reschedule notification with new date
        Task {
            await notificationManager.scheduleReminder(reminder)
        }

        try? modelContext.save()
        showEditSheet = false
    }
}

#Preview {
    RemindersListView()
}

