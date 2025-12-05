//
//  VisitCard.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct VisitCard: View {
    let visit: MedicalVisit
    var onDelete: (() -> Void)? = nil
    var isCompact: Bool = true  // For grid view (compact) vs list view (full)

    @State private var thumbnailImage: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var showingFullScreen = false
    @State private var showingDeleteDialog = false
    @State private var allImages: [UIImage] = []

    @ObservedObject private var lang = LanguageManager.shared
    private let photoService = PhotoService.shared

    // Fixed heights for consistent grid layout
    private let thumbnailHeight: CGFloat = 120
    private let contentMinHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail image at top
            ZStack(alignment: .topTrailing) {
                thumbnailView

                // Delete button - inside the card
                if onDelete != nil {
                    deleteButton
                        .padding(8)
                }
            }
            .frame(height: thumbnailHeight)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Header with icon and date
                HStack(spacing: 6) {
                    Image(systemName: iconForCondition(visit.condition))
                        .font(.caption)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 24, height: 24)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(Circle())

                    Text(visit.formattedDate)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                        .lineLimit(1)

                    Spacer(minLength: 0)
                }

                // Title
                Text(visit.displayTitle)
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(1)

                // Condition
                Text(visit.condition)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.7))
                    .lineLimit(1)

                Spacer(minLength: 0)

                // Bottom row: Doctor/Tag + Photo count
                HStack(spacing: 4) {
                    if !visit.doctorName.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "stethoscope")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.secondary)

                            Text(visit.doctorName)
                                .font(.system(size: 11))
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                                .lineLimit(1)
                        }
                    } else if let firstTag = visit.tags.first {
                        TagView(text: firstTag, isCompact: true)
                    }

                    Spacer(minLength: 0)

                    // Photo count
                    if visit.hasPhotos {
                        HStack(spacing: 2) {
                            Image(systemName: "photo")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.accent)

                            Text("\(visit.photoCount)")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(10)
            .frame(minHeight: contentMinHeight, alignment: .top)
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .shadow(color: Theme.Colors.shadow.opacity(0.5), radius: 4, x: 0, y: 2)
        .onAppear {
            loadThumbnail()
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenPhotoViewer(images: allImages, initialIndex: 0)
        }
        .customDialog(
            isPresented: $showingDeleteDialog,
            title: lang.localized("delete.title"),
            message: lang.localized("delete.message"),
            primaryButton: DialogButton(title: lang.localized("button.delete"), isDestructive: true) {
                onDelete?()
            },
            secondaryButton: DialogButton(title: lang.localized("button.cancel")) {}
        )
    }

    // MARK: - Thumbnail View
    @ViewBuilder
    private var thumbnailView: some View {
        if visit.hasPhotos {
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: thumbnailHeight)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingFullScreen = true
                    }
            } else if isLoadingThumbnail {
                Rectangle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                            .scaleEffect(0.8)
                    )
            } else {
                Rectangle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.primary.opacity(0.3))
                    )
            }
        } else {
            // No photo - show gradient placeholder
            LinearGradient(
                colors: [
                    Theme.Colors.primary.opacity(0.15),
                    Theme.Colors.accent.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Image(systemName: iconForCondition(visit.condition))
                    .font(.system(size: 32))
                    .foregroundColor(Theme.Colors.primary.opacity(0.3))
            )
        }
    }

    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            showingDeleteDialog = true
        } label: {
            Image(systemName: "trash.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Theme.Colors.error.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                )
        }
    }

    // MARK: - Load Thumbnail
    private func loadThumbnail() {
        // Guard: skip if no photos or already loaded
        guard visit.hasPhotos, !visit.photoFilePaths.isEmpty else { return }
        guard thumbnailImage == nil, allImages.isEmpty else { return }

        isLoadingThumbnail = true

        Task {
            var loadedImages: [UIImage] = []

            for filename in visit.photoFilePaths {
                do {
                    let image = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
                        _ = photoService.loadPhoto(filename: filename)
                            .subscribe(
                                onNext: { image in continuation.resume(returning: image) },
                                onError: { error in continuation.resume(throwing: error) }
                            )
                    }
                    loadedImages.append(image)
                } catch {
                    print("Error loading thumbnail: \(error)")
                }
            }

            await MainActor.run {
                allImages = loadedImages
                thumbnailImage = loadedImages.first
                isLoadingThumbnail = false
            }
        }
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
    var isCompact: Bool = false

    var body: some View {
        Text(text)
            .font(isCompact ? .system(size: 10) : Theme.Typography.caption)
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, isCompact ? 6 : Theme.Spacing.sm)
            .padding(.vertical, isCompact ? 2 : 4)
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
