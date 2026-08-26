//
//  TrainingResponseCard.swift
//  WarmupUIKit
//
//  The card a sensor company cannot draw.
//
//  Weekly training volume (ours) as bars, with the body's recovery signal (theirs) as a line over
//  the top — one axis, so the eye does the correlation without being told to. Where the line dips
//  as the bars climb, the body is falling behind the training, which is the entire reason a coach
//  exists.
//
//  Colour carries provenance throughout: coral is what you did, blue is what your body said
//  about it.
//

import SwiftUI

public struct TrainingResponseCard: View {
    /// Weekly totals, oldest first. Volume when it's been logged, else session count.
    let weeklyLoad: [Double]
    /// Recovery signal over the same weeks, oldest first. Usually HRV.
    let weeklyRecovery: [Double]
    let recoveryLabel: String
    let loadLabel: String
    /// Nil when there's no health data — the card still works, it just says less.
    let hasHealthData: Bool
    /// Whose training and recovery this is. Defaults to the reader's own.
    public let subject: HealthSubject

    public init(weeklyLoad: [Double], weeklyRecovery: [Double], recoveryLabel: String,
                loadLabel: String, hasHealthData: Bool, subject: HealthSubject = .you) {
        self.weeklyLoad = weeklyLoad
        self.weeklyRecovery = weeklyRecovery
        self.recoveryLabel = recoveryLabel
        self.loadLabel = loadLabel
        self.hasHealthData = hasHealthData
        self.subject = subject
    }

    private var loadTrendPercent: Int? {
        guard weeklyLoad.count >= 2 else { return nil }
        let recent = weeklyLoad.suffix(2)
        guard let previous = recent.first, let latest = recent.last, previous > 0 else { return nil }
        return Int(((latest - previous) / previous * 100).rounded())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.sm) {
            Text(headline)
                .font(DynamicTheme.Typography.headline)
                .foregroundColor(DynamicTheme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)

            chart

            HStack(spacing: DynamicTheme.Spacing.md) {
                legendItem(color: HealthPalette.load, label: loadLabel)
                if hasHealthData {
                    legendItem(color: HealthPalette.body, label: recoveryLabel)
                }
                Spacer()
            }

            if !hasHealthData {
                // Coral half keeps working at full strength; only the join is missing.
                Text(subject.isSelf
                    ? "Connect a health source to see whether your body is keeping pace."
                    : "\(subject.nominative) hasn't connected a health source, so there's no recovery signal to read against this load.")
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium))
    }

    /// States the relationship in words, because the whole point is the pairing.
    private var headline: String {
        guard let trend = loadTrendPercent else {
            return "Not enough weeks yet to show a trend."
        }
        let direction = trend > 0 ? "up" : (trend < 0 ? "down" : "level")
        let magnitude = abs(trend)

        guard hasHealthData, weeklyRecovery.count >= 2,
              let previousRecovery = weeklyRecovery.dropLast().last,
              let latestRecovery = weeklyRecovery.last, previousRecovery > 0 else {
            return trend == 0 ? "Load is holding steady." : "Load is \(direction) \(magnitude)%."
        }

        let recoveryHolding = latestRecovery >= previousRecovery * 0.95
        if trend > 0 {
            return recoveryHolding
                ? "Load is up \(magnitude)% and your body is keeping pace."
                : "Load is up \(magnitude)% and your recovery is slipping."
        }
        if trend < 0 {
            return recoveryHolding
                ? "Load eased \(magnitude)% and recovery held."
                : "Load eased \(magnitude)%, and recovery is still catching up."
        }
        return recoveryHolding ? "Load is steady and so is recovery." : "Load is steady but recovery is slipping."
    }

    private var chart: some View {
        GeometryReader { geo in
            let maxLoad = max(weeklyLoad.max() ?? 1, 1)
            let barSpan = weeklyLoad.isEmpty ? geo.size.width : geo.size.width / CGFloat(weeklyLoad.count)
            let barWidth = max(6, barSpan * 0.62)

            ZStack(alignment: .bottomLeading) {
                // Load — ours.
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(weeklyLoad.enumerated()), id: \.offset) { _, value in
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(HealthPalette.load.opacity(0.62))
                                .frame(width: barWidth,
                                       height: max(3, geo.size.height * 0.72 * (value / maxLoad)))
                        }
                        .frame(width: barSpan)
                    }
                }

                // Recovery — theirs. Drawn over the top, on the same axis.
                if hasHealthData, weeklyRecovery.count >= 2 {
                    recoveryLine(in: geo.size, barSpan: barSpan)
                }
            }
        }
        .frame(height: 96)
    }

    private func recoveryLine(in size: CGSize, barSpan: CGFloat) -> some View {
        let maxR = weeklyRecovery.max() ?? 1
        let minR = weeklyRecovery.min() ?? 0
        let span = max(maxR - minR, 0.0001)

        return Path { path in
            for (index, value) in weeklyRecovery.enumerated() {
                let x = barSpan * (CGFloat(index) + 0.5)
                // Confined to the upper third so it reads as an overlay, not a second bar chart.
                let normalized = (value - minR) / span
                let y = size.height * 0.30 - (normalized * size.height * 0.22)
                let point = CGPoint(x: x, y: y)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
        .stroke(HealthPalette.body, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 9, height: 9)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
    }
}
