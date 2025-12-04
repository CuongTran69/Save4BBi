//
//  AddChildView.swift
//  Save4BBi
//
//  Created by Cường Trần on 04/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared
    
    // Edit mode
    var childToEdit: Child?
    
    @State private var name = ""
    @State private var dateOfBirth = Date()
    @State private var gender: Gender = .other
    @State private var bloodType: BloodType = .unknown
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    
    private var isEditing: Bool { childToEdit != nil }
    private var isFormValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    avatarSection
                    basicInfoSection
                    notesSection
                }
                .padding(Theme.Spacing.md)
            }
            .dismissKeyboardOnTap()
            .background(Theme.Colors.background)
            .navigationTitle(isEditing ? lang.localized("child.edit") : lang.localized("child.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.save")) { saveChild() }
                        .disabled(!isFormValid)
                }
            }
            .onAppear { loadExistingData() }
        }
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Group {
                    if let avatarImage = avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                            Text("Add Photo")
                                .font(Theme.Typography.caption)
                        }
                        .foregroundColor(Theme.Colors.primary)
                    }
                }
                .frame(width: 100, height: 100)
                .background(Theme.Colors.primary.opacity(0.1))
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 2))
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        avatarImage = image
                    }
                }
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Name
            FormField(title: lang.localized("child.name"), placeholder: lang.localized("child.name.placeholder"), text: $name)
            
            // Date of Birth
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(lang.localized("child.dob"))
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.text.opacity(0.7))
                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            // Gender
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(lang.localized("child.gender"))
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.text.opacity(0.7))
                Picker("", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(genderLabel(g)).tag(g)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Blood Type
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(lang.localized("child.blood_type"))
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.text.opacity(0.7))
                Picker("", selection: $bloodType) {
                    ForEach(BloodType.allCases, id: \.self) { bt in
                        Text(bt.rawValue).tag(bt)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("child.notes"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            TextEditor(text: $notes)
                .font(Theme.Typography.body)
                .frame(minHeight: 80)
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.small)
                .overlay(RoundedRectangle(cornerRadius: Theme.CornerRadius.small).stroke(Theme.Colors.divider, lineWidth: 1))
        }
    }
    
    // MARK: - Helpers
    private func genderLabel(_ g: Gender) -> String {
        switch g {
        case .male: return lang.localized("child.gender.male")
        case .female: return lang.localized("child.gender.female")
        case .other: return lang.localized("child.gender.other")
        }
    }
    
    private func loadExistingData() {
        guard let child = childToEdit else { return }
        name = child.name
        dateOfBirth = child.dateOfBirth
        gender = child.gender
        bloodType = child.bloodType
        notes = child.notes
        if let data = child.avatarData { avatarImage = UIImage(data: data) }
    }
    
    private func saveChild() {
        let avatarData = avatarImage?.jpegData(compressionQuality: 0.8)
        
        if let child = childToEdit {
            child.name = name.trimmingCharacters(in: .whitespaces)
            child.dateOfBirth = dateOfBirth
            child.gender = gender
            child.bloodType = bloodType
            child.notes = notes
            child.avatarData = avatarData
            child.updatedAt = Date()
        } else {
            let newChild = Child(name: name.trimmingCharacters(in: .whitespaces), dateOfBirth: dateOfBirth, gender: gender, bloodType: bloodType, avatarData: avatarData, notes: notes)
            modelContext.insert(newChild)
            ChildManager.shared.selectChild(newChild)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

