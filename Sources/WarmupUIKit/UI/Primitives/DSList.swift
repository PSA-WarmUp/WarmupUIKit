//
//  DSList.swift
//  WarmupUIKit
//
//  The list vocabulary every screen in both apps is built from:
//
//    DSSectionHeader   "NEEDS YOU · 4"                         See all
//    DSRowGroup        one 16pt card, rows separated by hairlines
//    DSListRow         avatar · title / meta · trailing action
//    DSRowAction       the capsule on the right of a row ("Draft", "Message")
//    DSAvatar          photo, or initials on a tone
//
//  A screen is: title, then sections; each section is a header and a row group.
//

import SwiftUI

// MARK: - Section header

/// Section label in 13pt semibold uppercase, with an optional count and a trailing link.
public struct DSSectionHeader: View {
    let title: String
    let count: Int?
    let actionTitle: String?
    let action: (() -> Void)?

    public init(_ title: String, count: Int? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.count = count
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(count.map { "\(title) · \($0)" } ?? title)
                .dsEyebrow()
                .foregroundStyle(DS.Color.textSec)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Color.primaryText)
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Row group

/// One card holding rows, with a hairline between rows (not after the last).
///
/// Rows are laid out edge to edge; give each row its own padding (DSListRow does).
@available(iOS 18.0, *)
public struct DSRowGroup<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.offset) { index, subview in
                    subview
                    if index < subviews.count - 1 {
                        DS.Color.hairline
                            .frame(height: DS.Space.hairlineWidth)
                            .padding(.leading, 16)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                .fill(DS.Color.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous))
    }
}

// MARK: - Row

/// A list row: optional leading view, title and meta line, optional trailing view.
/// 64pt tall with a leading view, 52pt without.
public struct DSListRow<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String?
    let subtitleColor: Color
    let leading: Leading
    let trailing: Trailing

    public init(
        _ title: String,
        subtitle: String? = nil,
        subtitleColor: Color = DS.Color.textSec,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleColor = subtitleColor
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .dsRowTitle()
                    .foregroundStyle(DS.Color.text)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .dsRowMeta()
                        .foregroundStyle(subtitleColor)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .padding(.vertical, 10)
        .frame(minHeight: Leading.self == EmptyView.self ? 52 : 64)
        .contentShape(Rectangle())
    }
}

public extension DSListRow where Leading == EmptyView {
    init(_ title: String, subtitle: String? = nil, subtitleColor: Color = DS.Color.textSec,
         @ViewBuilder trailing: () -> Trailing) {
        self.init(title, subtitle: subtitle, subtitleColor: subtitleColor, leading: { EmptyView() }, trailing: trailing)
    }
}

public extension DSListRow where Leading == EmptyView, Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil, subtitleColor: Color = DS.Color.textSec) {
        self.init(title, subtitle: subtitle, subtitleColor: subtitleColor, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

/// A navigation row's trailing chevron.
public struct DSChevron: View {
    public init() {}
    public var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(DS.Color.textTer)
            .accessibilityHidden(true)
    }
}

// MARK: - Row action

/// The capsule on the right of a row. `.soft` (coral) for the one thing to do next,
/// `.neutral` for everything else.
public struct DSRowAction: View {
    public enum Style { case soft, neutral }

    let title: String
    let style: Style
    let action: () -> Void

    public init(_ title: String, style: Style = .neutral, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: {
            DS.Haptic.selection()
            action()
        }) {
            Text(title)
                .font(.system(size: 15, weight: style == .soft ? .semibold : .medium))
                .foregroundStyle(style == .soft ? DS.Color.primaryText : DS.Color.text)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Capsule(style: .continuous).fill(style == .soft ? DS.Color.primarySoft : DS.Color.cardHi))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .fixedSize()
    }
}

// MARK: - Avatar

/// Photo when there is one, otherwise initials on a tone. Tone carries meaning on lists
/// that triage ("Needs you": waiting = amber); elsewhere use `.neutral`.
public struct DSAvatar: View {
    public enum Tone { case neutral, info, success, warning, primary }

    let name: String
    let url: String?
    let size: CGFloat
    let tone: Tone

    public init(_ name: String, url: String? = nil, size: CGFloat = 40, tone: Tone = .neutral) {
        self.name = name
        self.url = url
        self.size = size
        self.tone = tone
    }

    public var body: some View {
        ZStack {
            Circle().fill(colors.bg)
            Text(Self.initials(from: name))
                .font(.system(size: size * 0.375, weight: .semibold))
                .foregroundStyle(colors.fg)
            if let url, !url.isEmpty, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    }
                }
                .clipShape(Circle())
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var colors: (bg: Color, fg: Color) {
        switch tone {
        case .neutral: return (DS.Color.cardHi, DS.Color.text)
        case .info:    return (DS.Color.infoSoft, DS.Color.info)
        case .success: return (DS.Color.successSoft, DS.Color.success)
        case .warning: return (DS.Color.warningSoft, DS.Color.warning)
        case .primary: return (DS.Color.primarySoft, DS.Color.primaryText)
        }
    }

    public static func initials(from name: String) -> String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        let letters = parts.prefix(2).compactMap(\.first).map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }
}
