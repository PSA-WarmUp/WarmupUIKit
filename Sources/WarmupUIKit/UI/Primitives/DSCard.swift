//
//  DSCard.swift
//  WarmupUIKit
//
//  Rounded-rect container with card background, 16pt radius, no shadow.
//

import SwiftUI

public struct DSCard<Content: View>: View {
    let highlighted: Bool
    @ViewBuilder let content: () -> Content

    public init(highlighted: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.highlighted = highlighted
        self.content = content
    }

    public var body: some View {
        content()
            .padding(DS.Space.cardPad)
            .background(
                RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                    .fill(highlighted ? DS.Color.cardHi : DS.Color.card)
            )
    }
}
