//
//  DSFigureTile.swift
//  WarmupUIKit
//
//  A number over its label on a card — the tiles in a trust bar or a stats row:
//
//    ┌──────────┐ ┌──────────┐ ┌──────────┐
//    │ 4.9      │ │ 9 yrs    │ │ 140      │
//    │ 82 reviews│ │ Coaching │ │ Coached  │
//    └──────────┘ └──────────┘ └──────────┘
//
//  22pt semibold mono value, 13pt secondary label, 16pt-radius card. Lay several out in an
//  equal-width HStack / grid.
//

import SwiftUI

public struct DSFigureTile: View {
    let value: String
    let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(DS.Color.text)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(DS.Color.textSec)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous).fill(DS.Color.card))
        .accessibilityElement(children: .combine)
    }
}
