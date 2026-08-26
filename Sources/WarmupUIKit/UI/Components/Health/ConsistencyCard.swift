//
//  ConsistencyCard.swift
//  WarmupUIKit
//
//  Consistency as a pattern, not a streak.
//
//  A streak counter tells you that you failed. It doesn't tell you WHEN, which is the only
//  version of that fact anyone can act on. Weekday down the side, weeks across: a row of hollow
//  cells in a grid of filled ones is a shape, so "Thursday isn't working" needs no reading.
//
//  Entirely our own data — coral throughout.
//

import SwiftUI

public struct ConsistencyCard: View {
    public struct Cell: Identifiable {
        public enum State { case trained, missed, rest }
        public let state: State
        public let id = UUID()

        public init(state: State) {
            self.state = state
        }
    }

    /// Seven rows (Mon…Sun), each with one cell per week, oldest week first.
    public let rows: [[Cell]]
    public let weekCount: Int

    public init(rows: [[Cell]], weekCount: Int) {
        self.rows = rows
        self.weekCount = weekCount
    }

    private static let dayInitials = ["M", "T", "W", "T", "F", "S", "S"]

    /// The weekday with the most misses, when it's bad enough to be worth naming.
    private var weakestDay: (day: String, missed: Int)? {
        let names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var worst: (String, Int)?
        for (index, row) in rows.enumerated() where index < names.count {
            let missed = row.filter { $0.state == .missed }.count
            if missed >= 3, missed > (worst?.1 ?? 0) { worst = (names[index], missed) }
        }
        return worst.map { (day: $0.0, missed: $0.1) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.md) {
            Text("How consistently · \(weekCount) weeks")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            VStack(spacing: 4) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack(spacing: 4) {
                        Text(index < Self.dayInitials.count ? Self.dayInitials[index] : "")
                            .font(.system(size: 9))
                            .foregroundColor(DynamicTheme.Colors.textTertiary)
                            .frame(width: 12, alignment: .leading)

                        ForEach(row) { cell in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(fill(for: cell.state))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(cell.state == .missed
                                                ? HealthPalette.load.opacity(0.55) : .clear,
                                                lineWidth: 1)
                                )
                                .frame(height: 11)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            if let weakestDay {
                Text("\(weakestDay.day) is where the plan breaks — \(weakestDay.missed) of \(weekCount) missed.")
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: DynamicTheme.Spacing.md) {
                swatch(HealthPalette.load.opacity(0.85), "Trained")
                swatch(.clear, "Missed", stroke: HealthPalette.load.opacity(0.55))
                swatch(DynamicTheme.Colors.divider.opacity(0.4), "Rest")
                Spacer()
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium))
    }

    private func fill(for state: Cell.State) -> Color {
        switch state {
        case .trained: return HealthPalette.load.opacity(0.85)
        case .missed:  return .clear
        case .rest:    return DynamicTheme.Colors.divider.opacity(0.4)
        }
    }

    private func swatch(_ color: Color, _ label: String, stroke: Color = .clear) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(stroke, lineWidth: 1))
                .frame(width: 9, height: 9)
            Text(label).font(.system(size: 10)).foregroundColor(DynamicTheme.Colors.textTertiary)
        }
    }
}
