//
//  DesignSystem.swift
//  WarmupUIKit
//
//  Quiet Pro / V2 Trainer OS design system.
//  Dark-first, data-dense, minimal aesthetic.
//  Shared between trainer and client apps.
//

import SwiftUI

// MARK: - DS Namespace

public enum DS {

    // MARK: - Colors

    public enum Color {
        /// Main background
        public static let bg = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#F5F5F7"),
            dark: SwiftUI.Color(hex: "#0B0B0D")
        )

        /// Elevated surface (tab bar, nav bar)
        public static let surface = SwiftUI.Color.dynamicColor(
            light: .white,
            dark: SwiftUI.Color(hex: "#141418")
        )

        /// Card background
        public static let card = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#F0F0F2"),
            dark: SwiftUI.Color(hex: "#1A1A1E")
        )

        /// Highlighted card / hover state
        public static let cardHi = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#E8E8EC"),
            dark: SwiftUI.Color(hex: "#212126")
        )

        /// Subtle divider
        public static let hairline = SwiftUI.Color.dynamicColor(
            light: .black.opacity(0.06),
            dark: .white.opacity(0.06)
        )

        /// Stronger divider
        public static let hairlineStrong = SwiftUI.Color.dynamicColor(
            light: .black.opacity(0.10),
            dark: .white.opacity(0.10)
        )

        /// Primary text
        public static let text = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#1C1C1E"),
            dark: SwiftUI.Color(hex: "#F5F5F7")
        )

        /// Secondary text
        public static let textSec = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#6B6B70"),
            dark: SwiftUI.Color(hex: "#8E8E93")
        )

        /// Tertiary text
        public static let textTer = SwiftUI.Color.dynamicColor(
            light: SwiftUI.Color(hex: "#AEAEB2"),
            dark: SwiftUI.Color(hex: "#5A5A5F")
        )

        /// Brand primary — flamingo red
        public static let primary = SwiftUI.Color(hex: "#FF5857")

        /// Brand hover / light step
        public static let primaryLight = SwiftUI.Color(hex: "#FF7674")

        /// Brand pressed step
        public static let primaryPressed = SwiftUI.Color(hex: "#E04746")

        /// Warm secondary — coral salmon. Never a second accent in the same view.
        public static let secondary = SwiftUI.Color(hex: "#FF8C69")

        /// Lightest warm step
        public static let secondaryLight = SwiftUI.Color(hex: "#FFA587")

        /// Barely-there brand wash for a selected row
        public static let primaryTint = SwiftUI.Color(hex: "#FF5857").opacity(0.06)

        // MARK: Provenance
        //
        // The most important colour rule here: coral is data that exists because a coach wrote
        // it and a client did it (volume, sets, RPE, adherence); blue is measured by a sensor we
        // don't own (HRV, resting HR, sleep). Because it never varies, a chart carrying both is
        // visibly a joined chart and no tile needs a logo explaining itself. The health side
        // stays deliberately unbranded — it may be a different provider tomorrow.

        /// Data WarmUp produced
        public static let dataLoad = SwiftUI.Color(hex: "#FF5857")

        /// Data a connected health source measured
        public static let dataBody = SwiftUI.Color(hex: "#5B8DD9")

        /// Soft primary fill (badges, pills)
        public static let primarySoft = SwiftUI.Color(hex: "#FF5857").opacity(0.12)

        /// Success green
        public static let success = SwiftUI.Color(hex: "#30D158")

        /// Soft success fill
        public static let successSoft = SwiftUI.Color(hex: "#30D158").opacity(0.12)

        /// Warning / amber
        public static let warning = SwiftUI.Color(hex: "#FF9F0A")

        /// Soft warning fill
        public static let warningSoft = SwiftUI.Color(hex: "#FF9F0A").opacity(0.12)

        /// Info / blue
        public static let info = SwiftUI.Color(hex: "#0A84FF")

        /// Soft info fill
        public static let infoSoft = SwiftUI.Color(hex: "#0A84FF").opacity(0.12)

        /// Error red (distinct from primary for semantics)
        public static let error = SwiftUI.Color(hex: "#FF3B30")

        // MARK: Avatar palette

        /// Deterministic avatar colors — each name always maps to the same pair.
        public static let avatarPalette: [(bg: SwiftUI.Color, fg: SwiftUI.Color)] = [
            (SwiftUI.Color(hex: "#30D158").opacity(0.14), SwiftUI.Color(hex: "#30D158")), // teal-green
            (SwiftUI.Color(hex: "#BF5AF2").opacity(0.14), SwiftUI.Color(hex: "#BF5AF2")), // purple
            (SwiftUI.Color(hex: "#FF9F0A").opacity(0.14), SwiftUI.Color(hex: "#FF9F0A")), // orange
            (SwiftUI.Color(hex: "#0A84FF").opacity(0.14), SwiftUI.Color(hex: "#0A84FF")), // blue
            (SwiftUI.Color(hex: "#64D2FF").opacity(0.14), SwiftUI.Color(hex: "#64D2FF")), // cyan
            (SwiftUI.Color(hex: "#FF375F").opacity(0.14), SwiftUI.Color(hex: "#FF375F")), // pink
        ]

        /// Returns a deterministic (bg, fg) color pair for the given name.
        public static func avatar(for name: String) -> (bg: SwiftUI.Color, fg: SwiftUI.Color) {
            guard !name.isEmpty else { return (primarySoft, primary) }
            let hash = name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
            return avatarPalette[abs(hash) % avatarPalette.count]
        }
    }

    // MARK: - Typography

    /// Titles in the system text face; every numeral in mono.
    ///
    /// Rounded numerals read friendly-consumer; monospaced numerals read instrument. That swap
    /// is the biggest visual change in this system, and it is why a column of figures now lines
    /// up: pair these with `.dsFigures()` so the digits are tabular as well as mono.
    ///
    /// Titles lost `design: .rounded` for the same reason — the interface should read as
    /// instrumentation with an agent attached, and rounded titles fight that everywhere they
    /// appear. Sizes and weights are unchanged, so nothing reflows.
    public enum Typo {
        /// 32pt bold, -0.8 tracking
        public static let largeTitle = Font.system(size: 32, weight: .bold)
        /// 28pt bold, -0.6 tracking
        public static let title1 = Font.system(size: 28, weight: .bold)
        /// 20pt semibold, -0.4 tracking
        public static let title2 = Font.system(size: 20, weight: .semibold)
        /// 17pt semibold, -0.2 tracking
        public static let title3 = Font.system(size: 17, weight: .semibold)
        /// 15pt regular default
        public static let body = Font.system(size: 15, weight: .regular)
        /// 15pt medium default
        public static let bodyMedium = Font.system(size: 15, weight: .medium)
        /// 14pt regular default
        public static let callout = Font.system(size: 14, weight: .regular)
        /// 14pt medium default
        public static let calloutMedium = Font.system(size: 14, weight: .medium)
        /// 12pt regular default
        public static let caption = Font.system(size: 12, weight: .regular)
        /// 12pt medium default
        public static let captionMedium = Font.system(size: 12, weight: .medium)
        /// 11pt semibold mono, uppercase, +0.5 tracking (applied via `.dsEyebrow()`)
        public static let eyebrow = Font.system(size: 11, weight: .semibold, design: .monospaced)
        /// 40pt semibold mono — hero stat numbers
        public static let stat = Font.system(size: 40, weight: .semibold, design: .monospaced)
        /// 24pt semibold mono — medium stat numbers
        public static let statMedium = Font.system(size: 24, weight: .semibold, design: .monospaced)
        /// 15pt semibold default — headline/emphasized body
        public static let headline = Font.system(size: 15, weight: .semibold)
        /// 13pt regular default — subheadline
        public static let subheadline = Font.system(size: 13, weight: .regular)

        // MARK: Numerals inline in text
        //
        // Any figure that appears mid-sentence or in a table cell — reps, weights, dates,
        // durations, percentages. Same point sizes as the text roles they sit beside, so a
        // number never changes the line height of the row it is in.

        /// 15pt mono — a figure sitting in body copy
        public static let numeric = Font.system(size: 15, weight: .regular, design: .monospaced)
        /// 15pt medium mono — an emphasised figure in body copy
        public static let numericMedium = Font.system(size: 15, weight: .medium, design: .monospaced)
        /// 14pt mono — a figure in a callout row
        public static let numericCallout = Font.system(size: 14, weight: .medium, design: .monospaced)
        /// 12pt mono — a figure in a caption or table cell
        public static let numericCaption = Font.system(size: 12, weight: .regular, design: .monospaced)
    }

    // MARK: - Tracking
    //
    // SwiftUI carries tracking on the view, not the font, so the ladder above can't hold it.
    // These are the source's values; `.dsTitle*()` applies them for you.

    public enum Track {
        public static let display: CGFloat = -0.8
        public static let title1: CGFloat = -0.6
        public static let title2: CGFloat = -0.4
        public static let title3: CGFloat = -0.2
        public static let eyebrow: CGFloat = 0.5
        public static let pill: CGFloat = 0.3
    }

    // MARK: - Spacing

    public enum Space {
        /// Horizontal gutter
        public static let gutter: CGFloat = 20
        /// Card corner radius
        public static let cardRadius: CGFloat = 16
        /// Inner element radius
        public static let innerRadius: CGFloat = 10
        /// Small element radius (chips, pills)
        public static let smallRadius: CGFloat = 8
        /// Card internal padding
        public static let cardPad: CGFloat = 16
        /// Hairline stroke width
        public static let hairlineWidth: CGFloat = 0.5

        /// Tightest radius — tags, inline marks
        public static let xsRadius: CGFloat = 4
        /// Chat bubble radius
        public static let bubbleRadius: CGFloat = 20
        /// Fully rounded — pills, avatars
        public static let pillRadius: CGFloat = 999

        // Button radii by size
        public static let buttonRadiusSmall: CGFloat = 10
        public static let buttonRadiusMedium: CGFloat = 12
        public static let buttonRadiusLarge: CGFloat = 14

        // Vertical rhythm
        public static let v4: CGFloat = 4
        public static let v8: CGFloat = 8
        public static let v12: CGFloat = 12
        public static let v16: CGFloat = 16
        public static let v20: CGFloat = 20
        public static let v24: CGFloat = 24
    }

    // MARK: - Motion

    public enum Motion {
        /// The system curve. Everything decelerates into place; nothing overshoots.
        public static let curve = Animation.timingCurve(0.2, 0.8, 0.2, 1)

        /// State change: 180ms. (`tap`, `sheet`, `snappy` live in the extension alongside
        /// their reduce-motion fallbacks.)
        public static let stateChange = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.18)
        /// Reveal / sheet: 400ms
        public static let reveal = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.40)

        /// Press scale. The source's `scaleEffect(0.97)` — a press is never a colour swap.
        public static let pressScale: CGFloat = 0.97
    }
}

// MARK: - DS View Modifiers

extension View {
    /// Card style: card bg, 16pt radius, no shadow
    public func dsCard() -> some View {
        self
            .padding(DS.Space.cardPad)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .fill(DS.Color.card)
            )
    }

    /// Highlighted card style
    public func dsCardHi() -> some View {
        self
            .padding(DS.Space.cardPad)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .fill(DS.Color.cardHi)
            )
    }

    /// Surface background
    public func dsSurface() -> some View {
        self.background(DS.Color.surface)
    }

    /// 20pt horizontal gutter padding
    public func dsGutter() -> some View {
        self.padding(.horizontal, DS.Space.gutter)
    }
}
