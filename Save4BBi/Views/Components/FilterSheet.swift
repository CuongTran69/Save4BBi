//
//  FilterSheet.swift
//  Save4BBi
//
//  Created by Cường Trần on 27/11/25.
//

import SwiftUI

struct FilterOptions {
    var startDate: Date?
    var endDate: Date?
    var selectedTags: Set<String> = []
    var sortOption: SortOption = .dateNewest
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Date (Newest First)"
        case dateOldest = "Date (Oldest First)"
        case conditionAZ = "Condition (A-Z)"
        case conditionZA = "Condition (Z-A)"
    }
    
    var isActive: Bool {
        startDate != nil || endDate != nil || !selectedTags.isEmpty || sortOption != .dateNewest
    }
}

struct FilterSheet: View {
    @Binding var filterOptions: FilterOptions
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempStartDate: Date?
    @State private var tempEndDate: Date?
    @State private var tempSelectedTags: Set<String>
    @State private var tempSortOption: FilterOptions.SortOption
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    let availableTags = ["Checkup", "Vaccination", "Emergency", "Dental", "Fever", "Routine"]
    
    init(filterOptions: Binding<FilterOptions>) {
        self._filterOptions = filterOptions
        _tempStartDate = State(initialValue: filterOptions.wrappedValue.startDate)
        _tempEndDate = State(initialValue: filterOptions.wrappedValue.endDate)
        _tempSelectedTags = State(initialValue: filterOptions.wrappedValue.selectedTags)
        _tempSortOption = State(initialValue: filterOptions.wrappedValue.sortOption)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Date Range Section
                    dateRangeSection
                    
                    // Tags Section
                    tagsSection
                    
                    // Sort Section
                    sortSection
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset") {
                        resetFilters()
                    }
                    .foregroundColor(Theme.Colors.error)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Date Range Section
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Date Range")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: Theme.Spacing.md) {
                // Start Date
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text("From")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text.opacity(0.7))
                        
                        Spacer()
                        
                        if tempStartDate != nil {
                            Button {
                                tempStartDate = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.text.opacity(0.4))
                            }
                        }
                    }
                    
                    Button {
                        showStartDatePicker.toggle()
                    } label: {
                        HStack {
                            Text(tempStartDate?.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                                .foregroundColor(tempStartDate == nil ? Theme.Colors.text.opacity(0.4) : Theme.Colors.text)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .font(Theme.Typography.body)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.background)
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                    
                    if showStartDatePicker {
                        DatePicker("", selection: Binding(
                            get: { tempStartDate ?? Date() },
                            set: { tempStartDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onChange(of: tempStartDate) { _, _ in
                            showStartDatePicker = false
                        }
                    }
                }
                
                // End Date
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text("To")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text.opacity(0.7))
                        
                        Spacer()
                        
                        if tempEndDate != nil {
                            Button {
                                tempEndDate = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.text.opacity(0.4))
                            }
                        }
                    }
                    
                    Button {
                        showEndDatePicker.toggle()
                    } label: {
                        HStack {
                            Text(tempEndDate?.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                                .foregroundColor(tempEndDate == nil ? Theme.Colors.text.opacity(0.4) : Theme.Colors.text)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .font(Theme.Typography.body)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.background)
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                    
                    if showEndDatePicker {
                        DatePicker("", selection: Binding(
                            get: { tempEndDate ?? Date() },
                            set: { tempEndDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onChange(of: tempEndDate) { _, _ in
                            showEndDatePicker = false
                        }
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Filter by Tags")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(availableTags, id: \.self) { tag in
                    TagButton(
                        text: tag,
                        isSelected: tempSelectedTags.contains(tag)
                    ) {
                        if tempSelectedTags.contains(tag) {
                            tempSelectedTags.remove(tag)
                        } else {
                            tempSelectedTags.insert(tag)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Sort Section
    private var sortSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Sort By")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: 0) {
                ForEach(FilterOptions.SortOption.allCases, id: \.self) { option in
                    Button {
                        tempSortOption = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)
                            
                            Spacer()
                            
                            if tempSortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.primary)
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(tempSortOption == option ? Theme.Colors.primary.opacity(0.1) : Color.clear)
                    }
                    
                    if option != FilterOptions.SortOption.allCases.last {
                        Divider()
                    }
                }
            }
            .cardStyle()
        }
    }
    
    // MARK: - Actions
    private func applyFilters() {
        filterOptions.startDate = tempStartDate
        filterOptions.endDate = tempEndDate
        filterOptions.selectedTags = tempSelectedTags
        filterOptions.sortOption = tempSortOption
        dismiss()
    }
    
    private func resetFilters() {
        tempStartDate = nil
        tempEndDate = nil
        tempSelectedTags = []
        tempSortOption = .dateNewest
    }
}

#Preview {
    FilterSheet(filterOptions: .constant(FilterOptions()))
}
