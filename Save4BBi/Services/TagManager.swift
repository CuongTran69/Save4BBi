//
//  TagManager.swift
//  MediFamily
//
//  Created by Cường Trần on 10/12/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class TagManager: ObservableObject {
    static let shared = TagManager()
    
    @Published var selectedFilterTags: Set<UUID> = []
    
    private init() {}
    
    // MARK: - CRUD Operations
    
    /// Initialize default tags if none exist
    func initializeDefaultTags(context: ModelContext) {
        let descriptor = FetchDescriptor<Tag>()
        let existingTags = (try? context.fetch(descriptor)) ?? []
        
        if existingTags.isEmpty {
            for tag in Tag.defaultTags {
                context.insert(tag)
            }
            try? context.save()
        }
    }
    
    /// Add a new custom tag
    func addTag(name: String, nameVI: String, icon: String = "🏷️", colorHex: String = "A8D8EA", context: ModelContext) -> Tag {
        let tag = Tag(name: name, nameVI: nameVI, icon: icon, colorHex: colorHex, isDefault: false)
        context.insert(tag)
        try? context.save()
        return tag
    }
    
    /// Update an existing tag
    func updateTag(_ tag: Tag, name: String, nameVI: String, icon: String, colorHex: String, context: ModelContext) {
        tag.name = name
        tag.nameVI = nameVI
        tag.icon = icon
        tag.colorHex = colorHex
        tag.updatedAt = Date()
        try? context.save()
    }
    
    /// Delete a tag (only non-default tags)
    func deleteTag(_ tag: Tag, context: ModelContext) -> Bool {
        guard !tag.isDefault else { return false }
        context.delete(tag)
        try? context.save()
        
        // Remove from filter if selected
        selectedFilterTags.remove(tag.id)
        return true
    }
    
    // MARK: - Filter Operations
    
    func toggleFilterTag(_ tagId: UUID) {
        if selectedFilterTags.contains(tagId) {
            selectedFilterTags.remove(tagId)
        } else {
            selectedFilterTags.insert(tagId)
        }
    }
    
    func clearFilterTags() {
        selectedFilterTags.removeAll()
    }
    
    func isTagSelected(_ tagId: UUID) -> Bool {
        selectedFilterTags.contains(tagId)
    }
    
    // MARK: - Helpers
    
    /// Get tag names from tag IDs
    func getTagNames(from tagIds: [String], allTags: [Tag]) -> [String] {
        tagIds.compactMap { idString -> String? in
            guard let uuid = UUID(uuidString: idString) else {
                // Legacy support: return the string itself if not a UUID
                return idString
            }
            return allTags.first { $0.id == uuid }?.localizedName
        }
    }
    
    /// Check if a visit matches the filter tags
    func visitMatchesFilter(_ visit: MedicalVisit, allTags: [Tag]) -> Bool {
        if selectedFilterTags.isEmpty { return true }
        
        let visitTagIds = Set(visit.tags.compactMap { UUID(uuidString: $0) })
        return !selectedFilterTags.isDisjoint(with: visitTagIds)
    }
}

// Note: Color(hex:) extension is defined in Theme.swift

