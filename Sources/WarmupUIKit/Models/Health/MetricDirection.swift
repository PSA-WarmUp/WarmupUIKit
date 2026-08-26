//
//  MetricDirection.swift
//  WarmupUIKit
//
//  Which way is "good" for each metric.
//
//  A universal "up is green" would be actively wrong on half of these: rising resting heart rate
//  is a warning, rising HRV is a win. Colour has to follow meaning, not the sign of the delta.
//

import SwiftUI

public enum MetricDirection {
    /// Higher is better — HRV, SpO₂, steps, VO₂ max.
    case higherIsBetter
    /// Lower is better — resting heart rate.
    case lowerIsBetter
    /// Neither, on its own — sleep is only "good" against a personal target.
    case neutral

    // `forType(_:)` deliberately does NOT live here. Mapping a metric to a direction means
    // knowing a particular provider's taxonomy — HealthKit's today, someone else's tomorrow —
    // and the package should not. Each app maps its own types onto these three cases.

    /// The colour a reading gets, given where it sits against the person's own band.
    ///
    /// `HealthPalette.body` (blue) means the direction is favourable, `HealthPalette.load` (coral)
    /// means it warrants attention — the same two families used everywhere else on the screen.
    func tint(for standing: MetricBaseline.Standing) -> Color {
        switch (self, standing) {
        case (_, .normal):                  return HealthPalette.neutralInk
        case (.higherIsBetter, .above):     return HealthPalette.body
        case (.higherIsBetter, .below):     return HealthPalette.load
        case (.lowerIsBetter, .above):      return HealthPalette.load
        case (.lowerIsBetter, .below):      return HealthPalette.body
        case (.neutral, _):                 return HealthPalette.neutralInk
        }
    }

    /// Plain words, because "▲ 4" doesn't say whether that's good.
    func phrase(for standing: MetricBaseline.Standing) -> String {
        switch standing {
        case .normal: return "typical for you"
        case .above:  return self == .lowerIsBetter ? "above your normal" : "above your normal"
        case .below:  return "below your normal"
        }
    }
}
