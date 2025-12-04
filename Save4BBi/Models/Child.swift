//
//  Child.swift
//  Save4BBi
//
//  Created by Cường Trần on 04/12/25.
//

import Foundation
import SwiftData

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var icon: String {
        switch self {
        case .male: return "👦"
        case .female: return "👧"
        case .other: return "🧒"
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

@Model
final class Child: Identifiable {
    var id: UUID
    var name: String
    var dateOfBirth: Date
    var gender: Gender
    var bloodType: BloodType
    var avatarData: Data?
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date = Date(),
        gender: Gender = .other,
        bloodType: BloodType = .unknown,
        avatarData: Data? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.bloodType = bloodType
        self.avatarData = avatarData
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Computed Properties
extension Child {
    var age: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: dateOfBirth, to: now)
        
        if let years = components.year, years > 0 {
            if let months = components.month, months > 0 {
                return "\(years)y \(months)m"
            }
            return "\(years)y"
        } else if let months = components.month, months > 0 {
            return "\(months)m"
        }
        return "< 1m"
    }
    
    var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dateOfBirth)
    }
    
    var avatarIcon: String {
        gender.icon
    }
}

// MARK: - Sample Data
extension Child {
    static var sample: Child {
        Child(
            name: "Bé Bống",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            gender: .female,
            bloodType: .aPositive
        )
    }
    
    static var samples: [Child] {
        [
            Child(
                name: "Bé Bống",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                gender: .female,
                bloodType: .aPositive
            ),
            Child(
                name: "Bé Bi",
                dateOfBirth: Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date(),
                gender: .male,
                bloodType: .oPositive
            )
        ]
    }
}

