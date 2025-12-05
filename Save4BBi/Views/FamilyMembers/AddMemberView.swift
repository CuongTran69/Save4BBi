//
//  AddMemberView.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var lang = LanguageManager.shared

    // Edit mode
    var memberToEdit: FamilyMember?

    // Basic fields
    @State private var name = ""
    @State private var dateOfBirth = Date()
    @State private var memberType: MemberType = .child
    @State private var gender: Gender = .other
    @State private var bloodType: BloodType = .unknown
    @State private var relationship: Relationship = .child
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    // Adult/Senior fields
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var chronicConditions: String = ""
    @State private var currentMedications: String = ""
    @State private var insuranceId: String = ""

    // Animation & Photo source
    @State private var avatarScale: CGFloat = 1.0
    @State private var showPhotoSourceSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var cameraImage: UIImage?

    private var isEditing: Bool { memberToEdit != nil }
    private var isFormValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var showAdultFields: Bool { memberType != .child }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.Spacing.lg) {
                    avatarSection
                    memberTypeSection
                    basicInfoSection
                    if showAdultFields {
                        healthInfoSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    notesSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.sm)
            }
            .dismissKeyboardOnTap()
            .background(Theme.Colors.background)
            .navigationTitle(isEditing ? lang.localized("member.edit") : lang.localized("member.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) { dismiss() }
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveMember()
                    } label: {
                        Text(lang.localized("button.save"))
                            .fontWeight(.semibold)
                            .foregroundColor(isFormValid ? Theme.Colors.primary : Theme.Colors.text.opacity(0.3))
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear { loadExistingData() }
        }
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                // Background decorative ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Theme.Colors.primary.opacity(0.3), Theme.Colors.accent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 130, height: 130)

                Button {
                    showPhotoSourceSheet = true
                } label: {
                    ZStack {
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            // Gradient background
                            LinearGradient(
                                colors: [Theme.Colors.primary.opacity(0.15), Theme.Colors.accent.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 6) {
                                Text(gender.icon(for: memberType))
                                    .font(.system(size: 50))
                                Text(lang.localized("member.photo.tap"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Theme.Colors.primary.opacity(0.8))
                            }
                        }

                        // Camera badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        LinearGradient(
                                            colors: [Theme.Colors.primary, Theme.Colors.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(4)
                    }
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .scaleEffect(avatarScale)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
        .sheet(isPresented: $showPhotoSourceSheet) {
            PhotoSourceSheet(
                onCameraSelected: {
                    showPhotoSourceSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                },
                onLibrarySelected: {
                    showPhotoSourceSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLibrary = true
                    }
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showLibrary) {
            PhotosPickerSheet(selectedImage: $avatarImage)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(image: $cameraImage)
                .ignoresSafeArea()
        }
        .onChange(of: cameraImage) { _, newImage in
            if let image = newImage {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    avatarScale = 1.1
                }
                avatarImage = image
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                    avatarScale = 1.0
                }
                cameraImage = nil
            }
        }
    }

    // MARK: - Member Type Section
    private var memberTypeSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(icon: "person.fill", title: lang.localized("member.type"))

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(MemberType.allCases, id: \.self) { type in
                    memberTypeButton(type)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 2)
    }

    private func memberTypeButton(_ type: MemberType) -> some View {
        let isSelected = memberType == type
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                memberType = type
                updateDefaultRelationship(for: type)
            }
        } label: {
            VStack(spacing: 6) {
                Text(type.icon)
                    .font(.system(size: 28))
                Text(memberTypeLabel(type))
                    .font(.system(size: 12, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(isSelected ? memberTypeColor(type).opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? memberTypeColor(type) : Theme.Colors.divider, lineWidth: isSelected ? 2 : 1)
            )
            .foregroundColor(isSelected ? memberTypeColor(type) : Theme.Colors.text.opacity(0.6))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func memberTypeColor(_ type: MemberType) -> Color {
        switch type {
        case .child: return .blue
        case .adult: return .green
        case .senior: return .orange
        }
    }

    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            sectionHeader(icon: "info.circle.fill", title: lang.localized("member.info.basic"))

            // Name field with icon
            styledTextField(
                icon: "person.fill",
                title: lang.localized("member.name"),
                placeholder: lang.localized("member.name.placeholder"),
                text: $name
            )

            // Date of Birth
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "calendar")
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.localized("member.dob"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                    DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.medium)

            // Gender selection
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "figure.stand")
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 20)
                    Text(lang.localized("member.gender"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                }

                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        genderButton(g)
                    }
                }
            }

            // Relationship & Blood Type row
            HStack(spacing: Theme.Spacing.md) {
                // Relationship
                VStack(alignment: .leading, spacing: 6) {
                    Label(lang.localized("member.relationship"), systemImage: "heart.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))

                    Menu {
                        ForEach(Relationship.allCases, id: \.self) { r in
                            Button {
                                relationship = r
                            } label: {
                                Label(relationshipLabel(r), systemImage: "")
                            }
                        }
                    } label: {
                        HStack {
                            Text(relationship.icon)
                            Text(relationshipLabel(relationship))
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Theme.Colors.text)
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.background)
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                }
                .frame(maxWidth: .infinity)

                // Blood Type
                VStack(alignment: .leading, spacing: 6) {
                    Label(lang.localized("member.blood_type"), systemImage: "drop.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))

                    Menu {
                        ForEach(BloodType.allCases, id: \.self) { bt in
                            Button {
                                bloodType = bt
                            } label: {
                                Text(bt.rawValue)
                            }
                        }
                    } label: {
                        HStack {
                            Text(bloodType.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(bloodType == .unknown ? Theme.Colors.text.opacity(0.5) : Theme.Colors.error)
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.background)
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 2)
    }

    private func genderButton(_ g: Gender) -> some View {
        let isSelected = gender == g
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                gender = g
            }
        } label: {
            Text(genderLabel(g))
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isSelected ? Theme.Colors.primary : Theme.Colors.background)
                .foregroundColor(isSelected ? .white : Theme.Colors.text.opacity(0.7))
                .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Health Info Section (Adults/Seniors)
    private var healthInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            sectionHeader(icon: "heart.text.square.fill", title: lang.localized("member.info.health"))

            // Height & Weight row
            HStack(spacing: Theme.Spacing.md) {
                styledNumberField(
                    icon: "ruler",
                    title: lang.localized("member.height"),
                    placeholder: "165",
                    unit: "cm",
                    text: $height
                )

                styledNumberField(
                    icon: "scalemass",
                    title: lang.localized("member.weight"),
                    placeholder: "60",
                    unit: "kg",
                    text: $weight
                )
            }

            // BMI display if both values exist
            if let h = Double(height), let w = Double(weight), h > 0 {
                let bmi = w / pow(h / 100, 2)
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(bmiColor(bmi))
                    Text("BMI: \(String(format: "%.1f", bmi))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(bmiColor(bmi))
                    Text(bmiCategory(bmi))
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
                .padding(Theme.Spacing.sm)
                .background(bmiColor(bmi).opacity(0.1))
                .cornerRadius(Theme.CornerRadius.small)
            }

            styledTextField(
                icon: "cross.case.fill",
                title: lang.localized("member.chronic"),
                placeholder: lang.localized("member.chronic.placeholder"),
                text: $chronicConditions
            )

            styledTextField(
                icon: "pills.fill",
                title: lang.localized("member.medications"),
                placeholder: lang.localized("member.medications.placeholder"),
                text: $currentMedications
            )

            styledTextField(
                icon: "creditcard.fill",
                title: lang.localized("member.insurance"),
                placeholder: lang.localized("member.insurance.placeholder"),
                text: $insuranceId
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 2)
    }

    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }

    private func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return lang.localized("bmi.underweight")
        case 18.5..<25: return lang.localized("bmi.normal")
        case 25..<30: return lang.localized("bmi.overweight")
        default: return lang.localized("bmi.obese")
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(icon: "note.text", title: lang.localized("member.notes"))

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text(lang.localized("member.notes.placeholder"))
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text.opacity(0.3))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $notes)
                    .font(Theme.Typography.body)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 2)
    }

    // MARK: - Reusable Components
    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.primary)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.Colors.text)
        }
    }

    private func styledTextField(icon: String, title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.Colors.text.opacity(0.5))
                TextField(placeholder, text: text)
                    .font(.system(size: 15))
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.medium)
    }

    private func styledNumberField(icon: String, title: String, placeholder: String, unit: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Colors.text.opacity(0.5))

            HStack {
                TextField(placeholder, text: text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .medium))
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Colors.text.opacity(0.5))
            }
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.small)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func memberTypeLabel(_ type: MemberType) -> String {
        switch type {
        case .child: return lang.localized("member.type.child")
        case .adult: return lang.localized("member.type.adult")
        case .senior: return lang.localized("member.type.senior")
        }
    }

    private func genderLabel(_ g: Gender) -> String {
        switch g {
        case .male: return lang.localized("member.gender.male")
        case .female: return lang.localized("member.gender.female")
        case .other: return lang.localized("member.gender.other")
        }
    }

    private func relationshipLabel(_ r: Relationship) -> String {
        switch r {
        case .father: return lang.localized("relation.father")
        case .mother: return lang.localized("relation.mother")
        case .child: return lang.localized("relation.child")
        case .grandfather: return lang.localized("relation.grandfather")
        case .grandmother: return lang.localized("relation.grandmother")
        case .spouse: return lang.localized("relation.spouse")
        case .sibling: return lang.localized("relation.sibling")
        case .other: return lang.localized("relation.other")
        }
    }

    private func updateDefaultRelationship(for type: MemberType) {
        switch type {
        case .child: relationship = .child
        case .adult: relationship = gender == .female ? .mother : .father
        case .senior: relationship = gender == .female ? .grandmother : .grandfather
        }
    }

    private func loadExistingData() {
        guard let member = memberToEdit else { return }
        name = member.name
        dateOfBirth = member.dateOfBirth
        memberType = member.memberType
        gender = member.gender
        bloodType = member.bloodType
        relationship = member.relationship
        notes = member.notes
        height = member.height.map { String(format: "%.0f", $0) } ?? ""
        weight = member.weight.map { String(format: "%.1f", $0) } ?? ""
        chronicConditions = member.chronicConditions.joined(separator: ", ")
        currentMedications = member.currentMedications.joined(separator: ", ")
        insuranceId = member.insuranceId ?? ""
        if let data = member.avatarData { avatarImage = UIImage(data: data) }
    }

    private func saveMember() {
        let avatarData = avatarImage?.jpegData(compressionQuality: 0.8)
        let heightValue = Double(height)
        let weightValue = Double(weight)
        let chronicList = chronicConditions.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let medsList = currentMedications.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        if let member = memberToEdit {
            member.name = name.trimmingCharacters(in: .whitespaces)
            member.dateOfBirth = dateOfBirth
            member.memberType = memberType
            member.gender = gender
            member.bloodType = bloodType
            member.relationship = relationship
            member.notes = notes
            member.avatarData = avatarData
            member.height = heightValue
            member.weight = weightValue
            member.chronicConditions = chronicList
            member.currentMedications = medsList
            member.insuranceId = insuranceId.isEmpty ? nil : insuranceId
            member.updatedAt = Date()
        } else {
            let newMember = FamilyMember(
                name: name.trimmingCharacters(in: .whitespaces),
                dateOfBirth: dateOfBirth,
                memberType: memberType,
                gender: gender,
                bloodType: bloodType,
                relationship: relationship,
                avatarData: avatarData,
                notes: notes,
                height: heightValue,
                weight: weightValue,
                chronicConditions: chronicList,
                currentMedications: medsList,
                insuranceId: insuranceId.isEmpty ? nil : insuranceId
            )
            modelContext.insert(newMember)
            MemberManager.shared.selectMember(newMember)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
