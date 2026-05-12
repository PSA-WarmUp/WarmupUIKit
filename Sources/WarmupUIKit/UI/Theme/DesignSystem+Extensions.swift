//
//  DesignSystem+Extensions.swift
//  WarmupUIKit
//
//  Extends the DS namespace with the foundation layers the trainer redesign
//  needed: shadow tokens, an icon-sizing scale, an expanded motion enum that
//  respects reduce-motion, a brand-tone split for the trainer/athlete fork,
//  haptics, a disabled color, extra spacing tokens, and a Dynamic-Type-aware
//  typography ladder.
//
//  Lifted from `warmup-trainer/Core/DesignSystem/DSTokens.swift` so both the
//  trainer and athlete apps can consume the same primitives.
//

import SwiftUI
import UIKit

// MARK: - Color additions

public extension DS.Color {
    /// Disabled control fill (replaces misuse of textSecondary).
    static let disabled = SwiftUI.Color.dynamicColor(
        light: SwiftUI.Color(hex: "#D1D1D6"),
        dark: SwiftUI.Color(hex: "#3A3A3C")
    )

    /// On-disabled text color.
    static let onDisabled = SwiftUI.Color.dynamicColor(
        light: SwiftUI.Color(hex: "#8E8E93"),
        dark: SwiftUI.Color(hex: "#6B6B70")
    )

    /// Soft error fill (badges, validation).
    static let errorSoft = SwiftUI.Color(hex: "#FF3B30").opacity(0.12)

    /// On-primary text — explicit so dark/light don't accidentally invert.
    static let onPrimary = SwiftUI.Color.white

    /// On-semantic (success/warning/error fills) text.
    static let onSemantic = SwiftUI.Color.white
}

// MARK: - Spacing additions

public extension DS.Space {
    /// Apple HIG minimum tap target.
    static let tapTarget: CGFloat = 44

    /// Standard between-section spacing.
    static let section: CGFloat = 32

    /// Vertical rhythm extras.
    static let v32: CGFloat = 32
    static let v40: CGFloat = 40
    static let v48: CGFloat = 48

    /// Standard sheet header height.
    static let sheetHeader: CGFloat = 56
}

// MARK: - Shadow

public struct DSShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension DS {
    enum Shadow {
        /// Card-level elevation. Near-clear in dark mode (use bg lightness instead).
        public static let card = DSShadow(
            color: SwiftUI.Color.dynamicColor(
                light: .black.opacity(0.04),
                dark: .clear
            ),
            radius: 12, x: 0, y: 4
        )

        /// Elevated surfaces (FABs, popovers).
        public static let elevated = DSShadow(
            color: SwiftUI.Color.dynamicColor(
                light: .black.opacity(0.08),
                dark: .black.opacity(0.4)
            ),
            radius: 20, x: 0, y: 8
        )

        /// Overlay layers (dropdowns, tooltips).
        public static let overlay = DSShadow(
            color: SwiftUI.Color.dynamicColor(
                light: .black.opacity(0.15),
                dark: .black.opacity(0.6)
            ),
            radius: 40, x: 0, y: 16
        )
    }
}

// MARK: - Icon sizing scale

public extension DS {
    enum Icon {
        public static let sm: CGFloat = 14
        public static let md: CGFloat = 18
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }
}

// MARK: - Motion (with reduce-motion)

public extension DS.Motion {
    /// Quick tap response. Linear when reduce-motion is enabled.
    static var tap: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .spring(response: 0.25, dampingFraction: 0.85)
    }

    /// Sheet/modal transitions.
    static var sheet: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0.1)
            : .spring(response: 0.4, dampingFraction: 0.85)
    }

    /// Snappy spring.
    static var snappy: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .spring(response: 0.3, dampingFraction: 0.9)
    }

    /// Bouncy spring (use sparingly).
    static var bouncy: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .spring(response: 0.5, dampingFraction: 0.65)
    }
}

// MARK: - Tone (multi-app brand variants)

public extension DS {
    enum AppTone {
        case trainer
        case athlete
    }

    enum Tone {
        /// Resolve at runtime. Trainer or athlete app sets this on launch.
        public static var current: AppTone = .trainer

        /// Accent color per tone.
        public static var accent: SwiftUI.Color {
            switch current {
            case .trainer: return DS.Color.primary
            case .athlete: return SwiftUI.Color(hex: "#FF7A45") // warmer coral for athletes
            }
        }

        /// Default font design per tone.
        public static var titleDesign: Font.Design {
            switch current {
            case .trainer: return .rounded
            case .athlete: return .rounded
            }
        }
    }
}

// MARK: - Dynamic-Type-aware typography ladder
//
// Existing `DS.Typo.*` uses fixed point sizes for the original Quiet Pro spec.
// `DS.TypoX.*` is the Dynamic-Type-aware ladder — new code should prefer the
// view modifiers (`.dsBody()`, `.dsTitle1()`) which read from this ladder, so
// user-set text sizes scale the UI.

public extension DS {
    enum TypoX {
        public static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        public static let title1     = Font.system(.title, design: .rounded).weight(.bold)
        public static let title2     = Font.system(.title2, design: .rounded).weight(.semibold)
        public static let title3     = Font.system(.title3, design: .rounded).weight(.semibold)
        public static let headline   = Font.system(.headline, design: .default).weight(.semibold)
        public static let body       = Font.system(.body, design: .default).weight(.regular)
        public static let bodyMedium = Font.system(.body, design: .default).weight(.medium)
        public static let callout    = Font.system(.callout, design: .default).weight(.regular)
        public static let calloutMedium = Font.system(.callout, design: .default).weight(.medium)
        public static let subheadline = Font.system(.subheadline, design: .default).weight(.regular)
        public static let caption     = Font.system(.caption, design: .default).weight(.regular)
        public static let captionMedium = Font.system(.caption, design: .default).weight(.medium)
        public static let eyebrow     = Font.system(.caption2, design: .default).weight(.semibold)
        public static let stat        = Font.system(.largeTitle, design: .rounded).weight(.bold)
        public static let statMedium  = Font.system(.title2, design: .rounded).weight(.bold)
    }
}

// MARK: - Haptics

public extension DS {
    enum Haptic {
        public static func light() {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.impactOccurred()
        }
        public static func medium() {
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.impactOccurred()
        }
        public static func soft() {
            let g = UIImpactFeedbackGenerator(style: .soft)
            g.impactOccurred()
        }
        public static func success() {
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.success)
        }
        public static func warning() {
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.warning)
        }
        public static func error() {
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.error)
        }
        public static func selection() {
            let g = UISelectionFeedbackGenerator()
            g.selectionChanged()
        }
    }
}
