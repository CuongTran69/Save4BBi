//
//  FamilyMember.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import Foundation
import SwiftData

// MARK: - Enums

enum MemberType: String, Codable, CaseIterable {
    case child = "child"
    case adult = "adult"
    case senior = "senior"
    
    var icon: String {
        switch self {
        case .child: return "👶"
        case .adult: return "👤"
        case .senior: return "👴"
        }
    }
    
    var defaultAge: Int {
        switch self {
        case .child: return 5
        case .adult: return 30
        case .senior: return 65
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    func icon(for memberType: MemberType) -> String {
        switch (self, memberType) {
        case (.male, .child): return "👦"
        case (.female, .child): return "👧"
        case (.other, .child): return "🧒"
        case (.male, .adult): return "👨"
        case (.female, .adult): return "👩"
        case (.other, .adult): return "🧑"
        case (.male, .senior): return "👴"
        case (.female, .senior): return "👵"
        case (.other, .senior): return "🧓"
        }
    }
}

enum BloodType: String, Codable, CaseIterable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"
    case unknown = "Unknown"
}

enum Relationship: String, Codable, CaseIterable {
    case father = "father"
    case mother = "mother"
    case child = "child"
    case grandfather = "grandfather"
    case grandmother = "grandmother"
    case spouse = "spouse"
    case sibling = "sibling"
    case other = "other"
    
    var icon: String {
        switch self {
        case .father: return "👨"
        case .mother: return "👩"
        case .child: return "👶"
        case .grandfather: return "👴"
        case .grandmother: return "👵"
        case .spouse: return "💑"
        case .sibling: return "👫"
        case .other: return "👤"
        }
    }
}

// MARK: - FamilyMember Model

@Model
final class FamilyMember: Identifiable {
    var id: UUID
    var name: String
    var dateOfBirth: Date
    var memberType: MemberType
    var gender: Gender
    var bloodType: BloodType
    var relationship: Relationship
    var avatarData: Data?
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    // Adult/Senior specific fields
    var height: Double?              // cm
    var weight: Double?              // kg
    var chronicConditions: [String]
    var currentMedications: [String]
    var insuranceId: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date = Date(),
        memberType: MemberType = .child,
        gender: Gender = .other,
        bloodType: BloodType = .unknown,
        relationship: Relationship = .child,
        avatarData: Data? = nil,
        notes: String = "",
        height: Double? = nil,
        weight: Double? = nil,
        chronicConditions: [String] = [],
        currentMedications: [String] = [],
        insuranceId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.memberType = memberType
        self.gender = gender
        self.bloodType = bloodType
        self.relationship = relationship
        self.avatarData = avatarData
        self.notes = notes
        self.height = height
        self.weight = weight
        self.chronicConditions = chronicConditions
        self.currentMedications = currentMedications
        self.insuranceId = insuranceId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Computed Properties
extension FamilyMember {
    // Static formatters to avoid expensive re-creation
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let calendar = Calendar.current

    var age: String {
        let now = Date()
        let components = Self.calendar.dateComponents([.year, .month], from: dateOfBirth, to: now)

        if let years = components.year, years > 0 {
            if memberType == .child, let months = components.month, months > 0 {
                return "\(years)y \(months)m"
            }
            return "\(years)y"
        } else if let months = components.month, months > 0 {
            return "\(months)m"
        }
        return "< 1m"
    }

    var ageInYears: Int {
        Self.calendar.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var formattedBirthDate: String {
        Self.dateFormatter.string(from: dateOfBirth)
    }

    var avatarIcon: String {
        gender.icon(for: memberType)
    }

    var bmi: Double? {
        guard let h = height, let w = weight, h > 0 else { return nil }
        let heightInMeters = h / 100.0
        return w / (heightInMeters * heightInMeters)
    }

    var formattedBMI: String? {
        guard let bmi = bmi else { return nil }
        return String(format: "%.1f", bmi)
    }
}

// MARK: - Sample Data
extension FamilyMember {
    static var sample: FamilyMember {
        FamilyMember(
            name: "Bé Bống",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            memberType: .child,
            gender: .female,
            bloodType: .aPositive,
            relationship: .child
        )
    }

    static var samples: [FamilyMember] {
        [
            FamilyMember(
                name: "Bé Bống",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                memberType: .child,
                gender: .female,
                bloodType: .aPositive,
                relationship: .child
            ),
            FamilyMember(
                name: "Mẹ Mai",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -32, to: Date()) ?? Date(),
                memberType: .adult,
                gender: .female,
                bloodType: .oPositive,
                relationship: .mother,
                height: 160,
                weight: 55
            ),
            FamilyMember(
                name: "Bố Hùng",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
                memberType: .adult,
                gender: .male,
                bloodType: .bPositive,
                relationship: .father,
                height: 172,
                weight: 70
            ),
            FamilyMember(
                name: "Ông Nội",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -68, to: Date()) ?? Date(),
                memberType: .senior,
                gender: .male,
                bloodType: .aPositive,
                relationship: .grandfather,
                height: 165,
                weight: 62,
                chronicConditions: ["Cao huyết áp"],
                currentMedications: ["Amlodipine 5mg"]
            )
        ]
    }
}

