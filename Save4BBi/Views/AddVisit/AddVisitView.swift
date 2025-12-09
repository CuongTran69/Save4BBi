//
//  AddVisitView.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData
import RxSwift

struct AddVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var memberManager = MemberManager.shared

    @State private var title = ""
    @State private var condition = ""
    @State private var doctorName = ""
    @State private var notes = ""
    @State private var visitDate = Date()
    @State private var selectedTags: Set<String> = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var selectedMemberId: UUID?

    // Photo source
    @State private var showPhotoSourceSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false

    private let photoService = PhotoService.shared
    private let disposeBag = DisposeBag()

    // Tag keys for localization
    private let tagKeys = ["tag.checkup", "tag.vaccination", "tag.emergency", "tag.dental", "tag.fever", "tag.routine"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Member Selector Section
                    memberSelectorSection

                    // Photo Picker Section
                    photoPickerSection

                    // Basic Information
                    basicInfoSection

                    // Tags Section
                    tagsSection

                    // Notes Section
                    notesSection
                }
                .padding(Theme.Spacing.md)
            }
            .dismissKeyboardOnTap()
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("visit.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Default to currently selected member
                selectedMemberId = memberManager.selectedMemberId
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(lang.localized("button.cancel"))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.Colors.text.opacity(0.7))
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveVisit()
                    } label: {
                        Text(lang.localized("button.save"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isFormValid && !isSaving ? .white : Theme.Colors.text.opacity(0.3))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isFormValid && !isSaving ? Theme.Colors.primary : Theme.Colors.text.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
        }
        .alert(lang.localized("error.title"), isPresented: $showError) {
            Button(lang.localized("error.ok"), role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .overlay {
            if isSaving {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: Theme.Spacing.md) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                            .scaleEffect(1.5)

                        Text(lang.localized("visit.saving"))
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                    }
                    .padding(Theme.Spacing.xl)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.large)
                    .shadow(color: Theme.Colors.shadow, radius: 16)
                }
            }
        }
    }
    
    // MARK: - Member Selector Section
    private var memberSelectorSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("member.select"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(members) { member in
                        Button {
                            selectedMemberId = member.id
                        } label: {
                            HStack(spacing: 8) {
                                // Avatar
                                memberAvatarView(member)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(member.name)
                                        .font(Theme.Typography.bodyBold)
                                        .lineLimit(1)
                                    Text(member.age)
                                        .font(Theme.Typography.caption)
                                        .opacity(0.7)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(selectedMemberId == member.id ? Theme.Colors.primary : Theme.Colors.cardBackground)
                            .foregroundColor(selectedMemberId == member.id ? .white : Theme.Colors.text)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(selectedMemberId == member.id ? Theme.Colors.primary : Theme.Colors.divider, lineWidth: 1)
                            )
                        }
                    }
                }
            }

            if members.isEmpty {
                Text(lang.localized("member.empty"))
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                    .padding(.top, Theme.Spacing.xs)
            }
        }
    }

    private func memberAvatarView(_ member: FamilyMember) -> some View {
        Group {
            if let avatarData = member.avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(member.avatarIcon)
                    .font(.title3)
            }
        }
        .frame(width: 36, height: 36)
        .background(Theme.Colors.primary.opacity(0.2))
        .clipShape(Circle())
    }

    // MARK: - Photo Picker Section
    private var photoPickerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("visit.photos.title"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            // Photo options - Camera & Library
            HStack(spacing: Theme.Spacing.md) {
                // Camera button
                Button {
                    showCamera = true
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.primary.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.localized("photo.source.camera"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.Colors.text)
                        }
                    }
                    .padding(Theme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())

                // Library button
                Button {
                    showLibrary = true
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.accent.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.Colors.accent)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.localized("photo.source.library"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.Colors.text)
                        }
                    }
                    .padding(Theme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }

            // Photo count indicator
            if !photoImages.isEmpty {
                HStack {
                    Text("\(photoImages.count) \(lang.localized("visit.photos"))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.primary)
                    Spacer()
                    Button {
                        photoImages.removeAll()
                        selectedPhotos.removeAll()
                    } label: {
                        Text(lang.localized("button.clear"))
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Colors.error)
                    }
                }
                .padding(.top, 4)
            }

            // Photo preview grid
            if !photoImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))

                                // Remove button
                                Button {
                                    photoImages.remove(at: index)
                                    if index < selectedPhotos.count {
                                        selectedPhotos.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLibrary) {
            MultiPhotosPickerSheet(selectedImages: $photoImages)
        }
        .fullScreenCover(isPresented: $showCamera) {
            MultiCameraImagePicker(images: $photoImages)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("visit.info.title"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            VStack(spacing: Theme.Spacing.md) {
                // Title
                FormField(title: lang.localized("visit.title"), placeholder: lang.localized("visit.title.placeholder"), text: $title)

                // Condition (Required)
                FormField(title: lang.localized("visit.condition.required"), placeholder: lang.localized("visit.condition.placeholder"), text: $condition)

                // Doctor Name
                FormField(title: lang.localized("visit.doctor"), placeholder: lang.localized("visit.doctor.placeholder"), text: $doctorName)

                // Visit Date
                CustomDatePicker(
                    lang.localized("visit.date"),
                    selection: $visitDate,
                    mode: .date
                )
            }
            .padding(Theme.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("visit.tags"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(tagKeys, id: \.self) { tagKey in
                    let displayText = lang.localized(tagKey)
                    TagButton(
                        text: displayText,
                        isSelected: selectedTags.contains(tagKey)
                    ) {
                        if selectedTags.contains(tagKey) {
                            selectedTags.remove(tagKey)
                        } else {
                            selectedTags.insert(tagKey)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("visit.notes"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            TextEditor(text: $notes)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .frame(minHeight: 120)
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.divider, lineWidth: 1)
                )
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        !condition.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Save Visit
    private func saveVisit() {
        guard !isSaving else { return }
        isSaving = true
        
        // If no photos, save visit directly
        if photoImages.isEmpty {
            saveVisitToDatabase(savedPhotoFilenames: [])
            return
        }
        
        // Save photos with encryption
        var savedFilenames: [String] = []
        let photoObservables = photoImages.map { image in
            photoService.savePhoto(image)
        }
        
        Observable.concat(photoObservables)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { filename in
                    savedFilenames.append(filename)
                },
                onError: { [self] error in
                    self.isSaving = false
                    self.errorMessage = "\(lang.localized("error.save_photos")): \(error.localizedDescription)"
                    self.showError = true
                },
                onCompleted: {
                    self.saveVisitToDatabase(savedPhotoFilenames: savedFilenames)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func saveVisitToDatabase(savedPhotoFilenames: [String]) {
        // Create new visit with selected member
        let visit = MedicalVisit(
            title: title,
            condition: condition,
            doctorName: doctorName,
            notes: notes,
            visitDate: visitDate,
            photoFilePaths: savedPhotoFilenames,
            tags: Array(selectedTags),
            memberId: selectedMemberId
        )

        modelContext.insert(visit)
        
        do {
            try modelContext.save()
            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            errorMessage = "\(lang.localized("error.save_visit")): \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Form Field Component
struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.text.opacity(0.7))

            TextField(placeholder, text: $text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.background)
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

// MARK: - Tag Button Component
struct TagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Theme.Typography.subheadline)
                .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isSelected ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

// FlowLayout is now imported from Components/FlowLayout.swift

// #Preview {
//     AddVisitView()
//         .modelContainer(for: MedicalVisit.self, inMemory: true)
// }
