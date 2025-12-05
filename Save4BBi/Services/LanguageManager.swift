//
//  LanguageManager.swift
//  MediFamily
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
        "edit.new.photos": "new photos",
        "button.clear": "Clear",

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

        // Family Members
        "member.profiles": "Family Members",
        "member.add": "Add Member",
        "member.edit": "Edit Member",
        "member.name": "Name",
        "member.name.placeholder": "e.g., John Doe",
        "member.dob": "Date of Birth",
        "member.gender": "Gender",
        "member.gender.male": "Male",
        "member.gender.female": "Female",
        "member.gender.other": "Other",
        "member.blood_type": "Blood Type",
        "member.blood_type.unknown": "Unknown",
        "member.notes": "Notes",
        "member.notes.placeholder": "Allergies, medical conditions...",
        "member.all": "All Members",
        "member.select": "Select Member",
        "member.empty": "No family members yet. Add one to get started.",
        "member.delete.title": "Delete Member",
        "member.delete.message": "Are you sure you want to delete this member?",
        "member.delete.has_visits": "This member has {count} medical visit(s). What would you like to do?",
        "member.delete.keep_visits": "Delete member only (keep visits)",
        "member.delete.with_visits": "Delete member and all visits",
        "member.age": "Age",
        "member.visits": "visits",

        // Member Types
        "member.type": "Member Type",
        "member.type.child": "Child",
        "member.type.adult": "Adult",
        "member.type.senior": "Senior",

        // Relationships
        "member.relationship": "Relationship",
        "relation.father": "Father",
        "relation.mother": "Mother",
        "relation.child": "Child",
        "relation.grandfather": "Grandfather",
        "relation.grandmother": "Grandmother",
        "relation.spouse": "Spouse",
        "relation.sibling": "Sibling",
        "relation.other": "Other",

        // Adult/Senior Fields
        "member.height": "Height (cm)",
        "member.weight": "Weight (kg)",
        "member.bmi": "BMI",
        "member.chronic": "Chronic Conditions",
        "member.chronic.placeholder": "e.g., Diabetes, Hypertension",
        "member.medications": "Current Medications",
        "member.medications.placeholder": "e.g., Aspirin 100mg",
        "member.insurance": "Insurance ID",
        "member.insurance.placeholder": "e.g., BHYT123456",

        // Empty State
        "member.empty.title": "Your Family Awaits",
        "member.empty.subtitle": "Add family members to start tracking their medical visits and health records",
        "member.add.first": "Add First Member",
        "member.tip.1": "Track health records for everyone",
        "member.tip.2": "Store prescriptions & documents",
        "member.tip.3": "Never miss important checkups",

        // Add Member UI
        "member.photo.tap": "Tap to add",
        "member.info.basic": "Basic Information",
        "member.info.health": "Health Information",
        "bmi.underweight": "Underweight",
        "bmi.normal": "Normal",
        "bmi.overweight": "Overweight",
        "bmi.obese": "Obese",

        // Photo Source
        "photo.source.title": "Add Photo",
        "photo.source.camera": "Take Photo",
        "photo.source.camera.desc": "Use camera to capture",
        "photo.source.library": "Photo Library",
        "photo.source.library.desc": "Choose from gallery",
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
        "edit.new.photos": "ảnh mới",
        "button.clear": "Xóa",

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

        // Family Members
        "member.profiles": "Thành Viên Gia Đình",
        "member.add": "Thêm Thành Viên",
        "member.edit": "Sửa Hồ Sơ",
        "member.name": "Tên",
        "member.name.placeholder": "VD: Nguyễn Văn A",
        "member.dob": "Ngày Sinh",
        "member.gender": "Giới Tính",
        "member.gender.male": "Nam",
        "member.gender.female": "Nữ",
        "member.gender.other": "Khác",
        "member.blood_type": "Nhóm Máu",
        "member.blood_type.unknown": "Không rõ",
        "member.notes": "Ghi Chú",
        "member.notes.placeholder": "Dị ứng, bệnh mãn tính...",
        "member.all": "Tất Cả",
        "member.select": "Chọn Thành Viên",
        "member.empty": "Chưa có thành viên. Thêm mới để bắt đầu.",
        "member.delete.title": "Xóa Thành Viên",
        "member.delete.message": "Bạn có chắc muốn xóa thành viên này?",
        "member.delete.has_visits": "Thành viên này có {count} lần khám. Bạn muốn làm gì?",
        "member.delete.keep_visits": "Chỉ xóa thành viên (giữ hồ sơ khám)",
        "member.delete.with_visits": "Xóa thành viên và tất cả hồ sơ khám",
        "member.age": "Tuổi",
        "member.visits": "lần khám",

        // Member Types
        "member.type": "Loại Thành Viên",
        "member.type.child": "Trẻ Em",
        "member.type.adult": "Người Lớn",
        "member.type.senior": "Người Cao Tuổi",

        // Relationships
        "member.relationship": "Quan Hệ",
        "relation.father": "Bố",
        "relation.mother": "Mẹ",
        "relation.child": "Con",
        "relation.grandfather": "Ông",
        "relation.grandmother": "Bà",
        "relation.spouse": "Vợ/Chồng",
        "relation.sibling": "Anh/Chị/Em",
        "relation.other": "Khác",

        // Adult/Senior Fields
        "member.height": "Chiều Cao (cm)",
        "member.weight": "Cân Nặng (kg)",
        "member.bmi": "BMI",
        "member.chronic": "Bệnh Mãn Tính",
        "member.chronic.placeholder": "VD: Tiểu đường, Cao huyết áp",
        "member.medications": "Thuốc Đang Dùng",
        "member.medications.placeholder": "VD: Aspirin 100mg",
        "member.insurance": "Số BHYT",
        "member.insurance.placeholder": "VD: DN1234567890",

        // Empty State
        "member.empty.title": "Gia Đình Của Bạn",
        "member.empty.subtitle": "Thêm thành viên để bắt đầu theo dõi lịch khám và hồ sơ sức khỏe",
        "member.add.first": "Thêm Thành Viên Đầu Tiên",
        "member.tip.1": "Theo dõi sức khỏe cho cả nhà",
        "member.tip.2": "Lưu trữ đơn thuốc & tài liệu",
        "member.tip.3": "Không bỏ lỡ lịch khám quan trọng",

        // Add Member UI
        "member.photo.tap": "Nhấn để thêm",
        "member.info.basic": "Thông Tin Cơ Bản",
        "member.info.health": "Thông Tin Sức Khỏe",
        "bmi.underweight": "Thiếu cân",
        "bmi.normal": "Bình thường",
        "bmi.overweight": "Thừa cân",
        "bmi.obese": "Béo phì",

        // Photo Source
        "photo.source.title": "Thêm Ảnh",
        "photo.source.camera": "Chụp Ảnh",
        "photo.source.camera.desc": "Dùng camera để chụp",
        "photo.source.library": "Thư Viện Ảnh",
        "photo.source.library.desc": "Chọn từ bộ sưu tập",
    ]
}

