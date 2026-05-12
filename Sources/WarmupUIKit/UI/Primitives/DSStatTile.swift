//
//  DSStatTile.swift
//  WarmupUIKit
//
//  Eyebrow label + large number + optional subtitle.
//

import SwiftUI

public struct DSStatTile: View {
    let eyebrow: String
    let value: String
    var subtitle: String?

    public init(eyebrow: String, value: String, subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.value = value
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.v4) {
            DSEyebrow(eyebrow)

            Text(value)
                .font(DS.Typo.statMedium)
                .foregroundStyle(DS.Color.text)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DS.Typo.caption)
                    .foregroundStyle(DS.Color.textSec)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
