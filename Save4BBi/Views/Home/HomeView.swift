//
//  HomeView.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData

enum ViewMode {
    case grid
    case list
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MedicalVisit.visitDate, order: .reverse) private var visits: [MedicalVisit]
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]
    @Query(sort: \Reminder.scheduledDate) private var reminders: [Reminder]
    @Query(sort: \Tag.createdAt) private var allTags: [Tag]
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var memberManager = MemberManager.shared

    @State private var searchText = ""
    @State private var viewMode: ViewMode = .grid
    @State private var showingAddVisit = false
    @State private var showingSettings = false
    @State private var showingFamilyMembers = false
    @State private var showingStatistics = false
    @State private var showingReminders = false
    @State private var showingManageTags = false
    @State private var isSearchExpanded = false
    @State private var showingSideMenu = false
    @FocusState private var isSearchFocused: Bool

    // Count of upcoming reminders (not completed, not past)
    private var upcomingReminderCount: Int {
        reminders.filter { !$0.isCompleted && !$0.isPast }.count
    }

    // Get selected member
    private var selectedMember: FamilyMember? {
        guard let selectedId = memberManager.selectedMemberId else { return nil }
        return members.first { $0.id == selectedId }
    }

    var filteredVisits: [MedicalVisit] {
        var result = visits

        // Apply member filter
        if let selectedMemberId = memberManager.selectedMemberId {
            result = result.filter { $0.memberId == selectedMemberId }
        }

        // Apply search filter (includes tag search)
        if !searchText.isEmpty {
            result = result.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.condition.localizedCaseInsensitiveContains(searchText) ||
                visit.doctorName.localizedCaseInsensitiveContains(searchText) ||
                visit.notes.localizedCaseInsensitiveContains(searchText) ||
                matchesTagSearch(visit: visit, searchText: searchText)
            }
        }

        // Sort by newest first
        result.sort { $0.visitDate > $1.visitDate }

        return result
    }

    /// Check if visit matches tag search - searches both tag IDs and localized names
    private func matchesTagSearch(visit: MedicalVisit, searchText: String) -> Bool {
        for tagIdString in visit.tags {
            // Try to find tag by UUID
            if let uuid = UUID(uuidString: tagIdString),
               let tag = allTags.first(where: { $0.id == uuid }) {
                // Search in both EN and VI names
                if tag.name.localizedCaseInsensitiveContains(searchText) ||
                   tag.nameVI.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            } else {
                // Legacy: direct string match for old data
                if tagIdString.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }
        }
        return false
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 0) {
                        // Custom Header
                        headerView

                        // Content
                        if filteredVisits.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                if viewMode == .grid {
                                    GridLayout(visits: filteredVisits)
                                } else {
                                    ListLayout(visits: filteredVisits)
                                }
                            }
                        }
                    }
                    .dismissKeyboardOnTap()
                    .background(Theme.Colors.background)

                    // Floating Add Button
                    Button {
                        handleAddVisitTap()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Theme.Colors.primary, Theme.Colors.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 4)
                    }
                    .padding(Theme.Spacing.lg)
                }
                .navigationBarHidden(true)
                .onTapGesture {
                    // Collapse search when tapping outside
                    if isSearchExpanded && searchText.isEmpty {
                        withAnimation(Theme.Animation.quick) {
                            isSearchExpanded = false
                            isSearchFocused = false
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(languageManager.localized("button.done")) {
                            isSearchFocused = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddVisit) {
                AddVisitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingFamilyMembers) {
                FamilyMembersView()
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
            }
            .sheet(isPresented: $showingReminders) {
                RemindersListView()
            }
            .sheet(isPresented: $showingManageTags) {
                ManageTagsSheet()
            }

            // Side Menu overlay
            SideMenuView(
                isPresented: $showingSideMenu,
                onSettingsTap: { showingSettings = true },
                onStatisticsTap: { showingStatistics = true },
                onFamilyMembersTap: { showingFamilyMembers = true },
                onTagsTap: { showingManageTags = true }
            )
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            // Title row with action buttons
            HStack(spacing: 16) {
                if isSearchExpanded {
                    // Expanded search field
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.text.opacity(0.4))

                        TextField(languageManager.localized("home.search"), text: $searchText)
                            .font(Theme.Typography.body)
                            .focused($isSearchFocused)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.text.opacity(0.4))
                            }
                        }

                        Button {
                            withAnimation(Theme.Animation.quick) {
                                searchText = ""
                                isSearchExpanded = false
                                isSearchFocused = false
                            }
                        } label: {
                            Text(languageManager.localized("button.cancel"))
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                } else {
                    // Menu button (hamburger)
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingSideMenu = true
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                    }

                    // Title
                    Text(languageManager.localized("home.title"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.Colors.text)

                    Spacer()

                    // Action buttons
                    HStack(spacing: 20) {
                        // Search
                        Button {
                            withAnimation(Theme.Animation.quick) {
                                isSearchExpanded = true
                                isSearchFocused = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }

                        // Reminders with badge
                        Button {
                            showingReminders = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Theme.Colors.text.opacity(0.6))

                                if upcomingReminderCount > 0 {
                                    Circle()
                                        .fill(Theme.Colors.error)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)

            // Member Selector + View Mode Toggle
            HStack {
                // Member chips
                memberSelectorView

                Spacer()

                // View mode toggle - compact
                HStack(spacing: 4) {
                    Button {
                        withAnimation(Theme.Animation.quick) { viewMode = .grid }
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 14))
                            .foregroundColor(viewMode == .grid ? Theme.Colors.primary : Theme.Colors.text.opacity(0.4))
                    }

                    Button {
                        withAnimation(Theme.Animation.quick) { viewMode = .list }
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 14))
                            .foregroundColor(viewMode == .list ? Theme.Colors.primary : Theme.Colors.text.opacity(0.4))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Theme.Colors.text.opacity(0.05))
                .cornerRadius(6)
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .onAppear {
            TagManager.shared.initializeDefaultTags(context: modelContext)
        }
    }

    // MARK: - Member Selector View
    private var memberSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" button
                memberChip(
                    label: languageManager.localized("member.all"),
                    isSelected: memberManager.selectedMemberId == nil,
                    icon: nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) { memberManager.clearSelection() }
                }

                // Member buttons
                ForEach(members) { member in
                    memberChip(
                        label: member.name,
                        isSelected: memberManager.isSelected(member),
                        icon: member.avatarIcon
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) { memberManager.selectMember(member) }
                    }
                }

                // Add member button
                Button {
                    showingFamilyMembers = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(Theme.Colors.text.opacity(0.08))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func memberChip(label: String, isSelected: Bool, icon: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.text.opacity(0.06))
            .foregroundColor(isSelected ? .white : Theme.Colors.text.opacity(0.8))
            .cornerRadius(16)
        }
    }

    // MARK: - Actions

    private func handleAddVisitTap() {
        // If no members exist, create a default member first
        if members.isEmpty {
            createDefaultMember()
        }
        showingAddVisit = true
    }

    private func createDefaultMember() {
        let defaultMember = FamilyMember(
            name: languageManager.localized("member.default_name"),
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
            memberType: .adult,
            gender: .other,
            bloodType: .unknown,
            relationship: .other
        )
        modelContext.insert(defaultMember)
        try? modelContext.save()

        // Auto-select the new member
        memberManager.selectMember(defaultMember)
    }
}
