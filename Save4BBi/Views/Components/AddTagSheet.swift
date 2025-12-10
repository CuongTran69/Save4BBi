//
//  AddTagSheet.swift
//  MediFamily
//
//  Created by Cường Trần on 10/12/25.
//

import SwiftUI
import SwiftData

struct AddTagSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared
    
    @State private var name = ""
    @State private var nameVI = ""
    @State private var selectedIcon = "🏷️"
    @State private var selectedColorHex = "A8D8EA"
    
    private let iconOptions = ["🏷️", "💊", "🏥", "🩹", "🧪", "👁️", "🦴", "🧠", "❤️", "🫁", "🦷", "👂", "🤧", "😷", "🤕", "🩺", "💉", "🚑", "⚕️", "🧬"]
    private let colorOptions = ["A8D8EA", "FFB6B9", "B4E7CE", "FFD93D", "C4B5E0", "F5A623", "7ED321", "4A90E2", "BD10E0", "9B9B9B"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(lang.localized("tag.name.placeholder"), text: $name)
                    TextField(lang.localized("tag.name_vi.placeholder"), text: $nameVI)
                } header: {
                    Text(lang.localized("tag.name"))
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Text(icon)
                                        .font(.title2)
                                        .padding(8)
                                        .background(selectedIcon == icon ? Theme.Colors.primary.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == icon ? Theme.Colors.primary : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text(lang.localized("tag.icon"))
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colorOptions, id: \.self) { hex in
                                Button {
                                    selectedColorHex = hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorHex == hex ? Color.black : Color.clear, lineWidth: 2)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .opacity(selectedColorHex == hex ? 1 : 0)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text(lang.localized("tag.color"))
                }
                
                // Preview
                Section {
                    HStack {
                        Text("\(selectedIcon) \(name.isEmpty ? "Preview" : name)")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: selectedColorHex))
                            .cornerRadius(8)
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(lang.localized("tag.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.save")) {
                        saveTag()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTag() {
        let viName = nameVI.isEmpty ? name : nameVI
        _ = TagManager.shared.addTag(
            name: name,
            nameVI: viName,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            context: modelContext
        )
        dismiss()
    }
}

