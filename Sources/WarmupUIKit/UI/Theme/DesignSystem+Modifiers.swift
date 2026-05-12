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
    func dsLargeTitle() -> some View { self.font(DS.TypoX.largeTitle) }
    func dsTitle1() -> some View     { self.font(DS.TypoX.title1) }
    func dsTitle2() -> some View     { self.font(DS.TypoX.title2) }
    func dsTitle3() -> some View     { self.font(DS.TypoX.title3) }
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
    func dsStat() -> some View       { self.font(DS.TypoX.stat) }
    func dsStatMedium() -> some View { self.font(DS.TypoX.statMedium) }
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
