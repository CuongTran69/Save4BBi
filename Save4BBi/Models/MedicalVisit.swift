//
//  MedicalVisit.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation
import SwiftData

// MARK: - Recovery Status Enum
enum RecoveryStatus: String, Codable, CaseIterable {
    case ongoing = "ongoing"       // Đang điều trị
    case recovered = "recovered"   // Đã khỏi
    case chronic = "chronic"       // Bệnh mãn tính
    case unknown = "unknown"       // Không xác định

    var displayName: String {
        switch self {
        case .ongoing: return "Đang điều trị"
        case .recovered: return "Đã khỏi"
        case .chronic: return "Bệnh mãn tính"
        case .unknown: return "Không xác định"
        }
    }

    var displayNameEN: String {
        switch self {
        case .ongoing: return "Ongoing"
        case .recovered: return "Recovered"
        case .chronic: return "Chronic"
        case .unknown: return "Unknown"
        }
    }

    var icon: String {
        switch self {
        case .ongoing: return "clock.arrow.circlepath"
        case .recovered: return "checkmark.circle.fill"
        case .chronic: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark.circle"
        }
    }
}

@Model
final class MedicalVisit: Identifiable {
    var id: UUID
    var title: String
    var condition: String
    var doctorName: String
    var notes: String
    var visitDate: Date
    var createdAt: Date
    var updatedAt: Date

    // Photo file paths (stored in app's document directory)
    var photoFilePaths: [String]

    // Tags/Categories
    var tags: [String]

    // Family member ID (supports all family members)
    var memberId: UUID?

    // NEW: Symptoms (triệu chứng)
    var symptoms: String

    // NEW: Medications/Prescriptions (thuốc được kê)
    var medications: String

    // NEW: Recovery status (tình trạng khỏi bệnh)
    var recoveryStatusRaw: String

    init(
        id: UUID = UUID(),
        title: String,
        condition: String,
        doctorName: String = "",
        notes: String = "",
        visitDate: Date = Date(),
        photoFilePaths: [String] = [],
        tags: [String] = [],
        memberId: UUID? = nil,
        symptoms: String = "",
        medications: String = "",
        recoveryStatus: RecoveryStatus = .unknown
    ) {
        self.id = id
        self.title = title
        self.condition = condition
        self.doctorName = doctorName
        self.notes = notes
        self.visitDate = visitDate
        self.createdAt = Date()
        self.updatedAt = Date()
        self.photoFilePaths = photoFilePaths
        self.tags = tags
        self.memberId = memberId
        self.symptoms = symptoms
        self.medications = medications
        self.recoveryStatusRaw = recoveryStatus.rawValue
    }

    // Computed property for RecoveryStatus
    var recoveryStatus: RecoveryStatus {
        get { RecoveryStatus(rawValue: recoveryStatusRaw) ?? .unknown }
        set { recoveryStatusRaw = newValue.rawValue }
    }
}

// MARK: - Computed Properties
extension MedicalVisit {
    // Static formatter to avoid expensive re-creation
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var formattedDate: String {
        Self.dateFormatter.string(from: visitDate)
    }
    
    var photoCount: Int {
        photoFilePaths.count
    }
    
    var hasPhotos: Bool {
        !photoFilePaths.isEmpty
    }
    
    var displayTitle: String {
        title.isEmpty ? condition : title
    }
}

// MARK: - Sample Data for Preview
extension MedicalVisit {
    static var sample: MedicalVisit {
        MedicalVisit(
            title: "Annual Checkup",
            condition: "Routine Examination",
            doctorName: "Dr. Nguyễn Văn A",
            notes: "Everything looks good. Height: 110cm, Weight: 20kg",
            visitDate: Date(),
            photoFilePaths: [],
            tags: ["Checkup", "Routine"]
        )
    }
    
    static var samples: [MedicalVisit] {
        [
            MedicalVisit(
                title: "Flu Vaccination",
                condition: "Vaccination",
                doctorName: "Dr. Trần Thị B",
                notes: "Seasonal flu vaccine administered",
                visitDate: Date().addingTimeInterval(-86400 * 7),
                tags: ["Vaccination"]
            ),
            MedicalVisit(
                title: "Fever Treatment",
                condition: "Fever",
                doctorName: "Dr. Lê Văn C",
                notes: "Temperature: 38.5°C. Prescribed paracetamol",
                visitDate: Date().addingTimeInterval(-86400 * 14),
                tags: ["Emergency", "Fever"]
            ),
            MedicalVisit(
                title: "Dental Checkup",
                condition: "Dental",
                doctorName: "Dr. Phạm Thị D",
                notes: "No cavities found. Good oral hygiene",
                visitDate: Date().addingTimeInterval(-86400 * 30),
                tags: ["Dental", "Checkup"]
            )
        ]
    }
}
