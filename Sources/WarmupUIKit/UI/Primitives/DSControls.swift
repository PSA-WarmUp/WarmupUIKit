//
//  DSControls.swift
//  WarmupUIKit
//
//  Controls shared by every screen in both apps:
//
//    DSFilterChips        "Needs you · 3   All · 18   Leads · 3" — a filter over ONE list
//    DSSegmentedControl   Plan | History | Health — switches between DIFFERENT content
//    DSHeaderIconButton   44pt icon in a header (calendar, bell, +, •••) with an unread dot
//    DSAskBar             the Co-Pilot bar: one tap opens the assistant
//    DSActionTile         icon-over-label tile ("Message · Schedule · Watch live")
//    DSSearchField        44pt search field on a card fill
//

import SwiftUI

// MARK: - Filter chips

public struct DSFilterChip: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let count: Int?

    public init(id: String, title: String, count: Int? = nil) {
        self.id = id
        self.title = title
        self.count = count
    }

    var label: String { count.map { "\(title) · \($0)" } ?? title }
}

/// A row of filter chips. Selected chip is inverted (text color fill); others sit on the card fill.
@available(iOS 17.0, *)
public struct DSFilterChips: View {
    let chips: [DSFilterChip]
    @Binding var selection: String

    public init(_ chips: [DSFilterChip], selection: Binding<String>) {
        self.chips = chips
        self._selection = selection
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    let on = chip.id == selection
                    Button {
                        DS.Haptic.selection()
                        withAnimation(DS.Motion.stateChange) { selection = chip.id }
                    } label: {
                        Text(chip.label)
                            .font(.system(size: 15, weight: on ? .semibold : .regular))
                            .foregroundStyle(on ? DS.Color.chipOnFg : DS.Color.text)
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .background(Capsule(style: .continuous).fill(on ? DS.Color.chipOnBg : DS.Color.card))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
        .scrollClipDisabled()
    }
}

// MARK: - Segmented control

/// Equal-width segments on a raised track; the selected pane steps one surface up the ramp.
public struct DSSegmentedControl: View {
    let items: [String]
    @Binding var selection: Int

    public init(items: [String], selection: Binding<Int>) {
        self.items = items
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(items.indices, id: \.self) { index in
                let on = selection == index
                Button {
                    DS.Haptic.selection()
                    withAnimation(DS.Motion.stateChange) { selection = index }
                } label: {
                    Text(items[index])
                        .font(.system(size: 15, weight: on ? .semibold : .regular))
                        .foregroundStyle(on ? DS.Color.text : DS.Color.textSec)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background {
                            if on {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(DS.Color.segOn)
                                    .shadow(color: .black.opacity(0.12), radius: 1.5, y: 1)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous).fill(DS.Color.cardHi))
    }
}

// MARK: - Header icon button

/// 44pt icon button for a screen header. `style: .plain` draws just the glyph (Today header);
/// `.filled` sits it on a 40pt circle (Library's archive / +). `.accent` is the soft-coral "+".
public struct DSHeaderIconButton: View {
    public enum Style { case plain, filled, accent }

    let systemName: String
    let label: String
    let style: Style
    let showsDot: Bool
    let action: () -> Void

    public init(_ systemName: String, label: String, style: Style = .plain, showsDot: Bool = false,
                action: @escaping () -> Void) {
        self.systemName = systemName
        self.label = label
        self.style = style
        self.showsDot = showsDot
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                switch style {
                case .plain: EmptyView()
                case .filled: Circle().fill(DS.Color.card).frame(width: 40, height: 40)
                case .accent: Circle().fill(DS.Color.primarySoft).frame(width: 40, height: 40)
                }
                Image(systemName: systemName)
                    .font(.system(size: style == .plain ? 20 : 17, weight: .medium))
                    .foregroundStyle(style == .accent ? DS.Color.primaryText : DS.Color.text)
            }
            .frame(width: 44, height: 44)
            .overlay(alignment: .topTrailing) {
                if showsDot {
                    Circle().fill(DS.Color.primary).frame(width: 8, height: 8).offset(x: -9, y: 9)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showsDot ? "\(label), unread" : label)
    }
}

// MARK: - Ask bar

/// The Co-Pilot bar. Not a text field: tapping anywhere opens the assistant sheet, the mic
/// opens it listening. One AI surface per screen.
public struct DSAskBar: View {
    let placeholder: String
    let onTap: () -> Void
    let onMic: (() -> Void)?

    public init(_ placeholder: String = "Draft a workout, plan a week, ask…",
                onTap: @escaping () -> Void, onMic: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onTap = onTap
        self.onMic = onMic
    }

    public var body: some View {
        HStack(spacing: 10) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(DS.Color.primaryText)
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Color.textSec)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ask Co-Pilot")

            if let onMic {
                Button(action: onMic) {
                    Image(systemName: "mic")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DS.Color.text)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(DS.Color.cardHi))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Speak to Co-Pilot")
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .frame(height: 48)
        .background(Capsule(style: .continuous).fill(DS.Color.card))
        .overlay(Capsule(style: .continuous).stroke(DS.Color.hairline, lineWidth: DS.Space.hairlineWidth))
    }
}

// MARK: - Action tile

/// Icon over a 13pt label on a card, 56pt tall. Laid out in an equal-width row.
public struct DSActionTile: View {
    let title: String
    let systemName: String
    let action: () -> Void

    public init(_ title: String, systemName: String, action: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemName).font(.system(size: 18, weight: .medium))
                Text(title).font(.system(size: 13, weight: .semibold)).lineLimit(1)
            }
            .foregroundStyle(DS.Color.text)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(DS.Color.card))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search field

public struct DSSearchField: View {
    let placeholder: String
    @Binding var text: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(DS.Color.textSec)
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundStyle(DS.Color.text)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(DS.Color.textTer)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.Color.card))
    }
}

// MARK: - Screen title

/// The 34pt tab title, or the 28pt page title on a pushed screen.
public struct DSScreenTitle: View {
    public enum Level { case tab, page }
    let text: String
    let level: Level

    public init(_ text: String, level: Level = .tab) {
        self.text = text
        self.level = level
    }

    public var body: some View {
        Text(text)
            .font(.system(size: level == .tab ? 34 : 28, weight: .bold))
            .tracking(level == .tab ? DS.Track.display : DS.Track.title1)
            .foregroundStyle(DS.Color.text)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .accessibilityAddTraits(.isHeader)
    }
}
