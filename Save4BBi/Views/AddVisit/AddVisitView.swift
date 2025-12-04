//
//  AddVisitView.swift
//  Save4BBi
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
    @Query(sort: \Child.createdAt) private var children: [Child]
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var childManager = ChildManager.shared

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
    @State private var selectedChildId: UUID?

    private let photoService = PhotoService.shared
    private let disposeBag = DisposeBag()

    // Tag keys for localization
    private let tagKeys = ["tag.checkup", "tag.vaccination", "tag.emergency", "tag.dental", "tag.fever", "tag.routine"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Child Selector Section
                    childSelectorSection

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
                // Default to currently selected child
                selectedChildId = childManager.selectedChildId
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.save")) {
                        saveVisit()
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
    
    // MARK: - Child Selector Section
    private var childSelectorSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(lang.localized("child.select"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(children) { child in
                        Button {
                            selectedChildId = child.id
                        } label: {
                            HStack(spacing: 8) {
                                // Avatar
                                childAvatarView(child)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(child.name)
                                        .font(Theme.Typography.bodyBold)
                                        .lineLimit(1)
                                    Text(child.age)
                                        .font(Theme.Typography.caption)
                                        .opacity(0.7)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(selectedChildId == child.id ? Theme.Colors.primary : Theme.Colors.cardBackground)
                            .foregroundColor(selectedChildId == child.id ? .white : Theme.Colors.text)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(selectedChildId == child.id ? Theme.Colors.primary : Theme.Colors.divider, lineWidth: 1)
                            )
                        }
                    }
                }
            }

            if children.isEmpty {
                Text(lang.localized("child.empty"))
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                    .padding(.top, Theme.Spacing.xs)
            }
        }
    }

    private func childAvatarView(_ child: Child) -> some View {
        Group {
            if let avatarData = child.avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(child.avatarIcon)
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

            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.localized("visit.photos.add"))
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)

                        Text(lang.localized("visit.photos.select"))
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                    }

                    Spacer()

                    if !selectedPhotos.isEmpty {
                        Text("\(selectedPhotos.count)")
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Theme.Colors.accent)
                            .clipShape(Circle())
                    }
                }
                .padding(Theme.Spacing.md)
                .cardStyle()
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    photoImages = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            photoImages.append(image)
                        }
                    }
                }
            }

            // Photo preview grid
            if !photoImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                        }
                    }
                }
            }
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
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(lang.localized("visit.date"))
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))

                    DatePicker("", selection: $visitDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
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
        // Create new visit with selected child profile
        let visit = MedicalVisit(
            title: title,
            condition: condition,
            doctorName: doctorName,
            notes: notes,
            visitDate: visitDate,
            photoFilePaths: savedPhotoFilenames,
            tags: Array(selectedTags),
            childProfileId: selectedChildId
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
