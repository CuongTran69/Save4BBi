//
//  MemberManager.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import Foundation
import SwiftUI

@MainActor
class MemberManager: ObservableObject {
    static let shared = MemberManager()
    
    private let selectedMemberKey = "selectedMemberId"
    
    @Published var selectedMemberId: UUID? {
        didSet {
            saveSelectedMember()
        }
    }
    
    private init() {
        loadSelectedMember()
    }
    
    // MARK: - Persistence
    private func saveSelectedMember() {
        if let id = selectedMemberId {
            UserDefaults.standard.set(id.uuidString, forKey: selectedMemberKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedMemberKey)
        }
    }
    
    private func loadSelectedMember() {
        if let idString = UserDefaults.standard.string(forKey: selectedMemberKey),
           let id = UUID(uuidString: idString) {
            selectedMemberId = id
        }
    }
    
    // MARK: - Helper Methods
    func selectMember(_ member: FamilyMember?) {
        selectedMemberId = member?.id
    }
    
    func isSelected(_ member: FamilyMember) -> Bool {
        selectedMemberId == member.id
    }
    
    func clearSelection() {
        selectedMemberId = nil
    }
}

