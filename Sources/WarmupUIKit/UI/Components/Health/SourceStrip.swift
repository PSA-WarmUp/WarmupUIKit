//
//  SourceStrip.swift
//  WarmupUIKit
//
//  Says on screen that this tab reads two sources together — and earns its place by carrying the
//  one fact nothing else shows: how current each of them is.
//
//  Not a badge. A badge that only decorates gets ignored within a week. The health half reports
//  the newest READING (not our upload time, which is what the old line reported), and the WarmUp
//  half reports sessions this week, so a client with an empty coral half can see why.
//
//  The border colours are the same two families the charts use, so the strip doubles as the key.
//

import SwiftUI

public struct SourceStrip: View {
    /// Newest connected-health reading, nil when nothing has ever synced.
    public let newestReading: Date?
    /// Device that produced it — "Apple Watch", "Oura", "Whoop". Never hardcoded.
    public let deviceName: String?
    public let isHealthAuthorized: Bool
    public let sessionsThisWeek: Int

    public init(newestReading: Date?, deviceName: String?, isHealthAuthorized: Bool,
                sessionsThisWeek: Int) {
        self.newestReading = newestReading
        self.deviceName = deviceName
        self.isHealthAuthorized = isHealthAuthorized
        self.sessionsThisWeek = sessionsThisWeek
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            half(
                accent: HealthPalette.body,
                title: "Health",
                detail: healthDetail,
                isHealthy: isHealthAuthorized && newestReading != nil,
                muted: !isHealthAuthorized
            )
            half(
                accent: HealthPalette.load,
                title: "WarmUp",
                detail: sessionsThisWeek == 1 ? "1 session this week"
                                              : "\(sessionsThisWeek) sessions this week",
                isHealthy: true,
                muted: false
            )
        }
    }

    /// Names the device rather than the vendor's app, so the label survives a Garmin or a Whoop.
    private var healthDetail: String {
        guard isHealthAuthorized else { return "Not connected" }
        guard let newestReading else { return "No readings yet" }
        let age = Self.relative.localizedString(for: newestReading, relativeTo: Date())
        if let deviceName, !deviceName.isEmpty {
            return "\(deviceName) · \(age)"
        }
        return age
    }

    private func half(accent: Color, title: String, detail: String,
                      isHealthy: Bool, muted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Circle()
                    .fill(isHealthy ? DynamicTheme.Colors.success : DynamicTheme.Colors.warning)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }
            Text(detail)
                .font(.system(size: 11))
                .foregroundColor(muted ? DynamicTheme.Colors.warning : DynamicTheme.Colors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DynamicTheme.Spacing.sm)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .fill(DynamicTheme.Colors.cardBackground)
        )
        .overlay(alignment: .leading) {
            // The accent edge is the legend: coral is ours, blue is theirs.
            RoundedRectangle(cornerRadius: 1)
                .fill(muted ? DynamicTheme.Colors.divider : accent)
                .frame(width: 2)
                .padding(.vertical, 8)
        }
    }

    private static let relative: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
}
