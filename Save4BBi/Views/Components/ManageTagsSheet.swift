//
//  ManageTagsSheet.swift
//  MediFamily
//
//  Created by Cường Trần on 10/12/25.
//

import SwiftUI
import SwiftData

struct ManageTagsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.createdAt) private var allTags: [Tag]
    @ObservedObject private var lang = LanguageManager.shared
    
    @State private var showAddTagSheet = false
    @State private var tagToEdit: Tag?
    @State private var tagToDelete: Tag?
    @State private var showDeleteAlert = false
    
    private var defaultTags: [Tag] {
        allTags.filter { $0.isDefault }
    }
    
    private var customTags: [Tag] {
        allTags.filter { !$0.isDefault }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Custom Tags Section
                if !customTags.isEmpty {
                    Section {
                        ForEach(customTags) { tag in
                            tagRow(tag, canDelete: true)
                        }
                    } header: {
                        Text(lang.localized("tag.custom"))
                    }
                }
                
                // Default Tags Section
                Section {
                    ForEach(defaultTags) { tag in
                        tagRow(tag, canDelete: false)
                    }
                } header: {
                    Text(lang.localized("tag.default"))
                } footer: {
                    Text(lang.localized("tag.cannot_delete_default"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(lang.localized("tag.manage"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.done")) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddTagSheet = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddTagSheet) {
                AddTagSheet()
            }
            .sheet(item: $tagToEdit) { tag in
                EditTagSheet(tag: tag)
            }
            .alert(lang.localized("tag.delete"), isPresented: $showDeleteAlert) {
                Button(lang.localized("button.cancel"), role: .cancel) {}
                Button(lang.localized("button.delete"), role: .destructive) {
                    if let tag = tagToDelete {
                        _ = TagManager.shared.deleteTag(tag, context: modelContext)
                    }
                }
            } message: {
                Text(lang.localized("tag.delete_confirm"))
            }
        }
    }
    
    private func tagRow(_ tag: Tag, canDelete: Bool) -> some View {
        HStack {
            Text(tag.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tag.name)
                    .font(.body)
                if tag.nameVI != tag.name {
                    Text(tag.nameVI)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(Color(hex: tag.colorHex))
                .frame(width: 20, height: 20)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !tag.isDefault {
                tagToEdit = tag
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if canDelete {
                Button(role: .destructive) {
                    tagToDelete = tag
                    showDeleteAlert = true
                } label: {
                    Label(lang.localized("button.delete"), systemImage: "trash")
                }
            }
            
            if !tag.isDefault {
                Button {
                    tagToEdit = tag
                } label: {
                    Label(lang.localized("button.edit"), systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
    }
}

