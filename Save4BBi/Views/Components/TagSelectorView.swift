//
//  TagSelectorView.swift
//  MediFamily
//
//  Created by Cường Trần on 10/12/25.
//

import SwiftUI
import SwiftData

struct TagSelectorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.createdAt) private var allTags: [Tag]
    @ObservedObject private var lang = LanguageManager.shared
    
    @Binding var selectedTagIds: Set<String>
    
    @State private var showAddTagSheet = false
    @State private var showManageTagsSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(lang.localized("visit.tags"))
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                Button {
                    showManageTagsSheet = true
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
            }
            
            VStack(spacing: Theme.Spacing.sm) {
                // Tags flow layout
                FlowLayout(spacing: Theme.Spacing.sm) {
                    ForEach(allTags) { tag in
                        TagChipButton(
                            tag: tag,
                            isSelected: selectedTagIds.contains(tag.id.uuidString)
                        ) {
                            toggleTag(tag)
                        }
                    }
                    
                    // Add custom tag button
                    Button {
                        showAddTagSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text(lang.localized("tag.add"))
                                .font(Theme.Typography.caption)
                        }
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.Colors.text.opacity(0.08))
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .cardStyle()
        }
        .sheet(isPresented: $showAddTagSheet) {
            AddTagSheet()
        }
        .sheet(isPresented: $showManageTagsSheet) {
            ManageTagsSheet()
        }
        .onAppear {
            TagManager.shared.initializeDefaultTags(context: modelContext)
        }
    }
    
    private func toggleTag(_ tag: Tag) {
        let tagId = tag.id.uuidString
        if selectedTagIds.contains(tagId) {
            selectedTagIds.remove(tagId)
        } else {
            selectedTagIds.insert(tagId)
        }
    }
}

// MARK: - Tag Chip Button
struct TagChipButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag.icon)
                    .font(.system(size: 12))
                Text(tag.localizedName)
                    .font(Theme.Typography.subheadline)
            }
            .foregroundColor(isSelected ? .white : Color(hex: tag.colorHex))
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Color(hex: tag.colorHex) : Color(hex: tag.colorHex).opacity(0.15))
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

