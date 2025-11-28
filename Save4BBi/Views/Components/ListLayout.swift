//
//  ListLayout.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI
import SwiftData
import RxSwift

struct ListLayout: View {
    let visits: [MedicalVisit]
    @Environment(\.modelContext) private var modelContext
    
    private let photoService = PhotoService.shared
    private let disposeBag = DisposeBag()
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(visits) { visit in
                NavigationLink {
                    VisitDetailView(visit: visit)
                } label: {
                    VisitCard(visit: visit) {
                        deleteVisit(visit)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func deleteVisit(_ visit: MedicalVisit) {
        // Delete photos from file system
        for filename in visit.photoFilePaths {
            photoService.deletePhoto(filename: filename)
                .subscribe()
                .disposed(by: disposeBag)
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
