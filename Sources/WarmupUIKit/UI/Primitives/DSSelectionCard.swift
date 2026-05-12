//
//  DSSelectionCard.swift
//  WarmupUIKit
//
//  Selection card primitive. One selected state, one unselected state.
//

import SwiftUI

public struct DSSelectionCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button {
            DS.Haptic.selection()
            action()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? DS.Tone.accent.opacity(0.15) : DS.Color.cardHi)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .dsIcon(DS.Icon.md, weight: .medium)
                        .foregroundColor(isSelected ? DS.Tone.accent : DS.Color.textSec)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .dsHeadline()
                        .foregroundColor(DS.Color.text)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .dsCallout()
                            .foregroundColor(DS.Color.textSec)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .dsIcon(DS.Icon.lg, weight: .semibold)
                        .foregroundColor(DS.Tone.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(DS.Space.cardPad)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .fill(isSelected ? DS.Tone.accent.opacity(0.06) : DS.Color.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .stroke(isSelected ? DS.Tone.accent : DS.Color.hairline,
                            lineWidth: isSelected ? 1.5 : DS.Space.hairlineWidth)
            )
            .animation(DS.Motion.tap, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)\(subtitle.map { ". \($0)" } ?? "")")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(.isButton)
    }
}
