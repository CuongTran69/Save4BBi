//
//  HomeView.swift
//  Save4BBi
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
    @ObservedObject private var languageManager = LanguageManager.shared

    @State private var searchText = ""
    @State private var viewMode: ViewMode = .grid
    @State private var showingAddVisit = false
    @State private var showingFilterSheet = false
    @State private var showingSettings = false
    @State private var filterOptions = FilterOptions()

    var filteredVisits: [MedicalVisit] {
        var result = visits
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.condition.localizedCaseInsensitiveContains(searchText) ||
                visit.doctorName.localizedCaseInsensitiveContains(searchText) ||
                visit.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply date range filter
        if let startDate = filterOptions.startDate {
            result = result.filter { $0.visitDate >= startDate }
        }
        if let endDate = filterOptions.endDate {
            result = result.filter { $0.visitDate <= endDate }
        }
        
        // Apply tag filter
        if !filterOptions.selectedTags.isEmpty {
            result = result.filter { visit in
                !Set(visit.tags).isDisjoint(with: filterOptions.selectedTags)
            }
        }
        
        // Apply sort
        switch filterOptions.sortOption {
        case .dateNewest:
            result.sort { $0.visitDate > $1.visitDate }
        case .dateOldest:
            result.sort { $0.visitDate < $1.visitDate }
        case .conditionAZ:
            result.sort { $0.condition < $1.condition }
        case .conditionZA:
            result.sort { $0.condition > $1.condition }
        }
        
        return result
    }
    
    var body: some View {
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
                    showingAddVisit = true
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
        }
        .sheet(isPresented: $showingAddVisit) {
            AddVisitView()
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(filterOptions: $filterOptions)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            // Title row with settings button
            HStack {
                Text(languageManager.localized("home.title"))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Theme.Colors.text)

                Spacer()

                // Settings button
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)

            // Search bar
            SearchBar(text: $searchText, placeholder: languageManager.localized("home.search"))
                .padding(.horizontal, Theme.Spacing.md)

            // View mode toggle and filter
            HStack {
                // View mode toggle
                HStack(spacing: 0) {
                    Button {
                        withAnimation(Theme.Animation.quick) {
                            viewMode = .grid
                        }
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)
                            .foregroundColor(viewMode == .grid ? .white : Theme.Colors.text)
                            .frame(width: 44, height: 36)
                            .background(viewMode == .grid ? Theme.Colors.primary : Color.clear)
                    }

                    Button {
                        withAnimation(Theme.Animation.quick) {
                            viewMode = .list
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.title3)
                            .foregroundColor(viewMode == .list ? .white : Theme.Colors.text)
                            .frame(width: 44, height: 36)
                            .background(viewMode == .list ? Theme.Colors.primary : Color.clear)
                    }
                }
                .background(Theme.Colors.primary.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.small)

                Spacer()

                // Filter button
                Button {
                    showingFilterSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: filterOptions.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        Text(languageManager.localized("home.filter"))
                    }
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(filterOptions.isActive ? .white : Theme.Colors.primary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(filterOptions.isActive ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.sm)
        }
        .padding(.top, Theme.Spacing.sm)
        .background(Theme.Colors.background)
    }
}
