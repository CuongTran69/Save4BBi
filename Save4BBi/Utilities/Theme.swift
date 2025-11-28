//
//  Theme.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import SwiftUI

/// Design system based on "Cute & Caring" principles
struct Theme {
    
    // MARK: - Colors
    struct Colors {
        // Primary palette
        static let primary = Color(hex: "A8D8EA")        // Soft pastel blue - calming, medical
        static let secondary = Color(hex: "FFB6B9")      // Warm peach - friendly, caring
        static let accent = Color(hex: "B4E7CE")         // Mint green - fresh, healthy
        static let background = Color(hex: "FFF9F0")     // Cream white - soft, easy on eyes
        static let text = Color(hex: "4A4A4A")           // Charcoal gray - readable
        
        // Semantic colors
        static let success = Color(hex: "B4E7CE")
        static let warning = Color(hex: "FFD93D")
        static let error = Color(hex: "FF6B9D")
        static let info = Color(hex: "A8D8EA")
        
        // UI elements
        static let cardBackground = Color.white
        static let divider = Color.gray.opacity(0.2)
        static let shadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Typography
    struct Typography {
        // Headers - SF Pro Rounded
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Body - SF Pro Text
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let round: CGFloat = 999
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let small = ShadowStyle(radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Animation
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
    }
}

// MARK: - Shadow Style
struct ShadowStyle {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions for Theme
extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Colors.shadow, radius: Theme.Shadow.medium.radius, x: Theme.Shadow.medium.x, y: Theme.Shadow.medium.y)
    }
    
    func primaryButton() -> some View {
        self
            .font(Theme.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.medium)
    }
}

