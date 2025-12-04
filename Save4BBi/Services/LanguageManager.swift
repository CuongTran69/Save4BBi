//
//  LanguageManager.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case vietnamese = "vi"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .vietnamese: return "Tiếng Việt"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .vietnamese: return "🇻🇳"
        }
    }
}

@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let languageKey = "app_language"
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Default to device language or English
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = deviceLanguage == "vi" ? .vietnamese : .english
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
    
    // MARK: - Localized Strings
    func localized(_ key: String) -> String {
        return LocalizedStrings.get(key, language: currentLanguage)
    }
}

// MARK: - Localized Strings Database
struct LocalizedStrings {
    static func get(_ key: String, language: AppLanguage) -> String {
        let strings = language == .english ? english : vietnamese
        return strings[key] ?? key
    }
    
    // MARK: - English Strings
    static let english: [String: String] = [
        // Home
        "home.title": "Medical Visits",
        "home.search": "Search...",
        "home.filter": "Filter",
        "home.empty.title": "No Medical Visits Yet",
        "home.empty.subtitle": "Tap the + button to add your first visit",
        
        // Visit Card
        "visit.photos": "photos",
        "visit.photo": "photo",
        "visit.tap_to_view": "Tap to view",
        
        // Add/Edit Visit
        "visit.add.title": "New Visit",
        "visit.edit.title": "Edit Visit",
        "visit.date": "Visit Date",
        "visit.title": "Title",
        "visit.title.placeholder": "e.g., Annual Checkup",
        "visit.condition": "Condition",
        "visit.condition.placeholder": "e.g., Fever, Cold",
        "visit.doctor": "Doctor Name",
        "visit.doctor.placeholder": "e.g., Dr. Smith",
        "visit.hospital": "Hospital",
        "visit.hospital.placeholder": "e.g., City Hospital",
        "visit.diagnosis": "Diagnosis",
        "visit.diagnosis.placeholder": "Enter diagnosis...",
        "visit.prescription": "Prescription",
        "visit.prescription.placeholder": "Enter prescription...",
        "visit.notes": "Notes",
        "visit.notes.placeholder": "Additional notes...",
        "visit.photos.title": "Photos",
        "visit.photos.add": "Add Photos",
        
        // Buttons
        "button.save": "Save",
        "button.cancel": "Cancel",
        "button.delete": "Delete",
        "button.done": "Done",
        "button.edit": "Edit",
        
        // Settings
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.about": "About",
        "settings.version": "Version",
        "settings.author": "Author",
        "settings.copyright": "Copyright",
        
        // Filter
        "filter.title": "Filter",
        "filter.date_range": "Date Range",
        "filter.from": "From",
        "filter.to": "To",
        "filter.condition": "Condition",
        "filter.doctor": "Doctor",
        "filter.reset": "Reset Filters",
        "filter.apply": "Apply",
        
        // Delete
        "delete.title": "Delete Visit",
        "delete.message": "Are you sure you want to delete this visit? This action cannot be undone.",

        // Visit Info Section
        "visit.info.title": "Visit Information",
        "visit.photos.select": "Tap to select from gallery",
        "visit.saving": "Saving photos...",
        "visit.tags": "Tags",
        "visit.condition.required": "Condition *",

        // Tags
        "tag.checkup": "Checkup",
        "tag.vaccination": "Vaccination",
        "tag.emergency": "Emergency",
        "tag.dental": "Dental",
        "tag.fever": "Fever",
        "tag.routine": "Routine",

        // Errors
        "error.title": "Error",
        "error.save_photos": "Failed to save photos",
        "error.save_visit": "Failed to save visit",
        "error.ok": "OK",
    ]
    
    // MARK: - Vietnamese Strings
    static let vietnamese: [String: String] = [
        // Home
        "home.title": "Lịch Khám Bệnh",
        "home.search": "Tìm kiếm...",
        "home.filter": "Lọc",
        "home.empty.title": "Chưa Có Lịch Khám",
        "home.empty.subtitle": "Nhấn nút + để thêm lần khám đầu tiên",
        
        // Visit Card
        "visit.photos": "ảnh",
        "visit.photo": "ảnh",
        "visit.tap_to_view": "Nhấn để xem",
        
        // Add/Edit Visit
        "visit.add.title": "Thêm Lần Khám",
        "visit.edit.title": "Sửa Lần Khám",
        "visit.date": "Ngày Khám",
        "visit.title": "Tiêu Đề",
        "visit.title.placeholder": "VD: Khám định kỳ",
        "visit.condition": "Tình Trạng",
        "visit.condition.placeholder": "VD: Sốt, Cảm cúm",
        "visit.doctor": "Bác Sĩ",
        "visit.doctor.placeholder": "VD: BS. Nguyễn Văn A",
        "visit.hospital": "Bệnh Viện",
        "visit.hospital.placeholder": "VD: BV Nhi Đồng 1",
        "visit.diagnosis": "Chẩn Đoán",
        "visit.diagnosis.placeholder": "Nhập chẩn đoán...",
        "visit.prescription": "Đơn Thuốc",
        "visit.prescription.placeholder": "Nhập đơn thuốc...",
        "visit.notes": "Ghi Chú",
        "visit.notes.placeholder": "Ghi chú thêm...",
        "visit.photos.title": "Hình Ảnh",
        "visit.photos.add": "Thêm Ảnh",
        
        // Buttons
        "button.save": "Lưu",
        "button.cancel": "Hủy",
        "button.delete": "Xóa",
        "button.done": "Xong",
        "button.edit": "Sửa",
        
        // Settings
        "settings.title": "Cài Đặt",
        "settings.language": "Ngôn Ngữ",
        "settings.about": "Thông Tin",
        "settings.version": "Phiên Bản",
        "settings.author": "Tác Giả",
        "settings.copyright": "Bản Quyền",
        
        // Filter
        "filter.title": "Lọc",
        "filter.date_range": "Khoảng Thời Gian",
        "filter.from": "Từ",
        "filter.to": "Đến",
        "filter.condition": "Tình Trạng",
        "filter.doctor": "Bác Sĩ",
        "filter.reset": "Xóa Bộ Lọc",
        "filter.apply": "Áp Dụng",
        
        // Delete
        "delete.title": "Xóa Lần Khám",
        "delete.message": "Bạn có chắc muốn xóa lần khám này? Hành động này không thể hoàn tác.",

        // Visit Info Section
        "visit.info.title": "Thông Tin Khám",
        "visit.photos.select": "Nhấn để chọn từ thư viện",
        "visit.saving": "Đang lưu ảnh...",
        "visit.tags": "Nhãn",
        "visit.condition.required": "Tình Trạng *",

        // Tags
        "tag.checkup": "Khám Định Kỳ",
        "tag.vaccination": "Tiêm Chủng",
        "tag.emergency": "Cấp Cứu",
        "tag.dental": "Nha Khoa",
        "tag.fever": "Sốt",
        "tag.routine": "Thường Quy",

        // Errors
        "error.title": "Lỗi",
        "error.save_photos": "Không thể lưu ảnh",
        "error.save_visit": "Không thể lưu lần khám",
        "error.ok": "OK",
    ]
}

