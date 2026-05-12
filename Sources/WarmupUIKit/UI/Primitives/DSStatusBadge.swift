//
//  DSStatusBadge.swift
//  WarmupUIKit
//

import SwiftUI

public enum DSStatus {
    case scheduled
    case pending
    case accepted
    case completed
    case declined
    case cancelled
    case info
    case neutral
    case custom(label: String, color: Color)

    var label: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .pending:   return "Pending"
        case .accepted:  return "Accepted"
        case .completed: return "Completed"
        case .declined:  return "Declined"
        case .cancelled: return "Cancelled"
        case .info:      return "Info"
        case .neutral:   return "—"
        case .custom(let l, _): return l
        }
    }

    var color: Color {
        switch self {
        case .scheduled, .info:  return DS.Color.info
        case .pending:           return DS.Color.warning
        case .accepted, .completed: return DS.Color.success
        case .declined, .cancelled: return DS.Color.error
        case .neutral:           return DS.Color.textSec
        case .custom(_, let c):  return c
        }
    }

    var softFill: Color {
        switch self {
        case .scheduled, .info:  return DS.Color.infoSoft
        case .pending:           return DS.Color.warningSoft
        case .accepted, .completed: return DS.Color.successSoft
        case .declined, .cancelled: return DS.Color.errorSoft
        case .neutral:           return DS.Color.card
        case .custom(_, let c):  return c.opacity(0.12)
        }
    }

    var icon: String? {
        switch self {
        case .scheduled: return "calendar"
        case .pending:   return "clock"
        case .accepted:  return "checkmark"
        case .completed: return "checkmark.circle.fill"
        case .declined:  return "xmark"
        case .cancelled: return "xmark.circle.fill"
        case .info:      return "info.circle"
        case .neutral:   return nil
        case .custom:    return nil
        }
    }
}

public struct DSStatusBadge: View {
    let status: DSStatus
    let size: Size
    let showIcon: Bool

    public enum Size { case sm, md }

    public init(_ status: DSStatus, size: Size = .sm, showIcon: Bool = true) {
        self.status = status
        self.size = size
        self.showIcon = showIcon
    }

    public var body: some View {
        HStack(spacing: 4) {
            if showIcon, let icon = status.icon {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
            }
            Text(status.label)
                .font(.system(size: textSize, weight: .semibold))
        }
        .foregroundColor(status.color)
        .padding(.horizontal, hPad)
        .padding(.vertical, vPad)
        .background(
            Capsule().fill(status.softFill)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status: \(status.label)")
    }

    private var iconSize: CGFloat { size == .sm ? 9 : 11 }
    private var textSize: CGFloat { size == .sm ? 11 : 12 }
    private var hPad: CGFloat { size == .sm ? 8 : 10 }
    private var vPad: CGFloat { size == .sm ? 4 : 5 }
}
