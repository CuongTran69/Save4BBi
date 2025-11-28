//
//  ListLayout.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct ListLayout: View {
    let visits: [MedicalVisit]
    
    var body: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
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
            ListLayout(visits: MedicalVisit.samples)
        }
        .background(Theme.Colors.background)
    }
}

