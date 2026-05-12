//
//  DSChip.swift
//  WarmupUIKit
//
//  Outline chip for suggestions / quick-replies.
//

import SwiftUI

public struct DSChip: View {
    let label: String
    var icon: String?
    var action: (() -> Void)?

    public init(_ label: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.label = label
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(label)
                    .font(DS.Typo.calloutMedium)
            }
            .foregroundStyle(DS.Color.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .stroke(DS.Color.hairlineStrong, lineWidth: DS.Space.hairlineWidth)
            )
        }
        .buttonStyle(.plain)
    }
}
