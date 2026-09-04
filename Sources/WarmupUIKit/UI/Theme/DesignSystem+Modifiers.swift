//
//  DesignSystem+Modifiers.swift
//  WarmupUIKit
//
//  View modifiers for the DS namespace. These are the primary way new code
//  should consume tokens: `.dsBody()` instead of `.font(DS.Typo.body)`,
//  `.dsTapTarget()` for icon buttons, etc.
//

import SwiftUI
import UIKit

// MARK: - Tap target

public extension View {
    /// Guarantees a 44×44 hit area on icon-only buttons.
    /// Required for accessibility: anything you can tap must be ≥ 44pt per HIG.
    func dsTapTarget(_ size: CGFloat = DS.Space.tapTarget) -> some View {
        self
            .frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}

// MARK: - Icon sizing

public extension Image {
    /// Apply DS icon sizing + weight to an `Image(systemName:)`.
    func dsIcon(_ size: CGFloat = DS.Icon.md, weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: size, weight: weight))
    }
}

// MARK: - Shadow

public extension View {
    func dsShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Dynamic Type typography modifiers
//
// Prefer these over `.font(DS.Typo.body)` — they pull from `DS.TypoX` which
// scales with the user's text size preference. Existing call sites still
// work; new code should use the modifier.

public extension View {
    // Titles carry negative tracking; SwiftUI puts tracking on the view rather than the font,
    // so these are the only place it can live and still come for free at every call site.
    func dsLargeTitle() -> some View { self.font(DS.TypoX.largeTitle).tracking(DS.Track.display) }
    func dsTitle1() -> some View     { self.font(DS.TypoX.title1).tracking(DS.Track.title1) }
    func dsTitle2() -> some View     { self.font(DS.TypoX.title2).tracking(DS.Track.title2) }
    func dsTitle3() -> some View     { self.font(DS.TypoX.title3).tracking(DS.Track.title3) }
    func dsHeadline() -> some View   { self.font(DS.TypoX.headline) }
    func dsBody() -> some View       { self.font(DS.TypoX.body) }
    func dsBodyMedium() -> some View { self.font(DS.TypoX.bodyMedium) }
    func dsCallout() -> some View    { self.font(DS.TypoX.callout) }
    func dsCalloutMedium() -> some View { self.font(DS.TypoX.calloutMedium) }
    func dsSubheadline() -> some View { self.font(DS.TypoX.subheadline) }
    func dsCaption() -> some View    { self.font(DS.TypoX.caption) }
    func dsCaptionMedium() -> some View { self.font(DS.TypoX.captionMedium) }
    func dsEyebrow() -> some View {
        self
            .font(DS.TypoX.eyebrow)
            .tracking(0.5)
            .textCase(.uppercase)
    }
    func dsStat() -> some View       { self.font(DS.TypoX.stat).dsFigures() }
    func dsStatMedium() -> some View { self.font(DS.TypoX.statMedium).dsFigures() }

    // MARK: Figures
    //
    // Mono alone isn't enough: SF's default numerals are proportional, so a column of them
    // still shuffles left and right as the value changes. Tabular figures are what make a
    // stack of readings scan as a table and a live counter stop twitching.

    /// Lock digits to equal width. Free to apply; costs nothing when there are no digits.
    func dsFigures() -> some View { self.monospacedDigit() }

    /// A figure inline in body copy — reps, a weight, a percentage.
    func dsNumeric() -> some View { self.font(DS.TypoX.numeric).dsFigures() }
    func dsNumericMedium() -> some View { self.font(DS.TypoX.numericMedium).dsFigures() }
    func dsNumericCallout() -> some View { self.font(DS.TypoX.numericCallout).dsFigures() }
    func dsNumericCaption() -> some View { self.font(DS.TypoX.numericCaption).dsFigures() }
}

// MARK: - Press

public extension View {
    /// The system's press feedback: a 0.97 scale, never a colour swap.
    ///
    /// Colour-swapping a press means inventing a second brand step for every tinted surface,
    /// and they never agree. Scale reads the same on every fill.
    func dsPressable(_ isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? DS.Motion.pressScale : 1)
            .animation(DS.Motion.tap, value: isPressed)
    }
}

// MARK: - Card with shadow

public extension View {
    /// Card with default elevation. Adds the DS card shadow on top of
    /// `.dsCard()`.
    func dsCardElevated() -> some View {
        self
            .padding(DS.Space.cardPad)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .fill(DS.Color.card)
            )
            .dsShadow(DS.Shadow.card)
    }
}

// MARK: - Reduce-motion-aware animation

public extension View {
    /// Like `.animation(...)` but respects reduce-motion when the value changes.
    func dsAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        self.animation(
            UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0) : animation,
            value: value
        )
    }
}

// MARK: - Disabled overlay style

public extension View {
    /// Standard disabled appearance — fades to disabled color, blocks hits.
    func dsDisabled(_ isDisabled: Bool) -> some View {
        self
            .opacity(isDisabled ? 0.5 : 1.0)
            .allowsHitTesting(!isDisabled)
    }
}
