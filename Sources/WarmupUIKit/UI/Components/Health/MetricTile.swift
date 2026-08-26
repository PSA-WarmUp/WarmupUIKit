//
//  MetricTile.swift
//  WarmupUIKit
//
//  A metric that answers "is that good" instead of leaving it to the reader.
//
//  The old tile showed a number and a label, so 21 steps rendered exactly like a healthy figure.
//  This one carries the reading's standing against the person's own band, in words, plus the age
//  of the reading when it isn't from today.
//

import SwiftUI

public struct MetricTile: View {
    public let title: String
    public let icon: String
    public let value: String
    public let unit: String?
    public let measuredAt: Date?
    public let baseline: MetricBaseline?
    public let rawValue: Double
    public let direction: MetricDirection
    /// Last 30 days, oldest first — drawn as a sparkline when there's enough to show a shape.
    public let series: [Double]
    public let subject: HealthSubject

    public init(title: String, icon: String, value: String, unit: String?, measuredAt: Date?,
                baseline: MetricBaseline?, rawValue: Double, direction: MetricDirection,
                series: [Double], subject: HealthSubject = .you) {
        self.title = title
        self.icon = icon
        self.value = value
        self.unit = unit
        self.measuredAt = measuredAt
        self.baseline = baseline
        self.rawValue = rawValue
        self.direction = direction
        self.series = series
        self.subject = subject
    }

    private var standing: MetricBaseline.Standing? {
        baseline.map { $0.standing(of: rawValue) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(HealthPalette.body)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(DynamicTheme.Typography.title3)
                    .foregroundColor(DynamicTheme.Colors.text)
                    .monospacedDigit()
                if let unit {
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                }
            }

            if let baseline, let standing {
                Text(direction.phrase(for: standing))
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(direction.tint(for: standing))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                BaselineBand(baseline: baseline, value: rawValue, direction: direction)
                    .padding(.top, 2)
            } else {
                // Honest about not knowing yet, rather than implying a verdict.
                Text("building \(subject.possessive) normal")
                    .font(.system(size: 10.5))
                    .foregroundColor(DynamicTheme.Colors.textTertiary)
            }

            if let age = Self.staleLabel(for: measuredAt) {
                Text(age)
                    .font(.system(size: 10))
                    .foregroundColor(DynamicTheme.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium))
    }

    /// Nil for a reading taken today — today's number needs no caveat.
    public static func staleLabel(for date: Date?) -> String? {
        guard let date, !Calendar.current.isDateInToday(date) else { return nil }
        if Calendar.current.isDateInYesterday(date) { return "yesterday" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days <= 1 ? "yesterday" : "\(days) days ago"
    }
}
