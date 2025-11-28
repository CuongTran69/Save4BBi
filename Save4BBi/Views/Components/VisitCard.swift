//
//  VisitCard.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import RxSwift
import SwiftData

struct VisitCard: View {
    let visit: MedicalVisit
    var onDelete: (() -> Void)? = nil
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var showingFullScreen = false
    @State private var showingDeleteDialog = false
    @State private var allImages: [UIImage] = []
    
    private let photoService = PhotoService.shared
    private let disposeBag = DisposeBag()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail image at top (if available)
            if visit.hasPhotos {
                Group {
                    if let thumbnail = thumbnailImage {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                            .onTapGesture {
                                showingFullScreen = true
                            }
                    } else if isLoadingThumbnail {
                        Rectangle()
                            .fill(Theme.Colors.primary.opacity(0.1))
                            .frame(height: 160)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                            )
                    } else {
                        Rectangle()
                            .fill(Theme.Colors.primary.opacity(0.1))
                            .frame(height: 160)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(Theme.Colors.primary.opacity(0.3))
                            )
                    }
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Header with icon and date
                HStack {
                    Image(systemName: iconForCondition(visit.condition))
                        .font(.title3)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 32, height: 32)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Text(visit.formattedDate)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
                
                // Title and condition
                VStack(alignment: .leading, spacing: 2) {
                    Text(visit.displayTitle)
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.text)
                        .lineLimit(1)
                    
                    Text(visit.condition)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                        .lineLimit(1)
                }
                
                // Doctor name
                if !visit.doctorName.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "stethoscope")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondary)
                        
                        Text(visit.doctorName)
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                
                // Tags and photo count
                HStack {
                    // Tags
                    if !visit.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.xs) {
                                ForEach(visit.tags.prefix(2), id: \.self) { tag in
                                    TagView(text: tag)
                                }
                                if visit.tags.count > 2 {
                                    Text("+\(visit.tags.count - 2)")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Photo count
                    if visit.hasPhotos {
                        HStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.accent)
                            
                            Text("\(visit.photoCount)")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            // Delete button
            Button {
                showingDeleteDialog = true
            } label: {
                ZStack {
                    // Background blur effect
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Icon
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.error)
                }
            }
            .padding(Theme.Spacing.sm)
        }
        .onAppear {
            loadThumbnail()
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenPhotoViewer(images: allImages, initialIndex: 0)
        }
        .customDialog(
            isPresented: $showingDeleteDialog,
            title: "Delete Visit?",
            message: "This action cannot be undone. All photos and information will be permanently deleted.",
            primaryButton: DialogButton(title: "Delete", isDestructive: true) {
                onDelete?()
            },
            secondaryButton: DialogButton(title: "Cancel") {}
        )
    }
    
    // MARK: - Load Thumbnail
    private func loadThumbnail() {
        guard visit.hasPhotos, let firstPhotoPath = visit.photoFilePaths.first else { return }
        
        isLoadingThumbnail = true
        
        // Load all images for full screen viewer
        let photoObservables = visit.photoFilePaths.map { filename in
            photoService.loadPhoto(filename: filename)
        }
        
        Observable.concat(photoObservables)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { image in
                    self.allImages.append(image)
                    if self.thumbnailImage == nil {
                        self.thumbnailImage = image
                        self.isLoadingThumbnail = false
                    }
                },
                onError: { error in
                    print("Error loading thumbnail: \(error)")
                    self.isLoadingThumbnail = false
                },
                onCompleted: {
                    self.isLoadingThumbnail = false
                }
            )
            .disposed(by: disposeBag)
    }
    
    // Helper function to get icon based on condition
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
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(Theme.Colors.primary.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Preview
// #Preview {
//     VStack(spacing: Theme.Spacing.md) {
//         VisitCard(visit: .sample)
//         VisitCard(visit: MedicalVisit.samples[0])
//         VisitCard(visit: MedicalVisit.samples[1])
//     }
//     .padding()
//     .background(Theme.Colors.background)
// }
