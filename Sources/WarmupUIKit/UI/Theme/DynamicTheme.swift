//
//  DynamicTheme.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//
//  Dynamic theme colors that adapt to light/dark mode
//

import SwiftUI

// MARK: - Dynamic Colors that adapt to light/dark mode
public struct DynamicTheme {
    public struct Colors {
        // Primary brand colors (consistent across themes)
        public static let primary = Color(hex: "#ff5857")          // Flamingo pink - stays the same
        public static let primaryLight = Color(hex: "#ff7674")
        public static let primaryDark = Color(hex: "#e04746")

        // Secondary brand color - coral/salmon that complements flamingo pink
        public static let secondary = Color(hex: "#ff8c69")        // Coral salmon
        public static let secondaryLight = Color(hex: "#ffa587")
        public static let secondaryDark = Color(hex: "#e67a5b")

        // Dynamic colors that change with theme
        public static let background = Color.dynamicColor(
            light: .white,
            dark: Color(hex: "#0a0a0a")  // Slightly off-black for easier viewing
        )

        public static let surface = Color.dynamicColor(
            light: .white,
            dark: Color(hex: "#1a1a1c")  // Elevated surface
        )

        /// Matches DS.Color.card. Light is white on the grey page so a bare fill is enough to
        /// read as a card; #f9fafb was half a percent off the background it sat on.
        public static let cardBackground = Color.dynamicColor(
            light: .white,
            dark: Color(hex: "#1A1A1E")
        )

        public static let bubbleBackground = Color.dynamicColor(
            light: Color(hex: "#f3f4f6"),
            dark: Color(hex: "#2a2a2c")  // Input fields, bubbles
        )

        // Text colors
        public static let text = Color.dynamicColor(
            light: .black,
            dark: Color(hex: "#ffffff")  // Pure white for contrast
        )

        public static let textSecondary = Color.dynamicColor(
            light: Color(hex: "#6B7280"),
            dark: Color(hex: "#a1a1a3")  // Lighter gray for dark mode
        )

        public static let textTertiary = Color.dynamicColor(
            light: Color(hex: "#9CA3AF"),
            dark: Color(hex: "#6b6b6d")  // Subtle text
        )

        // Borders and dividers
        public static let border = Color.dynamicColor(
            light: Color(hex: "#e5e7eb"),
            dark: Color(hex: "#2f2f31")  // Subtle borders in dark mode
        )

        public static let divider = Color.dynamicColor(
            light: Color(hex: "#d1d5db"),
            dark: Color(hex: "#3a3a3c")  // Slightly visible dividers
        )

        // Chat bubbles
        public static let userBubble = primary  // Always flamingo pink
        public static let aiBubble = Color.dynamicColor(
            light: Color(hex: "#f8fafc"),
            dark: Color(hex: "#1f1f21")  // Match card background in dark
        )

        // Status colors (adjusted for visibility in dark mode)
        public static let success = Color.dynamicColor(
            light: Color(hex: "#10b981"),
            dark: Color(hex: "#34d399")
        )

        public static let warning = Color.dynamicColor(
            light: Color(hex: "#f59e0b"),
            dark: Color(hex: "#fbbf24")
        )

        public static let error = Color.dynamicColor(
            light: Color(hex: "#dc2626"),
            dark: Color(hex: "#f87171")
        )

        public static let info = Color.dynamicColor(
            light: Color(hex: "#3b82f6"),
            dark: Color(hex: "#60a5fa")
        )

        // Primary background for accent areas
        public static let primaryBackground = Color.dynamicColor(
            light: Color(hex: "#fef2f2"),  // Very light pink
            dark: Color(hex: "#2a1a1a")    // Dark with pink tint
        )

        // Additional helpful colors
        public static let secondaryText = textSecondary  // Alias for compatibility

        // Tab bar specific (iOS handles this well, but we can customize)
        public static let tabBarBackground = Color.dynamicColor(
            light: Color(hex: "#ffffff").opacity(0.95),
            dark: Color(hex: "#1a1a1c").opacity(0.95)
        )

        // Navigation bar
        public static let navigationBackground = Color.dynamicColor(
            light: Color(hex: "#ffffff").opacity(0.98),
            dark: Color(hex: "#0a0a0a").opacity(0.98)
        )

        // MARK: - Gradients
        //
        // Kept as symbols, emptied of gradient. A gradient is the loudest thing on a screen and
        // this system is quiet: depth is read from where a surface sits on the neutral ramp, not
        // from a wash. Each of these now resolves to a single flat colour, so the ~55 call sites
        // across both apps keep compiling and simply stop shading.
        //
        // New code should use the colour directly. These remain only so nothing had to be
        // rewritten to get the flat look.

        private static func flat(_ color: Color) -> LinearGradient {
            LinearGradient(colors: [color, color], startPoint: .top, endPoint: .bottom)
        }

        /// Was a warm brand wash on onboarding and feature screens.
        public static let warmGradient = flat(primary)

        /// Was the dark paywall wash.
        public static let premiumGradient = flat(Color.dynamicColor(
            light: Color(hex: "#F0F0F2"), dark: Color(hex: "#1A1A1E")))

        /// Was the flamingo brand wash.
        public static let primaryGradient = flat(primary)

        /// Was the subtle page wash.
        public static let subtleGradient = flat(Color.dynamicColor(
            light: Color(hex: "#F5F5F7"), dark: Color(hex: "#0B0B0D")))
    }

    // Keep all the same spacing, radius, typography from Theme.swift
    public struct Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let card: CGFloat = 20        // Card-specific padding for richer feel
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let section: CGFloat = 32     // Spacing between sections
        public static let xxl: CGFloat = 48
    }

    public struct Radius {
        public static let xs: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let bubble: CGFloat = 20
        public static let round: CGFloat = 50
    }

    public struct Typography {
        // Display styles - increased size jump for better hierarchy
        public static let largeTitle = Font.system(size: 34, weight: .bold)
        public static let title = Font.system(size: 32, weight: .bold)
        public static let title2 = Font.system(size: 24, weight: .semibold)
        public static let title3 = Font.system(size: 20, weight: .semibold)

        // Body styles
        public static let headline = Font.system(size: 17, weight: .semibold)
        public static let body = Font.system(size: 16, weight: .regular)
        public static let bodyMedium = Font.system(size: 16, weight: .medium)
        public static let bodyLight = Font.system(size: 16, weight: .light)
        public static let callout = Font.system(size: 15, weight: .regular)
        public static let subheadline = Font.system(size: 14, weight: .regular)

        // Small styles - added light variants for tertiary text
        public static let footnote = Font.system(size: 13, weight: .regular)
        public static let footnoteLight = Font.system(size: 13, weight: .light)
        public static let caption = Font.system(size: 13, weight: .regular)
        public static let captionMedium = Font.system(size: 13, weight: .medium)
        public static let captionLight = Font.system(size: 13, weight: .light)

        // Micro text for badges, tags
        public static let micro = Font.system(size: 11, weight: .medium, design: .monospaced)
    }

    public struct Animations {
        public static let quick = Animation.easeInOut(duration: 0.2)
        public static let standard = Animation.easeInOut(duration: 0.3)
        public static let slow = Animation.easeInOut(duration: 0.5)
        public static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
        public static let springBouncy = Animation.spring(response: 0.6, dampingFraction: 0.7)
    }

    public struct Shadows {
        // Updated shadows: softer opacity (0.04-0.06), larger blur (8-16pt) for premium feel
        public static let small = Shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        public static let medium = Shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        public static let large = Shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)

        // Card-specific shadow for richer depth
        public static let card = Shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)

        public struct Shadow {
            public let color: Color
            public let radius: CGFloat
            public let x: CGFloat
            public let y: CGFloat

            public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
                self.color = color
                self.radius = radius
                self.x = x
                self.y = y
            }
        }
    }
}

// MARK: - Semantic Color Groups (for easier usage)
public extension DynamicTheme.Colors {
    struct Text {
        public static let primary = DynamicTheme.Colors.text
        public static let secondary = DynamicTheme.Colors.textSecondary
        public static let tertiary = DynamicTheme.Colors.textTertiary
        public static let inverse = Color.dynamicColor(
            light: Color.white,
            dark: Color.black
        )
        public static let accent = DynamicTheme.Colors.primary
    }

    struct Background {
        public static let primary = DynamicTheme.Colors.background
        public static let secondary = DynamicTheme.Colors.cardBackground
        public static let surface = DynamicTheme.Colors.surface
        public static let accent = DynamicTheme.Colors.primaryBackground
    }

    struct Interactive {
        public static let primary = DynamicTheme.Colors.primary
        public static let primaryHover = DynamicTheme.Colors.primaryDark
        public static let primaryPressed = DynamicTheme.Colors.primaryDark
        public static let secondary = DynamicTheme.Colors.cardBackground
        /// Disabled FILL, not tertiary text. A disabled control should read as an inert
        /// surface; tinting it like faint text made it look like a label someone forgot to
        /// style. Pair with `DS.Color.onDisabled` for the label on top.
        public static let disabled = DS.Color.disabled
    }
}
