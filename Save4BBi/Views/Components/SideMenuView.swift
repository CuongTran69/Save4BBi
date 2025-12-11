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
    let onTagsTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Dimmed background
                if isPresented {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }
                }

                // Menu content
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        menuHeader

                        // Menu items
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 8) {
                                // Main section
                                menuSection(title: lang.localized("menu.section.main")) {
                                    menuItem(
                                        icon: "person.2.fill",
                                        iconColor: Theme.Colors.primary,
                                        title: lang.localized("menu.family"),
                                        action: { closeAndExecute { onFamilyMembersTap() } }
                                    )

                                    menuItem(
                                        icon: "tag.fill",
                                        iconColor: .orange,
                                        title: lang.localized("menu.tags"),
                                        action: { closeAndExecute { onTagsTap() } }
                                    )

                                    menuItem(
                                        icon: "chart.bar.fill",
                                        iconColor: .green,
                                        title: lang.localized("menu.statistics"),
                                        action: { closeAndExecute { onStatisticsTap() } }
                                    )
                                }

                                // Settings section
                                menuSection(title: lang.localized("menu.section.app")) {
                                    menuItem(
                                        icon: "gearshape.fill",
                                        iconColor: .gray,
                                        title: lang.localized("menu.settings"),
                                        action: { closeAndExecute { onSettingsTap() } }
                                    )
                                }
                            }
                            .padding(.top, Theme.Spacing.sm)
                        }

                        Spacer()

                        // App version footer
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red.opacity(0.6))
                            Text("MediFamily v1.0")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.Colors.text.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.text.opacity(0.03))
                    }
                    .frame(width: min(geometry.size.width * 0.78, 300))
                    .background(
                        Theme.Colors.background
                            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 5, y: 0)
                    )
                    .offset(x: isPresented ? 0 : -min(geometry.size.width * 0.78, 300))

                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Menu Header
    private var menuHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.Spacing.md) {
                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Theme.Colors.primary, Theme.Colors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("MediFamily")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.Colors.text)

                    Text(lang.localized("menu.subtitle"))
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                }

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, 60)
            .padding(.bottom, Theme.Spacing.lg)

            // Divider with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.primary.opacity(0.3), Theme.Colors.accent.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, Theme.Spacing.lg)
        }
    }

    // MARK: - Menu Section
    private func menuSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.Colors.text.opacity(0.4))
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.sm)

            VStack(spacing: 2) {
                content()
            }
        }
    }

    // MARK: - Menu Item
    private func menuItem(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon with colored background
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.Colors.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.text.opacity(0.25))
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 10)
            .background(Color.clear)
        }
        .buttonStyle(MenuItemButtonStyle())
        .padding(.horizontal, Theme.Spacing.sm)
    }

    private func closeAndExecute(_ action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}

// MARK: - Custom Button Style
struct MenuItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Theme.Colors.primary.opacity(0.08) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

