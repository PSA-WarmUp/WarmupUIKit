//
//  DSHairline.swift
//  WarmupUIKit
//
//  0.5pt divider at hairline color.
//

import SwiftUI

public struct DSHairline: View {
    var strong: Bool

    public init(strong: Bool = false) {
        self.strong = strong
    }

    public var body: some View {
        Rectangle()
            .fill(strong ? DS.Color.hairlineStrong : DS.Color.hairline)
            .frame(height: DS.Space.hairlineWidth)
    }
}
