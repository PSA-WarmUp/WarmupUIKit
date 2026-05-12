//
//  DSNotificationDot.swift
//  WarmupUIKit
//
//  Relative-positioned notification dot. Survives Dynamic Type scaling.
//

import SwiftUI

public extension View {
    /// Overlays a small dot in the top-right when `count > 0`.
    /// Pass `count: nil` for an unread indicator without a number.
    func dsNotificationDot(count: Int? = nil, show: Bool = true) -> some View {
        self.overlay(alignment: .topTrailing) {
            if show, count.map({ $0 > 0 }) ?? true {
                Group {
                    if let count = count, count > 0 {
                        Text(count > 99 ? "99+" : "\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, count > 9 ? 4 : 0)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Capsule().fill(DS.Color.error))
                            .accessibilityLabel("\(count) unread")
                    } else {
                        Circle()
                            .fill(DS.Color.error)
                            .frame(width: 8, height: 8)
                            .accessibilityLabel("Unread")
                    }
                }
                .alignmentGuide(.top) { d in d[VerticalAlignment.center] }
                .alignmentGuide(.trailing) { d in d[HorizontalAlignment.center] + 2 }
            }
        }
    }
}
