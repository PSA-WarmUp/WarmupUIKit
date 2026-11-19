//
//  DSCheckCircle.swift
//  WarmupUIKit
//
//  The 24pt tick on a row that can be picked: coral disc with a check when on, an empty ring
//  when off. Used wherever a list turns into a multi-select (Library › Movements, Copy to…).
//
//      DSCheckCircle(isOn: selection.contains(id))
//
//  Decorative: the row carrying it should expose the state (`.accessibilityAddTraits(.isSelected)`).
//

import SwiftUI

public struct DSCheckCircle: View {
    let isOn: Bool

    public init(isOn: Bool) {
        self.isOn = isOn
    }

    /// The off ring: #AEAEB2 light / #48484E dark (Foundations "ring").
    static let ring = SwiftUI.Color.dynamicColor(
        light: SwiftUI.Color(hex: "#AEAEB2"),
        dark: SwiftUI.Color(hex: "#48484E")
    )

    public var body: some View {
        ZStack {
            if isOn {
                Circle().fill(DS.Color.primary)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DS.Color.onPrimary)
            } else {
                Circle().strokeBorder(Self.ring, lineWidth: 2)
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        DSCheckCircle(isOn: true)
        DSCheckCircle(isOn: false)
    }
    .padding()
    .background(DS.Color.bg)
}
