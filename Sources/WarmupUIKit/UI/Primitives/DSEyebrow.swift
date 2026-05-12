//
//  DSEyebrow.swift
//  WarmupUIKit
//
//  11pt semibold uppercase text with +0.5 tracking.
//

import SwiftUI

public struct DSEyebrow: View {
    let text: String
    var color: Color

    public init(_ text: String, color: Color = DS.Color.textSec) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text.uppercased())
            .font(DS.Typo.eyebrow)
            .tracking(0.5)
            .foregroundStyle(color)
    }
}
