//
//  MetricBaseline.swift
//  WarmupUIKit
//
//  "Your normal" — the band every metric is drawn against.
//
//  We have no goals stored anywhere, and inventing one (10,000 steps) would be borrowing someone
//  else's target and calling it yours. What we do have is the person's own recent history, which
//  is the better reference for a coached app: "68 bpm" says nothing, "68 — six below your normal"
//  is something a client and a coach can both act on.
//

import Foundation

public struct MetricBaseline {
    /// Low edge of "normal" — the 10th percentile of the window.
    public let low: Double
    /// High edge — the 90th.
    public let high: Double
    public let median: Double
    /// How many readings the band was built from. Below `minimumSamples` it isn't shown at all.
    public let sampleCount: Int

    public init(low: Double, high: Double, median: Double, sampleCount: Int) {
        self.low = low
        self.high = high
        self.median = median
        self.sampleCount = sampleCount
    }

    /// Percentiles rather than min/max on purpose: one outlier night would otherwise widen
    /// "normal" so far that nothing ever reads as unusual again.
    public static let lowPercentile = 0.10
    public static let highPercentile = 0.90

    /// Fewer readings than this and a band would be describing noise as a habit.
    public static let minimumSamples = 8

    public static func from(_ values: [Double]) -> MetricBaseline? {
        let sorted = values.sorted()
        guard sorted.count >= minimumSamples else { return nil }
        return MetricBaseline(
            low: percentile(sorted, lowPercentile),
            high: percentile(sorted, highPercentile),
            median: percentile(sorted, 0.5),
            sampleCount: sorted.count
        )
    }

    private static func percentile(_ sorted: [Double], _ p: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let position = p * Double(sorted.count - 1)
        let lower = Int(position.rounded(.down))
        let upper = min(lower + 1, sorted.count - 1)
        let weight = position - Double(lower)
        return sorted[lower] * (1 - weight) + sorted[upper] * weight
    }

    /// Where a reading sits, 0…1 across the band, clamped so a marker never leaves the track.
    func position(of value: Double) -> Double {
        guard high > low else { return 0.5 }
        return min(1, max(0, (value - low) / (high - low)))
    }

    func standing(of value: Double) -> Standing {
        if value < low { return .below }
        if value > high { return .above }
        return .normal
    }

    public enum Standing { case below, normal, above }
}
