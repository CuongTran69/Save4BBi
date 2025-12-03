//
//  ListLayout.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData

struct ListLayout: View {
    let visits: [MedicalVisit]
    @Environment(\.modelContext) private var modelContext

    private let photoService = PhotoService.shared

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(visits) { visit in
                NavigationLink {
                    VisitDetailView(visit: visit)
                } label: {
                    VisitCard(visit: visit, onDelete: { deleteVisit(visit) }, isCompact: false)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
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

// #Preview {
//     NavigationStack {
//         ScrollView {
//             ListLayout(visits: MedicalVisit.samples)
//         }
//         .background(Theme.Colors.background)
//     }
// }
