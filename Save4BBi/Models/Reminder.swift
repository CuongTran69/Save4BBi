//
//  Reminder.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import Foundation
import SwiftData

@Model
final class Reminder {
    var id: UUID
    var title: String
    var message: String
    var scheduledDate: Date
    var createdAt: Date
    var isCompleted: Bool
    
    // Reference to the visit
    var visitId: UUID?
    var visitTitle: String?
    
    // Reference to the member
    var memberId: UUID?
    var memberName: String?
    
    // Notification identifier for cancellation
    var notificationId: String
    
    init(
        title: String,
        message: String,
        scheduledDate: Date,
        visitId: UUID? = nil,
        visitTitle: String? = nil,
        memberId: UUID? = nil,
        memberName: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.scheduledDate = scheduledDate
        self.createdAt = Date()
        self.isCompleted = false
        self.visitId = visitId
        self.visitTitle = visitTitle
        self.memberId = memberId
        self.memberName = memberName
        self.notificationId = UUID().uuidString
    }
    
    // MARK: - Computed Properties
    
    var isPast: Bool {
        scheduledDate < Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }
    
    var daysUntil: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: scheduledDate)
        return components.day ?? 0
    }
}

