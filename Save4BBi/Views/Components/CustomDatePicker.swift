//
//  CustomDatePicker.swift
//  MediFamily
//
//  Created by Cường Trần on 09/12/25.
//

import SwiftUI

/// Modern, user-friendly date picker with beautiful UI
/// Supports both date-only and date+time selection
struct CustomDatePicker: View {
    @Binding var date: Date
    @ObservedObject private var lang = LanguageManager.shared
    
    let title: String?
    let mode: Mode
    let dateRange: ClosedRange<Date>?
    let showLabel: Bool
    
    @State private var showPicker = false
    @State private var tempDate: Date
    
    enum Mode {
        case date
        case dateAndTime
        
        var displayedComponents: DatePickerComponents {
            switch self {
            case .date: return .date
            case .dateAndTime: return [.date, .hourAndMinute]
            }
        }
    }
    
    init(
        _ title: String? = nil,
        selection: Binding<Date>,
        mode: Mode = .date,
        in dateRange: ClosedRange<Date>? = nil,
        showLabel: Bool = true
    ) {
        self.title = title
        self._date = selection
        self.mode = mode
        self.dateRange = dateRange
        self.showLabel = showLabel
        self._tempDate = State(initialValue: selection.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            // Label
            if showLabel, let title = title {
                Text(title)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.text.opacity(0.7))
            }
            
            // Date Display Button
            Button {
                tempDate = date
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showPicker.toggle()
                }
            } label: {
                HStack(spacing: Theme.Spacing.md) {
                    // Calendar Icon
                    Image(systemName: mode == .dateAndTime ? "calendar.badge.clock" : "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 28)
                    
                    // Date Text
                    Text(formattedDate)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: showPicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(showPicker ? Theme.Colors.primary : Color.clear, lineWidth: 2)
                )
                .shadow(color: Theme.Colors.shadow, radius: showPicker ? 8 : 2, x: 0, y: showPicker ? 4 : 1)
            }
            
        }
        .sheet(isPresented: $showPicker) {
            DatePickerSheet(
                date: $date,
                tempDate: $tempDate,
                mode: mode,
                dateRange: dateRange,
                lang: lang,
                onDismiss: { showPicker = false }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Formatted Date

    private var formattedDate: String {
        let formatter = DateFormatter()

        switch mode {
        case .date:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        case .dateAndTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }

        // Use current language
        formatter.locale = Locale(identifier: lang.currentLanguage.rawValue)

        return formatter.string(from: date)
    }
}

// MARK: - Date Picker Sheet
private struct DatePickerSheet: View {
    @Binding var date: Date
    @Binding var tempDate: Date
    let mode: CustomDatePicker.Mode
    let dateRange: ClosedRange<Date>?
    let lang: LanguageManager
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.md) {
                // Date Picker
                if let range = dateRange {
                    DatePicker(
                        "",
                        selection: $tempDate,
                        in: range,
                        displayedComponents: mode.displayedComponents
                    )
                    .datePickerStyle(.graphical)
                    .tint(Theme.Colors.primary)
                    .labelsHidden()
                } else {
                    DatePicker(
                        "",
                        selection: $tempDate,
                        displayedComponents: mode.displayedComponents
                    )
                    .datePickerStyle(.graphical)
                    .tint(Theme.Colors.primary)
                    .labelsHidden()
                }

                Spacer()
            }
            .padding(Theme.Spacing.md)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { onDismiss() }
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.done")) {
                        date = tempDate
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }
}