//
//  Tag.swift
//  MediFamily
//
//  Created by Cường Trần on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    var id: UUID
    var name: String
    var nameVI: String  // Vietnamese name
    var icon: String    // Emoji icon
    var colorHex: String
    var isDefault: Bool // System default tags cannot be deleted
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        nameVI: String = "",
        icon: String = "🏷️",
        colorHex: String = "A8D8EA",
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.nameVI = nameVI.isEmpty ? name : nameVI
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Computed Properties
extension Tag {
    /// Returns localized name based on current language
    @MainActor
    var localizedName: String {
        let lang = LanguageManager.shared.currentLanguage
        return lang == .vietnamese ? nameVI : name
    }

    /// Display text with icon
    @MainActor
    var displayText: String {
        "\(icon) \(localizedName)"
    }

    /// Non-main actor version for use in non-UI contexts
    func getLocalizedName(isVietnamese: Bool) -> String {
        return isVietnamese ? nameVI : name
    }
}

// MARK: - Default Tags
extension Tag {
    static var defaultTags: [Tag] {
        [
            Tag(name: "Checkup", nameVI: "Khám Định Kỳ", icon: "🩺", colorHex: "A8D8EA", isDefault: true),
            Tag(name: "Vaccination", nameVI: "Tiêm Chủng", icon: "💉", colorHex: "B4E7CE", isDefault: true),
            Tag(name: "Emergency", nameVI: "Cấp Cứu", icon: "🚨", colorHex: "FF6B9D", isDefault: true),
            Tag(name: "Dental", nameVI: "Nha Khoa", icon: "🦷", colorHex: "FFD93D", isDefault: true),
            Tag(name: "Fever", nameVI: "Sốt", icon: "🤒", colorHex: "FFB6B9", isDefault: true),
            Tag(name: "Routine", nameVI: "Thường Quy", icon: "📋", colorHex: "C4B5E0", isDefault: true)
        ]
    }
    
    static var sample: Tag {
        Tag(name: "Sample Tag", nameVI: "Nhãn Mẫu", icon: "🏷️", colorHex: "A8D8EA")
    }
}

