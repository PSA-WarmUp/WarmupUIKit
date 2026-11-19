//
//  DSPersonCard.swift
//  WarmupUIKit
//
//  A person waiting on a decision, as one card:
//
//    (TB)  Tom Baker
//          Assessment request
//    Thu, Nov 19 · 5:00 PM · paid
//    [      Confirm      ] [ Decline ]
//
//  Used wherever a request needs an answer (assessment requests, matches, quote requests,
//  follow and connection requests) so they all read and act the same way.
//

import SwiftUI

/// Avatar, name, what kind of request it is, an optional detail line and note, then a row of
/// `DSCardButton`s.
public struct DSPersonCard<Actions: View>: View {
    let name: String
    let imageURL: String?
    let kind: String
    let detail: String?
    let note: String?
    let actions: Actions

    public init(_ name: String,
                imageURL: String? = nil,
                kind: String,
                detail: String? = nil,
                note: String? = nil,
                @ViewBuilder actions: () -> Actions) {
        self.name = name
        self.imageURL = imageURL
        self.kind = kind
        self.detail = detail
        self.note = note
        self.actions = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                DSAvatar(name, url: imageURL, size: 44, tone: .primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .dsRowTitle()
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(1)
                    Text(kind)
                        .dsRowMeta()
                        .foregroundStyle(DS.Color.textSec)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Color.textBody)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let note, !note.isEmpty {
                Text(note)
                    .font(.system(size: 15))
                    .italic()
                    .foregroundStyle(DS.Color.textSec)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 8) { actions }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                .fill(DS.Color.card)
        )
    }
}

/// A 44pt button inside a card. `.filled` is coral (one per screen — give it to the first card
/// only), `.soft` is coral on a tint, `.neutral` is the raised grey. `grows` lets it take the
/// row's spare width.
public struct DSCardButton: View {
    public enum Style { case filled, soft, neutral }

    let title: String
    let style: Style
    let grows: Bool
    let isLoading: Bool
    let action: () -> Void

    public init(_ title: String, style: Style = .neutral, grows: Bool = false, isLoading: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.grows = grows
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: {
            DS.Haptic.selection()
            action()
        }) {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: style == .neutral ? .regular : .bold))
                    .lineLimit(1)
                    .opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(foreground) }
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .frame(maxWidth: grows ? .infinity : nil)
            .frame(height: 44)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(background))
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .disabled(isLoading)
        .fixedSize(horizontal: !grows, vertical: false)
    }

    private var foreground: Color {
        switch style {
        case .filled: return DS.Color.onPrimary
        case .soft: return DS.Color.primaryText
        case .neutral: return DS.Color.text
        }
    }

    private var background: Color {
        switch style {
        case .filled: return DS.Color.primary
        case .soft: return DS.Color.primarySoft
        case .neutral: return DS.Color.cardHi
        }
    }
}
