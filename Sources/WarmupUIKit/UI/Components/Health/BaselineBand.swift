//
//  BaselineBand.swift
//  WarmupUIKit
//
//  The device the whole health tab is built from.
//
//  A shaded run showing where this person normally sits, with a mark for the current reading. It
//  means the same thing at every size and on every metric, which is what lets a number like
//  "69 bpm" carry a verdict without a paragraph of explanation.
//

import SwiftUI

public struct BaselineBand: View {
    public let baseline: MetricBaseline
    public let value: Double
    public let direction: MetricDirection

    public init(baseline: MetricBaseline, value: Double, direction: MetricDirection) {
        self.baseline = baseline
        self.value = value
        self.direction = direction
    }

    private var standing: MetricBaseline.Standing { baseline.standing(of: value) }

    /// Where the marker sits across the whole track, with the band occupying the middle 60%.
    ///
    /// The band is drawn inset rather than edge-to-edge so a reading outside it still has
    /// somewhere to go — a marker pinned to the very end reads as broken.
    private var markerFraction: Double {
        let inset = 0.2
        return inset + baseline.position(of: value) * (1 - inset * 2)
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(HealthPalette.bandTrack)
                    .frame(height: 7)

                Capsule()
                    .fill(HealthPalette.bandFill)
                    .frame(width: geo.size.width * 0.6, height: 7)
                    .offset(x: geo.size.width * 0.2)

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(direction.tint(for: standing))
                    .frame(width: 3, height: 17)
                    .offset(x: max(0, min(geo.size.width - 3, geo.size.width * markerFraction - 1.5)))
            }
            .frame(height: 17)
        }
        .frame(height: 17)
        .accessibilityLabel(Text(accessibilityDescription))
    }

    private var accessibilityDescription: String {
        "\(Int(value.rounded())), \(direction.phrase(for: standing))"
    }
}
