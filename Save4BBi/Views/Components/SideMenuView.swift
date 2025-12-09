//
//  SideMenuView.swift
//  MediFamily
//
//  Created by Cường Trần on 09/12/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var lang = LanguageManager.shared
    
    let onSettingsTap: () -> Void
    let onStatisticsTap: () -> Void
    let onFamilyMembersTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Dimmed background
                if isPresented {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isPresented = false
                            }
                        }
                }
                
                // Menu content
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        menuHeader
                        
                        Divider()
                            .padding(.vertical, Theme.Spacing.sm)
                        
                        // Menu items
                        VStack(spacing: 4) {
                            menuItem(
                                icon: "person.2.fill",
                                title: lang.localized("menu.family"),
                                action: {
                                    closeAndExecute { onFamilyMembersTap() }
                                }
                            )
                            
                            menuItem(
                                icon: "chart.bar.fill",
                                title: lang.localized("menu.statistics"),
                                action: {
                                    closeAndExecute { onStatisticsTap() }
                                }
                            )
                            
                            menuItem(
                                icon: "gearshape.fill",
                                title: lang.localized("menu.settings"),
                                action: {
                                    closeAndExecute { onSettingsTap() }
                                }
                            )
                        }
                        
                        Spacer()
                        
                        // App version
                        Text("MediFamily v1.0")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text.opacity(0.4))
                            .padding(Theme.Spacing.md)
                    }
                    .frame(width: min(geometry.size.width * 0.75, 280))
                    .background(Theme.Colors.background)
                    .offset(x: isPresented ? 0 : -min(geometry.size.width * 0.75, 280))
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Menu Header
    private var menuHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("MediFamily")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.Colors.text)
            
            Text(lang.localized("menu.subtitle"))
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
        .padding(Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.xl)
    }
    
    // MARK: - Menu Item
    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 32)
                
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.text.opacity(0.3))
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.small)
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    
    private func closeAndExecute(_ action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}

