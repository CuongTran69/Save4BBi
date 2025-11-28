//
//  VisitCard.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct VisitCard: View {
    let visit: MedicalVisit
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header with icon and date
            HStack {
                Image(systemName: iconForCondition(visit.condition))
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 40, height: 40)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(visit.formattedDate)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
            }
            
            // Title and condition
            VStack(alignment: .leading, spacing: 4) {
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
            
            // Tags
            if !visit.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(visit.tags, id: \.self) { tag in
                            TagView(text: tag)
                        }
                    }
                }
            }
            
            // Photo count
            if visit.hasPhotos {
                HStack(spacing: 4) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.accent)
                    
                    Text("\(visit.photoCount) photo\(visit.photoCount > 1 ? "s" : "")")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
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
#Preview {
    VStack(spacing: Theme.Spacing.md) {
        VisitCard(visit: .sample)
        VisitCard(visit: MedicalVisit.samples[0])
        VisitCard(visit: MedicalVisit.samples[1])
    }
    .padding()
    .background(Theme.Colors.background)
}

