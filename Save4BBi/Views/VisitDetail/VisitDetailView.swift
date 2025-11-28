//
//  VisitDetailView.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData
import RxSwift

struct VisitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let visit: MedicalVisit
    
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var loadedImages: [UIImage] = []
    @State private var isLoadingImages = false
    
    private let photoService = PhotoService.shared
    private let disposeBag = DisposeBag()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header Card
                headerCard
                
                // Photos Section
                if visit.hasPhotos {
                    photosSection
                }
                
                // Information Card
                informationCard
                
                // Notes Section
                if !visit.notes.isEmpty {
                    notesSection
                }
                
                // Tags Section
                if !visit.tags.isEmpty {
                    tagsSection
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle("Visit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
        }
        .alert("Delete Visit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteVisit()
            }
        } message: {
            Text("Are you sure you want to delete this visit? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditView) {
            EditVisitView(visit: visit)
        }
        .onAppear {
            loadPhotos()
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: iconForCondition(visit.condition))
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 60, height: 60)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.displayTitle)
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(visit.condition)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                }
                
                Spacer()
            }
            
            Divider()
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Theme.Colors.secondary)
                Text(visit.formattedDate)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Photos Section
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Photos (\(visit.photoCount))")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            if isLoadingImages {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                    Text("Loading photos...")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
                .frame(height: 150)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                                .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Information Card
    private var informationCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Information")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            if !visit.doctorName.isEmpty {
                InfoRow(icon: "stethoscope", title: "Doctor", value: visit.doctorName)
            }

            InfoRow(icon: "clock", title: "Created", value: formatDate(visit.createdAt))

            if visit.updatedAt != visit.createdAt {
                InfoRow(icon: "arrow.clockwise", title: "Updated", value: formatDate(visit.updatedAt))
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Notes")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Text(visit.notes)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text.opacity(0.8))
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.divider, lineWidth: 1)
                )
        }
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Tags")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(visit.tags, id: \.self) { tag in
                    TagView(text: tag)
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func iconForCondition(_ condition: String) -> String {
        let lowercased = condition.lowercased()

        if lowercased.contains("vaccination") || lowercased.contains("vaccine") {
            return "syringe"
        } else if lowercased.contains("dental") || lowercased.contains("teeth") {
            return "mouth"
        } else if lowercased.contains("fever") || lowercased.contains("sick") {
            return "thermometer"
        } else if lowercased.contains("checkup") || lowercased.contains("routine") {
            return "heart.text.square"
        } else if lowercased.contains("emergency") {
            return "cross.case"
        } else {
            return "heart.circle"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func deleteVisit() {
        // Delete photos from file system first
        for filename in visit.photoFilePaths {
            photoService.deletePhoto(filename: filename)
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        modelContext.delete(visit)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting visit: \(error)")
        }
    }
    
    // MARK: - Load Photos
    private func loadPhotos() {
        guard !visit.photoFilePaths.isEmpty else { return }
        
        isLoadingImages = true
        loadedImages = []
        
        let photoObservables = visit.photoFilePaths.map { filename in
            photoService.loadPhoto(filename: filename)
        }
        
        Observable.concat(photoObservables)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { image in
                    self.loadedImages.append(image)
                },
                onError: { error in
                    print("Error loading photo: \(error)")
                },
                onCompleted: {
                    self.isLoadingImages = false
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.Colors.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))

                Text(value)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        VisitDetailView(visit: .sample)
    }
    .modelContainer(for: MedicalVisit.self, inMemory: true)
}
