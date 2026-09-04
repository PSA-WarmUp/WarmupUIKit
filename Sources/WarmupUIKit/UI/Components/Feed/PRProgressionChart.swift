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
        VStack(alignment: .leading, spacing: DS.Space.v8) {
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
            .font(DS.Typo.captionMedium)
            .foregroundColor(DS.Color.textTer)

            // Bar chart
            if let dataPoints = progression.dataPoints, !dataPoints.isEmpty {
                barChart(dataPoints: dataPoints)
            }

            // Footer: improvement label
            HStack {
                Spacer()
                if let label = progression.improvementLabel {
                    Text(label)
                        .font(DS.Typo.caption)
                        .foregroundColor(DS.Color.textSec)
                }
            }
        }
        .padding(.horizontal, DS.Space.cardPad)
        .padding(.vertical, DS.Space.v8)
    }

    private func barChart(dataPoints: [PRDataPoint]) -> some View {
        let maxValue = dataPoints.map(\.value).max() ?? 1

        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(dataPoints) { point in
                VStack(spacing: 2) {
                    if point.isPR == true {
                        Text("\(Int(point.value))")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .monospacedDigit()
                            .foregroundColor(DS.Color.primary)
                    }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(point.isPR == true
                              ? DS.Color.primary
                              : DS.Color.textTer.opacity(0.25))
                        .frame(height: max(4, CGFloat(point.value / maxValue) * 80))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 100)
    }
}
