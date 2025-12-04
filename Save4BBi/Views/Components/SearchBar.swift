//
//  SearchBar.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search visits, conditions, doctors..."
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.Colors.text.opacity(0.5))

            // Text field
            TextField(placeholder, text: $text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .focused($isFocused)
                .submitLabel(.search)
            
            // Clear button
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
}

/*
#Preview {
    VStack {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Fever"))
    }
    .padding()
    .background(Theme.Colors.background)
}
*/
