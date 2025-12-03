//
//  EditVisitView.swift
//  Save4BBi
//
//  Created by Cường Trần on 27/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let visit: MedicalVisit

    @State private var title: String
    @State private var condition: String
    @State private var doctorName: String
    @State private var notes: String
    @State private var visitDate: Date
    @State private var selectedTags: Set<String>
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var existingPhotoFilePaths: [String]
    @State private var existingPhotoImages: [String: UIImage] = [:]  // filename -> image
    @State private var isLoadingExistingPhotos = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let photoService = PhotoService.shared

    let availableTags = ["Checkup", "Vaccination", "Emergency", "Dental", "Fever", "Routine"]

    init(visit: MedicalVisit) {
        self.visit = visit
        _title = State(initialValue: visit.title)
        _condition = State(initialValue: visit.condition)
        _doctorName = State(initialValue: visit.doctorName)
        _notes = State(initialValue: visit.notes)
        _visitDate = State(initialValue: visit.visitDate)
        _selectedTags = State(initialValue: Set(visit.tags))
        _existingPhotoFilePaths = State(initialValue: visit.photoFilePaths)
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
            .navigationTitle("Edit Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
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
                        
                        Text("Saving changes...")
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
            Text("Photos")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add More Photos")
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        Text("Tap to select from gallery")
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
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Visit Date")
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
            Text("Tags")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(availableTags, id: \.self) { tag in
                    TagButton(
                        text: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
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
            Text("Notes")
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
        visit.tags = Array(selectedTags)
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
