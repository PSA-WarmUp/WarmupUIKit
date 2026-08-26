//
//  EffortRecoveryCard.swift
//  WarmupUIKit
//
//  Effort, against what it cost.
//
//  RPE alone is a number a client typed. Sleep alone is a number a watch recorded. Put the night
//  BEHIND the session it preceded and the pair says something neither does alone.
//
//  Both families on one card: coral is the session, blue is the night before it.
//

import SwiftUI

public struct EffortRecoveryCard: View {
    public struct Session: Identifiable {
        let date: Date
        let rpe: Double
        /// Hours slept the night before this session. Nil when we have no reading for it.
        let sleepBefore: Double?
        public var id: Date { date }

        public init(date: Date, rpe: Double, sleepBefore: Double?) {
            self.date = date
            self.rpe = rpe
            self.sleepBefore = sleepBefore
        }
    }

    let sessions: [Session]          // oldest first
    let averageRpe: Double?
    let prescribedRpe: Double?
    let personalRecords: Int

    public init(sessions: [Session], averageRpe: Double?, prescribedRpe: Double?,
                personalRecords: Int) {
        self.sessions = sessions
        self.averageRpe = averageRpe
        self.prescribedRpe = prescribedRpe
        self.personalRecords = personalRecords
    }

    private var hasSleep: Bool { sessions.contains { $0.sleepBefore != nil } }

    /// Descriptive, never causal. Two hard sessions after two short nights is an observation
    /// worth surfacing and not a claim that one caused the other.
    private var observation: String? {
        let withSleep = sessions.compactMap { s -> (Double, Double)? in
            guard let sleep = s.sleepBefore else { return nil }
            return (s.rpe, sleep)
        }
        guard withSleep.count >= 4 else { return nil }
        let medianSleep = withSleep.map(\.1).sorted()[withSleep.count / 2]
        let hardest = withSleep.sorted { $0.0 > $1.0 }.prefix(2)
        guard hardest.allSatisfy({ $0.1 < medianSleep }) else { return nil }
        return "Your two hardest sessions both followed shorter-than-usual nights."
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.md) {
            Text("How well · effort vs recovery")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            chart

            HStack(spacing: DynamicTheme.Spacing.md) {
                swatch(HealthPalette.load, "Session RPE")
                if hasSleep { swatch(HealthPalette.body.opacity(0.5), "Sleep, night before") }
                Spacer()
            }

            HStack(spacing: 0) {
                stat(averageRpe.map { String(format: "%.1f", $0) } ?? "—", "AVG RPE")
                stat(prescribedRpe.map { String(format: "%.1f", $0) } ?? "—", "PRESCRIBED")
                stat("\(personalRecords)", personalRecords == 1 ? "PR" : "PRs")
            }
            .padding(.top, 2)

            if let observation {
                Text(observation)
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium))
    }

    private var chart: some View {
        GeometryReader { geo in
            let span = sessions.isEmpty ? geo.size.width : geo.size.width / CGFloat(sessions.count)
            let maxSleep = max(sessions.compactMap(\.sleepBefore).max() ?? 8, 1)

            ZStack(alignment: .bottomLeading) {
                // Sleep the night before — behind, because it's the context not the subject.
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(sessions) { session in
                        VStack {
                            Spacer(minLength: 0)
                            if let sleep = session.sleepBefore {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(HealthPalette.body.opacity(0.22))
                                    .frame(width: max(6, span * 0.62),
                                           height: max(4, geo.size.height * 0.8 * (sleep / maxSleep)))
                            } else {
                                Color.clear.frame(width: max(6, span * 0.62), height: 1)
                            }
                        }
                        .frame(width: span)
                    }
                }

                // RPE — in front.
                if sessions.count >= 2 {
                    Path { path in
                        for (index, session) in sessions.enumerated() {
                            let x = span * (CGFloat(index) + 0.5)
                            // RPE is 1…10, pinned to the upper half so it never collides with bars.
                            let y = geo.size.height * 0.55 - (CGFloat(session.rpe) / 10 * geo.size.height * 0.45)
                            let point = CGPoint(x: x, y: y)
                            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
                        }
                    }
                    .stroke(HealthPalette.load,
                            style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                }
            }
        }
        .frame(height: 96)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DynamicTheme.Colors.text)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func swatch(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 9, height: 9)
            Text(label).font(.system(size: 10)).foregroundColor(DynamicTheme.Colors.textTertiary)
        }
    }
}
