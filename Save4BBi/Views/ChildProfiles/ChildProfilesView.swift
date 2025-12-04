//
//  ChildProfilesView.swift
//  Save4BBi
//
//  Created by Cường Trần on 04/12/25.
//

import SwiftUI
import SwiftData

struct ChildProfilesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Child.createdAt) private var children: [Child]
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var childManager = ChildManager.shared
    
    @State private var showingAddChild = false
    @State private var childToEdit: Child?
    @State private var childToDelete: Child?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    if children.isEmpty {
                        emptyStateView
                    } else {
                        childListView
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("child.profiles"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.done")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddChild = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
            }
            .sheet(item: $childToEdit) { child in
                AddChildView(childToEdit: child)
            }
            .alert(lang.localized("child.delete.title"), isPresented: $showingDeleteAlert) {
                Button(lang.localized("button.cancel"), role: .cancel) { }
                Button(lang.localized("button.delete"), role: .destructive) {
                    if let child = childToDelete {
                        deleteChild(child)
                    }
                }
            } message: {
                Text(lang.localized("child.delete.message"))
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer().frame(height: 60)
            
            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.primary.opacity(0.6))
            
            Text(lang.localized("child.add"))
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            Button {
                showingAddChild = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(lang.localized("child.add"))
                }
                .font(Theme.Typography.bodyBold)
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.primary)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Child List
    private var childListView: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(children) { child in
                ChildRowView(
                    child: child,
                    isSelected: childManager.isSelected(child),
                    onTap: {
                        childManager.selectChild(child)
                        dismiss()
                    },
                    onEdit: {
                        childToEdit = child
                    },
                    onDelete: {
                        childToDelete = child
                        showingDeleteAlert = true
                    }
                )
            }
        }
    }
    
    // MARK: - Delete Child
    private func deleteChild(_ child: Child) {
        if childManager.isSelected(child) {
            childManager.clearSelection()
        }
        modelContext.delete(child)
        try? modelContext.save()
    }
}

// MARK: - Child Row View
struct ChildRowView: View {
    let child: Child
    let isSelected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                // Avatar
                avatarView
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(Theme.Typography.bodyBold)
                        .foregroundColor(Theme.Colors.text)
                    
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(child.age)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                        
                        Text("•")
                            .foregroundColor(Theme.Colors.text.opacity(0.3))
                        
                        Text(child.bloodType.rawValue)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Actions
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.title2)
                }
                
                Menu {
                    Button { onEdit() } label: {
                        Label(lang.localized("button.edit"), systemImage: "pencil")
                    }
                    Button(role: .destructive) { onDelete() } label: {
                        Label(lang.localized("button.delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                        .padding(8)
                }
            }
            .padding(Theme.Spacing.md)
            .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var avatarView: some View {
        Group {
            if let avatarData = child.avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(child.avatarIcon)
                    .font(.system(size: 28))
            }
        }
        .frame(width: 50, height: 50)
        .background(Theme.Colors.primary.opacity(0.15))
        .clipShape(Circle())
    }
}

