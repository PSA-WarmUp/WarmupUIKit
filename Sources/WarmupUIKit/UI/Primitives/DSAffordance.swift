//
//  DSAffordance.swift
//  WarmupUIKit
//
//  D4 — editable-vs-static affordance convention.
//
//  One reusable rule for the whole design system: an element that is
//  tappable or editable must *look* different from a plain, static label.
//
//  • Interactive: a real tap target (≥ 44pt), a card fill + hairline border,
//    and (optionally) a trailing glyph — a chevron for "opens something",
//    a pencil for "edit in place".
//  • Static: visually plain — no border, no fill, no glyph.
//
//  Consume it via the convenience modifiers, which are the intended API:
//      Text(reps).dsInteractiveField(glyph: .edit) { … }   // tappable/editable
//      Text(name).dsStaticLabel()                           // plain
//  or the enum-driven single entry point when the state is data-driven:
//      Text(value).dsAffordance(isEditable ? .interactive : .static)
//
//  All colors resolve from the DS token layer, so light/dark is automatic.
//

import SwiftUI

// MARK: - Affordance kind

/// Whether an element advertises that it can be interacted with, or reads as
/// a plain static label. This is the single knob the D4 convention turns.
public enum DSAffordance {
    /// Tappable: gets a tap target, border + fill, and a glyph naming the result.
    case interactive
    /// Editable in place: the interactive container plus a pencil, and a focus ring that
    /// makes "I am typing here" unambiguous.
    ///
    /// Split out from `.interactive` because they answer different questions. A tappable row
    /// says "this goes somewhere"; an editable field says "this value is yours to change".
    /// Rendering them identically is why clients could not tell which values they could edit
    /// and which ones the app had decided for them.
    case editable
    /// Read-only: rendered plain, with no interactive chrome.
    case `static`
}

// MARK: - Trailing glyph

/// The trailing affordance glyph on an interactive element. Picks the icon
/// that matches the *kind* of interaction so the user can predict the result.
public enum DSAffordanceGlyph {
    /// Opens a picker / navigates / reveals more (`chevron.right`).
    case chevron
    /// Edits the value in place (`pencil`).
    case edit
    /// No trailing glyph — the border + fill alone carry the affordance.
    case none

    var systemName: String? {
        switch self {
        case .chevron: return "chevron.right"
        case .edit:    return "pencil"
        case .none:    return nil
        }
    }
}

// MARK: - Core modifier

/// The one modifier that implements the D4 convention. Prefer the
/// `.dsInteractiveField(…)` / `.dsStaticLabel()` conveniences at call sites;
/// this is exposed for data-driven use via `.dsAffordance(…)`.
public struct DSAffordanceModifier: ViewModifier {
    let affordance: DSAffordance
    let glyph: DSAffordanceGlyph
    /// Draws the accent border (focused / active / selected), mirroring the
    /// focus treatment of `DSTextField`.
    let isEmphasized: Bool
    /// Pushes the glyph to the trailing edge and lets the row own its width,
    /// so it reads as a full field. Set `false` for compact inline chips.
    let fillWidth: Bool

    public init(
        affordance: DSAffordance,
        glyph: DSAffordanceGlyph = .chevron,
        isEmphasized: Bool = false,
        fillWidth: Bool = true
    ) {
        self.affordance = affordance
        self.glyph = glyph
        self.isEmphasized = isEmphasized
        self.fillWidth = fillWidth
    }

    public func body(content: Content) -> some View {
        switch affordance {
        case .static:
            // Visually plain. No border, no fill, no glyph — the whole point
            // of the convention is that static text carries no affordance.
            content

        case .interactive, .editable:
            HStack(spacing: DS.Space.v8) {
                content
                if fillWidth {
                    Spacer(minLength: DS.Space.v8)
                }
                if let name = resolvedGlyph.systemName {
                    Image(systemName: name)
                        .dsIcon(DS.Icon.sm, weight: .semibold)
                        .foregroundStyle(glyphColor)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DS.Space.v12)
            .frame(minHeight: DS.Space.tapTarget)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                    .fill(DS.Color.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous))
            .contentShape(Rectangle())
            .dsAnimation(DS.Motion.tap, value: isEmphasized)
        }
    }

    /// An editable field always advertises the pencil, even when the caller passed nothing —
    /// the glyph IS how "you can change this" is said. A tappable row keeps whatever it asked for.
    private var resolvedGlyph: DSAffordanceGlyph {
        if affordance == .editable, glyph == .chevron || glyph == .none { return .edit }
        return glyph
    }

    private var borderColor: Color {
        isEmphasized ? DS.Tone.accent : DS.Color.hairlineStrong
    }

    private var borderWidth: CGFloat {
        isEmphasized ? 1.5 : DS.Space.hairlineWidth
    }

    private var glyphColor: Color {
        isEmphasized ? DS.Tone.accent : DS.Color.textSec
    }
}

// MARK: - Convenience modifiers (the intended call-site API)

public extension View {
    /// Enum-driven entry point — use when the affordance is data-driven and you
    /// want a single call site that flips between plain and interactive.
    ///
    /// - Parameters:
    ///   - affordance: `.interactive` for tappable/editable, `.static` for plain.
    ///   - glyph: trailing glyph for the interactive variant (ignored when static).
    ///   - isEmphasized: draw the accent border (focused / active / selected).
    ///   - fillWidth: push the glyph to the trailing edge and own the row width.
    func dsAffordance(
        _ affordance: DSAffordance,
        glyph: DSAffordanceGlyph = .chevron,
        isEmphasized: Bool = false,
        fillWidth: Bool = true
    ) -> some View {
        modifier(DSAffordanceModifier(
            affordance: affordance,
            glyph: glyph,
            isEmphasized: isEmphasized,
            fillWidth: fillWidth
        ))
    }

    /// Marks a view as an interactive (tappable / editable) field: tap target,
    /// card fill, hairline border, and a trailing glyph. Wrap the result in a
    /// `Button`/`onTapGesture` (or make the content a `TextField`) to wire the
    /// behavior — this modifier only supplies the *affordance*.
    ///
    /// - Parameters:
    ///   - glyph: `.chevron` (opens/navigates), `.edit` (edit in place), or `.none`.
    ///   - isEmphasized: draw the accent border when focused / active / selected.
    ///   - fillWidth: `true` (default) for a full-width field row; `false` to hug content.
    func dsInteractiveField(
        glyph: DSAffordanceGlyph = .chevron,
        isEmphasized: Bool = false,
        fillWidth: Bool = true
    ) -> some View {
        dsAffordance(.interactive, glyph: glyph, isEmphasized: isEmphasized, fillWidth: fillWidth)
    }

    /// Marks a view as a static, read-only label — rendered plain, with no
    /// interactive chrome. The passive half of the D4 convention.
    func dsStaticLabel() -> some View {
        dsAffordance(.static)
    }

    /// Marks a value the user can change in place. Carries the pencil by default; pass
    /// `isEmphasized: true` while the field has focus so the border grows to the accent.
    func dsEditableField(isEmphasized: Bool = false, fillWidth: Bool = true) -> some View {
        dsAffordance(.editable, glyph: .edit, isEmphasized: isEmphasized, fillWidth: fillWidth)
    }
}

// MARK: - Preview

#Preview("D4 · Interactive vs Static") {
    VStack(alignment: .leading, spacing: DS.Space.v24) {

        // Interactive — advertises that it can be changed.
        VStack(alignment: .leading, spacing: DS.Space.v12) {
            Text("Interactive")
                .dsEyebrow()
                .foregroundStyle(DS.Color.textSec)

            Text("135 lb")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsInteractiveField(glyph: .edit)

            Text("Chest · Push")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsInteractiveField(glyph: .chevron)

            Text("8 reps")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsInteractiveField(glyph: .edit, isEmphasized: true) // focused

            HStack(spacing: DS.Space.v8) {
                Text("Set 1")
                    .dsBodyMedium()
                    .foregroundStyle(DS.Color.text)
                    .dsInteractiveField(glyph: .none, fillWidth: false)
                Text("Set 2")
                    .dsBodyMedium()
                    .foregroundStyle(DS.Color.text)
                    .dsInteractiveField(glyph: .none, fillWidth: false)
            }
        }

        DSHairline()

        // Static — plain, no affordance.
        VStack(alignment: .leading, spacing: DS.Space.v12) {
            Text("Static")
                .dsEyebrow()
                .foregroundStyle(DS.Color.textSec)

            Text("135 lb")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsStaticLabel()

            Text("Chest · Push")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsStaticLabel()

            Text("8 reps")
                .dsBodyMedium()
                .foregroundStyle(DS.Color.text)
                .dsStaticLabel()
        }

        Spacer()
    }
    .padding(DS.Space.gutter)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(DS.Color.bg)
}
