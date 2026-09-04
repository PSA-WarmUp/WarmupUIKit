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
    /// Quick tap response — 250ms on the system curve.
    static var tap: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.25)
    }

    /// Sheet/modal transitions — 400ms.
    static var sheet: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0.1)
            : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.40)
    }

    /// Snappy — a state change, 180ms.
    static var snappy: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.18)
    }

    /// Was a bouncy spring. Now the same curve as everything else.
    ///
    /// The source marked this "use sparingly", which in practice meant it appeared wherever
    /// something wanted attention. A single overshooting element is the loudest thing on an
    /// otherwise still screen, and this system doesn't raise its voice. Kept as a name so call
    /// sites still compile; it no longer bounces.
    static var bouncy: Animation {
        UIAccessibility.isReduceMotionEnabled
            ? .linear(duration: 0)
            : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.25)
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
        ///
        /// Both apps answer `.default` now. The fork stays because the accent still differs,
        /// but the face does not: rounded titles read consumer-app, and one product reading as
        /// instrumentation while the other reads as a fitness tracker is not a tone difference,
        /// it is two design systems.
        public static var titleDesign: Font.Design {
            switch current {
            case .trainer: return .default
            case .athlete: return .default
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
        public static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
        public static let title1     = Font.system(.title, design: .default).weight(.bold)
        public static let title2     = Font.system(.title2, design: .default).weight(.semibold)
        public static let title3     = Font.system(.title3, design: .default).weight(.semibold)
        public static let headline   = Font.system(.headline, design: .default).weight(.semibold)
        public static let body       = Font.system(.body, design: .default).weight(.regular)
        public static let bodyMedium = Font.system(.body, design: .default).weight(.medium)
        public static let callout    = Font.system(.callout, design: .default).weight(.regular)
        public static let calloutMedium = Font.system(.callout, design: .default).weight(.medium)
        public static let subheadline = Font.system(.subheadline, design: .default).weight(.regular)
        public static let caption     = Font.system(.caption, design: .default).weight(.regular)
        public static let captionMedium = Font.system(.caption, design: .default).weight(.medium)
        public static let eyebrow     = Font.system(.caption2, design: .monospaced).weight(.semibold)
        public static let stat        = Font.system(.largeTitle, design: .monospaced).weight(.semibold)
        public static let statMedium  = Font.system(.title2, design: .monospaced).weight(.semibold)
        /// Figures inline in text, at each text size.
        public static let numeric     = Font.system(.body, design: .monospaced).weight(.regular)
        public static let numericMedium = Font.system(.body, design: .monospaced).weight(.medium)
        public static let numericCallout = Font.system(.callout, design: .monospaced).weight(.medium)
        public static let numericCaption = Font.system(.caption, design: .monospaced).weight(.regular)
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
