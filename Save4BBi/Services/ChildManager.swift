//
//  ChildManager.swift
//  Save4BBi
//
//  Created by Cường Trần on 04/12/25.
//

import Foundation
import SwiftUI

@MainActor
class ChildManager: ObservableObject {
    static let shared = ChildManager()
    
    private let selectedChildKey = "selectedChildId"
    
    @Published var selectedChildId: UUID? {
        didSet {
            saveSelectedChild()
        }
    }
    
    private init() {
        loadSelectedChild()
    }
    
    // MARK: - Persistence
    private func saveSelectedChild() {
        if let id = selectedChildId {
            UserDefaults.standard.set(id.uuidString, forKey: selectedChildKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedChildKey)
        }
    }
    
    private func loadSelectedChild() {
        if let idString = UserDefaults.standard.string(forKey: selectedChildKey),
           let id = UUID(uuidString: idString) {
            selectedChildId = id
        }
    }
    
    // MARK: - Helper Methods
    func selectChild(_ child: Child?) {
        selectedChildId = child?.id
    }
    
    func isSelected(_ child: Child) -> Bool {
        selectedChildId == child.id
    }
    
    func clearSelection() {
        selectedChildId = nil
    }
}

