//
//  PRProgressionChart.swift
//  WarmupUIKit
//
//  Bar chart showing PR weight progression over time.
//  Used in feed cards when prProgression data is available.
//

import SwiftUI

public struct PRProgressionChart: View {
    public let progression: PRProgressionDto

    public init(progression: PRProgressionDto) {
        self.progression = progression
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Eyebrow: "DEADLIFT · 12 WEEKS"
            HStack(spacing: 4) {
                if let name = progression.exerciseName {
                    Text(name.uppercased())
                }
                if progression.exerciseName != nil && progression.durationLabel != nil {
                    Text("·")
                }
                if let duration = progression.durationLabel {
                    Text(duration.uppercased())
                }
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(DynamicTheme.Colors.textTertiary)

            // Bar chart
            if let dataPoints = progression.dataPoints, !dataPoints.isEmpty {
                barChart(dataPoints: dataPoints)
            }

            // Footer: improvement label
            HStack {
                Spacer()
                if let label = progression.improvementLabel {
                    Text(label)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.vertical, DynamicTheme.Spacing.sm)
    }

    private func barChart(dataPoints: [PRDataPoint]) -> some View {
        let maxValue = dataPoints.map(\.value).max() ?? 1

        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(dataPoints) { point in
                VStack(spacing: 2) {
                    // Value label on PR bar only
                    if point.isPR == true {
                        Text("\(Int(point.value))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(point.isPR == true
                              ? DynamicTheme.Colors.primary
                              : DynamicTheme.Colors.textTertiary.opacity(0.25))
                        .frame(height: max(4, CGFloat(point.value / maxValue) * 80))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 100)
    }
}
