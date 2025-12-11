//
//  AddReminderSheet.swift
//  MediFamily
//
//  Created by Cường Trần on 11/12/25.
//

import SwiftUI
import SwiftData

struct AddReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var scheduledDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var selectedMemberId: UUID?
    @State private var showingSuccessAlert = false
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Title field
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(lang.localized("reminder.name"))
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField(lang.localized("reminder.name_placeholder"), text: $title)
                            .textFieldStyle(.plain)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                    
                    // Message field (optional)
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(lang.localized("reminder.message"))
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField(lang.localized("reminder.message_placeholder"), text: $message, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                    
                    // Member picker
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(lang.localized("member.select"))
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.sm) {
                                // "All" option
                                memberChip(name: lang.localized("member.all"), isSelected: selectedMemberId == nil) {
                                    selectedMemberId = nil
                                }
                                
                                ForEach(members) { member in
                                    memberChip(name: member.name, isSelected: selectedMemberId == member.id) {
                                        selectedMemberId = member.id
                                    }
                                }
                            }
                        }
                    }
                    
                    // Date picker
                    CustomDatePicker(
                        lang.localized("reminder.date"),
                        selection: $scheduledDate,
                        mode: .dateAndTime
                    )
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("reminder.add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { dismiss() }
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.save")) { saveReminder() }
                        .fontWeight(.semibold)
                        .foregroundColor(canSave ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.4))
                        .disabled(!canSave)
                }
            }
            .alert(lang.localized("reminder.success"), isPresented: $showingSuccessAlert) {
                Button(lang.localized("button.ok")) {
                    dismiss()
                }
            } message: {
                Text("\(lang.localized("reminder.success_message")) \(formattedDate)")
            }
        }
    }
    
    // MARK: - Member Chip
    private func memberChip(name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(name)
                .font(Theme.Typography.caption)
                .foregroundColor(isSelected ? .white : Theme.Colors.text)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isSelected ? Theme.Colors.primary : Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }
    
    // MARK: - Save
    private func saveReminder() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let memberName = members.first { $0.id == selectedMemberId }?.name
        
        let reminder = Reminder(
            title: trimmedTitle,
            message: trimmedMessage.isEmpty ? trimmedTitle : trimmedMessage,
            scheduledDate: scheduledDate,
            visitId: nil,
            visitTitle: trimmedTitle,
            memberId: selectedMemberId,
            memberName: memberName
        )
        
        modelContext.insert(reminder)
        
        Task {
            await notificationManager.scheduleReminder(reminder)
        }
        
        try? modelContext.save()
        showingSuccessAlert = true
    }
}

