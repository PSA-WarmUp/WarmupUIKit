//
//  DSPill.swift
//  WarmupUIKit
//
//  Status pill — primarySoft fill + primary text, with gray variant.
//

import SwiftUI

public struct DSPill: View {
    let label: String
    var style: Style

    public enum Style {
        case primary
        case success
        case gray
    }

    public init(_ label: String, style: Style = .primary) {
        self.label = label
        self.style = style
    }

    public var body: some View {
        Text(label.uppercased())
            .font(DS.Typo.eyebrow)
            .tracking(0.3)
            .foregroundStyle(foreground)
            // A pill is a label, not a paragraph. Without these the text wrapped inside its own
            // capsule when the row got tight, breaking mid-word into "SUPERSE / T A" and
            // "STRENGT / H". Sizing to content and refusing to wrap makes the pill hold its
            // shape and pushes the pressure onto the flexible text beside it, which is the
            // element that can truncate gracefully.
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(background)
            )
    }

    private var foreground: Color {
        switch style {
        case .primary: return DS.Color.primary
        case .success: return DS.Color.success
        case .gray:    return DS.Color.textSec
        }
    }

    private var background: Color {
        switch style {
        case .primary: return DS.Color.primarySoft
        case .success: return DS.Color.successSoft
        case .gray:    return DS.Color.hairline
        }
    }
}
