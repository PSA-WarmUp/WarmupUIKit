//
//  TrainingMixCard.swift
//  WarmupUIKit
//
//  What you actually trained — against what the programme asked for.
//
//  A distribution chart on its own is a pie chart with extra steps. The ghost outline is the
//  proposal: dashed is prescribed, solid is done, and the gap between them is the only part
//  anyone acts on.
//
//  Entirely our own data, so the card is drawn in coral throughout and works with no health
//  source connected.
//

import SwiftUI

public struct TrainingMixCard: View {
    public struct Row: Identifiable {
        public let pattern: MovementPattern
        public let done: Int
        public let prescribed: Int

        public init(pattern: MovementPattern, done: Int, prescribed: Int) {
            self.pattern = pattern
            self.done = done
            self.prescribed = prescribed
        }
        public var id: String { pattern.rawValue }
    }


    public let rows: [Row]
    public let strengthShare: Double   // 0…1
    public let cardioShare: Double     // 0…1
    public let subject: HealthSubject

    public init(rows: [Row], strengthShare: Double, cardioShare: Double,
                subject: HealthSubject = .you) {
        self.rows = rows
        self.strengthShare = strengthShare
        self.cardioShare = cardioShare
        self.subject = subject
    }

    private var maxSets: Int {
        max(rows.map { max($0.done, $0.prescribed) }.max() ?? 1, 1)
    }

    /// The single most useful sentence the card can produce: the biggest gap, named.
    private var finding: String? {
        let missed = rows
            .filter { $0.prescribed > 0 && $0.done < $0.prescribed }
            .max(by: { ($0.prescribed - $0.done) < ($1.prescribed - $1.done) })
        guard let missed, missed.prescribed - missed.done >= 3 else { return nil }
        return "\(missed.pattern.label) is \(missed.prescribed - missed.done) sets behind what was programmed."
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.md) {
            Text("What \(subject.nominative) trained · 30 days")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            if strengthShare + cardioShare > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        HStack(spacing: 3) {
                            if strengthShare > 0 {
                                Capsule().fill(HealthPalette.load.opacity(0.75))
                                    .frame(width: max(4, geo.size.width * strengthShare - 2))
                            }
                            if cardioShare > 0 {
                                Capsule().fill(HealthPalette.load.opacity(0.32))
                                    .frame(width: max(4, geo.size.width * cardioShare - 2))
                            }
                        }
                    }
                    .frame(height: 12)

                    HStack(spacing: DynamicTheme.Spacing.md) {
                        swatch(HealthPalette.load.opacity(0.75), "Strength \(percent(strengthShare))")
                        swatch(HealthPalette.load.opacity(0.32), "Cardio \(percent(cardioShare))")
                        Spacer()
                    }
                }
            }

            VStack(spacing: 8) {
                ForEach(rows) { row in
                    regionRow(row)
                }
            }

            if let finding {
                Text(finding)
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("dashed = programmed")
                .font(.system(size: 9.5))
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium))
    }

    private func regionRow(_ row: Row) -> some View {
        HStack(spacing: 8) {
            Text(row.pattern.label)
                .font(.system(size: 10.5))
                .foregroundColor(DynamicTheme.Colors.textSecondary)
                .frame(width: 62, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Prescribed — the ghost.
                    if row.prescribed > 0 {
                        Capsule()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2.5, 2.5]))
                            .foregroundColor(DynamicTheme.Colors.divider)
                            .frame(width: geo.size.width * CGFloat(row.prescribed) / CGFloat(maxSets),
                                   height: 12)
                    }
                    // Done.
                    Capsule()
                        .fill(HealthPalette.load.opacity(row.pattern == .unknown ? 0.3 : 0.75))
                        .frame(width: max(2, geo.size.width * CGFloat(row.done) / CGFloat(maxSets)),
                               height: 12)
                }
                .frame(height: 12)
            }
            .frame(height: 12)

            Text("\(row.done)")
                .font(.system(size: 10))
                .foregroundColor(DynamicTheme.Colors.textTertiary)
                .monospacedDigit()
                .frame(width: 22, alignment: .trailing)
        }
    }

    private func swatch(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 9, height: 9)
            Text(label).font(.system(size: 10)).foregroundColor(DynamicTheme.Colors.textTertiary)
        }
    }

    private func percent(_ value: Double) -> String { "\(Int((value * 100).rounded()))%" }
}
