//
//  EditVisitView.swift
//  MediFamily
//
//  Created by Cường Trần on 27/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.createdAt) private var allTags: [Tag]

    let visit: MedicalVisit

    @State private var title: String
    @State private var condition: String
    @State private var doctorName: String
    @State private var notes: String
    @State private var visitDate: Date
    @State private var selectedTagIds: Set<String>
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var existingPhotoFilePaths: [String]
    @State private var existingPhotoImages: [String: UIImage] = [:]  // filename -> image
    @State private var isLoadingExistingPhotos = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var hasLoadedTagIds = false

    // Photo source
    @State private var showCamera = false
    @State private var showLibrary = false
    @ObservedObject private var lang = LanguageManager.shared

    private let photoService = PhotoService.shared

    init(visit: MedicalVisit) {
        self.visit = visit
        _title = State(initialValue: visit.title)
        _condition = State(initialValue: visit.condition)
        _doctorName = State(initialValue: visit.doctorName)
        _notes = State(initialValue: visit.notes)
        _visitDate = State(initialValue: visit.visitDate)
        _selectedTagIds = State(initialValue: Set<String>())
        _existingPhotoFilePaths = State(initialValue: visit.photoFilePaths)
    }

    // Convert selected tag IDs to tag names for storage
    private var selectedTagNames: [String] {
        selectedTagIds.compactMap { tagId in
            allTags.first { $0.id.uuidString == tagId }?.name
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
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
            .navigationTitle(lang.localized("visit.edit.title"))
            .navigationBarTitleDisplayMode(.inline)
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
                        saveChanges()
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
            Button(lang.localized("button.ok"), role: .cancel) { }
        } message: {
            Text(errorMessage ?? lang.localized("error.unknown"))
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

                        Text(lang.localized("saving"))
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
        .onAppear {
            loadExistingPhotos()
        }
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

            // New photos preview
            if !photoImages.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text("\(photoImages.count) \(lang.localized("edit.new.photos"))")
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

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))

                                    Button {
                                        photoImages.remove(at: index)
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

            // Existing photos with delete option
            if !existingPhotoFilePaths.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Existing Photos (\(existingPhotoFilePaths.count))")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))

                    if isLoadingExistingPhotos {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                            Text("Loading...")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }
                        .frame(height: 80)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.sm) {
                                ForEach(existingPhotoFilePaths, id: \.self) { filename in
                                    ZStack(alignment: .topTrailing) {
                                        if let image = existingPhotoImages[filename] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                                        } else {
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .fill(Theme.Colors.cardBackground)
                                                .frame(width: 80, height: 80)
                                                .overlay {
                                                    Image(systemName: "photo")
                                                        .foregroundColor(Theme.Colors.text.opacity(0.3))
                                                }
                                        }

                                        // Delete button
                                        Button {
                                            removeExistingPhoto(filename: filename)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.white)
                                                .background(Color.red.clipShape(Circle()))
                                        }
                                        .offset(x: 8, y: -8)
                                    }
                                }
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

    // MARK: - Remove Existing Photo
    private func removeExistingPhoto(filename: String) {
        // Delete from file system
        Task {
            _ = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                _ = photoService.deletePhoto(filename: filename)
                    .subscribe(
                        onNext: { continuation.resume(returning: ()) },
                        onError: { error in continuation.resume(throwing: error) }
                    )
            }
        }

        // Remove from state
        existingPhotoFilePaths.removeAll { $0 == filename }
        existingPhotoImages.removeValue(forKey: filename)
    }

    // MARK: - Load Existing Photos
    private func loadExistingPhotos() {
        guard !existingPhotoFilePaths.isEmpty else { return }

        isLoadingExistingPhotos = true

        Task {
            for filename in existingPhotoFilePaths {
                do {
                    let image = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
                        _ = photoService.loadPhoto(filename: filename)
                            .subscribe(
                                onNext: { image in continuation.resume(returning: image) },
                                onError: { error in continuation.resume(throwing: error) }
                            )
                    }
                    await MainActor.run {
                        existingPhotoImages[filename] = image
                    }
                } catch {
                    print("Error loading existing photo: \(error)")
                }
            }
            await MainActor.run {
                isLoadingExistingPhotos = false
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Visit Information")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: Theme.Spacing.md) {
                // Title
                FormField(title: "Title", placeholder: "e.g., Annual Checkup", text: $title)
                
                // Condition (Required)
                FormField(title: "Condition *", placeholder: "e.g., Fever, Vaccination", text: $condition)
                
                // Doctor Name
                FormField(title: "Doctor Name", placeholder: "e.g., Dr. Nguyễn Văn A", text: $doctorName)

                // Visit Date
                CustomDatePicker(
                    "Visit Date",
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
        TagSelectorView(selectedTagIds: $selectedTagIds)
            .onAppear {
                loadTagIds()
            }
    }

    // Load tag IDs from tag names (only once when allTags is available)
    private func loadTagIds() {
        guard !hasLoadedTagIds && !allTags.isEmpty else { return }
        hasLoadedTagIds = true

        // Convert tag names to tag IDs
        let tagIds: Set<String> = Set(visit.tags.compactMap { tagName in
            allTags.first { $0.name == tagName || $0.nameVI == tagName }?.id.uuidString
        })
        selectedTagIds = tagIds
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
    
    // MARK: - Save Changes
    private func saveChanges() {
        guard !isSaving else { return }
        isSaving = true

        // If no new photos, update visit directly
        if photoImages.isEmpty {
            updateVisit(newPhotoFilePaths: [])
            return
        }

        // Save new photos with encryption using async/await
        Task {
            var savedFilenames: [String] = []

            for image in photoImages {
                do {
                    let filename = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                        _ = photoService.savePhoto(image)
                            .subscribe(
                                onNext: { filename in continuation.resume(returning: filename) },
                                onError: { error in continuation.resume(throwing: error) }
                            )
                    }
                    savedFilenames.append(filename)
                } catch {
                    await MainActor.run {
                        isSaving = false
                        errorMessage = "Failed to save photos: \(error.localizedDescription)"
                        showError = true
                    }
                    return
                }
            }

            await MainActor.run {
                updateVisit(newPhotoFilePaths: savedFilenames)
            }
        }
    }
    
    private func updateVisit(newPhotoFilePaths: [String]) {
        // Update visit properties
        visit.title = title
        visit.condition = condition
        visit.doctorName = doctorName
        visit.notes = notes
        visit.visitDate = visitDate
        visit.tags = selectedTagNames
        visit.updatedAt = Date()

        // Append new photos to existing ones
        visit.photoFilePaths = existingPhotoFilePaths + newPhotoFilePaths
        
        do {
            try modelContext.save()
            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}

// #Preview {
//     EditVisitView(visit: .sample)
//         .modelContainer(for: MedicalVisit.self, inMemory: true)
// }
