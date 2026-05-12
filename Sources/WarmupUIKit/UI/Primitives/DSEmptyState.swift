//
//  DSEmptyState.swift
//  WarmupUIKit
//

import SwiftUI

public struct DSEmptyState: View {
    public struct ActionConfig {
        let title: String
        let icon: String?
        let action: () -> Void

        public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
            self.title = title
            self.icon = icon
            self.action = action
        }
    }

    public enum Style {
        /// Inline within a screen (no card, just centered content).
        case inline
        /// Wrapped in a DS card.
        case card
        /// Full-screen primary state (large illustration, big copy).
        case fullscreen
    }

    let icon: String
    let title: String
    let message: String?
    let primaryAction: ActionConfig?
    let secondaryAction: ActionConfig?
    let style: Style

    public init(
        icon: String,
        title: String,
        message: String? = nil,
        primaryAction: ActionConfig? = nil,
        secondaryAction: ActionConfig? = nil,
        style: Style = .card
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.style = style
    }

    public var body: some View {
        VStack(spacing: 14) {
            iconBlock
            VStack(spacing: 6) {
                Text(title)
                    .font(titleFont)
                    .foregroundColor(DS.Color.text)
                    .multilineTextAlignment(.center)
                if let message = message {
                    Text(message)
                        .dsCallout()
                        .foregroundColor(DS.Color.textSec)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            actions
        }
        .padding(.horizontal, DS.Space.gutter)
        .padding(.vertical, style == .fullscreen ? DS.Space.v40 : DS.Space.v24)
        .frame(maxWidth: .infinity)
        .modifier(StyleBackgroundModifier(style: style))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message ?? "")")
    }

    private var titleFont: Font {
        style == .fullscreen ? DS.TypoX.title2 : DS.TypoX.headline
    }

    @ViewBuilder
    private var iconBlock: some View {
        let size: CGFloat = style == .fullscreen ? 56 : 40
        ZStack {
            Circle()
                .fill(DS.Color.primarySoft)
                .frame(width: size + 24, height: size + 24)
            Image(systemName: icon)
                .font(.system(size: size * 0.55, weight: .medium))
                .foregroundColor(DS.Tone.accent)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var actions: some View {
        if primaryAction != nil || secondaryAction != nil {
            VStack(spacing: 8) {
                if let p = primaryAction {
                    DSButton(p.title, icon: p.icon, variant: .primary, size: .md, fullWidth: true, action: p.action)
                }
                if let s = secondaryAction {
                    DSButton(s.title, icon: s.icon, variant: .tertiary, size: .md, fullWidth: true, action: s.action)
                }
            }
            .padding(.top, 4)
        }
    }
}

private struct StyleBackgroundModifier: ViewModifier {
    let style: DSEmptyState.Style
    func body(content: Content) -> some View {
        switch style {
        case .inline, .fullscreen:
            content
        case .card:
            content
                .background(
                    RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                        .fill(DS.Color.card)
                )
                .padding(.horizontal, DS.Space.gutter)
        }
    }
}
