//
//  GridLayout.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData

struct GridLayout: View {
    let visits: [MedicalVisit]
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]

    @State private var selectedVisit: MedicalVisit?

    private let photoService = PhotoService.shared

    // Grid columns with fixed spacing
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(visits) { visit in
                Button {
                    selectedVisit = visit
                } label: {
                    VisitCard(
                        visit: visit,
                        member: memberFor(visit),
                        onDelete: { deleteVisit(visit) },
                        isCompact: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .sheet(item: $selectedVisit) { visit in
            NavigationStack {
                VisitDetailView(visit: visit)
            }
        }
    }

    private func memberFor(_ visit: MedicalVisit) -> FamilyMember? {
        guard let memberId = visit.memberId else { return nil }
        return members.first { $0.id == memberId }
    }

    private func deleteVisit(_ visit: MedicalVisit) {
        // Delete photos from file system using Task
        Task {
            for filename in visit.photoFilePaths {
                _ = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    _ = photoService.deletePhoto(filename: filename)
                        .subscribe(
                            onNext: { continuation.resume(returning: ()) },
                            onError: { error in continuation.resume(throwing: error) }
                        )
                }
            }
        }

        // Delete from database
        modelContext.delete(visit)

        do {
            try modelContext.save()
        } catch {
            print("Error deleting visit: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            GridLayout(visits: MedicalVisit.samples)
        }
        .background(Theme.Colors.background)
    }
}
