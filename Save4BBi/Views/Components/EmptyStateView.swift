//
//  EmptyStateView.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            
            // Cute illustration
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.text.square")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            // Title
            Text("No Medical Visits Yet")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            // Description
            Text("Tap the + button below to add your first medical visit record")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// #Preview {
//     EmptyStateView()
// }
