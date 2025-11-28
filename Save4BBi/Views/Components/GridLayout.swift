//
//  GridLayout.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct GridLayout: View {
    let visits: [MedicalVisit]
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
            ForEach(visits) { visit in
                NavigationLink {
                    VisitDetailView(visit: visit)
                } label: {
                    VisitCard(visit: visit)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(Theme.Spacing.md)
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

