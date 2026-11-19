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
    /// A time the trainer suggested and the client hasn't confirmed (amber: waiting)
    case proposed
    /// Built but not scheduled or sent (neutral)
    case draft
    /// Finished (green)
    case done
    /// Both sides agreed (green)
    case confirmed
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
        case .proposed:  return "Proposed"
        case .draft:     return "Draft"
        case .done:      return "Done"
        case .confirmed: return "Confirmed"
        case .custom(let l, _): return l
        }
    }

    var color: Color {
        switch self {
        case .scheduled, .info:  return DS.Color.info
        case .pending, .proposed: return DS.Color.warning
        case .accepted, .completed, .done, .confirmed: return DS.Color.success
        case .declined, .cancelled: return DS.Color.error
        case .neutral, .draft:   return DS.Color.textSec
        case .custom(_, let c):  return c
        }
    }

    var softFill: Color {
        switch self {
        case .scheduled, .info:  return DS.Color.infoSoft
        case .pending, .proposed: return DS.Color.warningSoft
        case .accepted, .completed, .done, .confirmed: return DS.Color.successSoft
        case .declined, .cancelled: return DS.Color.errorSoft
        case .neutral, .draft:   return DS.Color.cardHi
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
        case .neutral, .proposed, .draft, .done, .confirmed: return nil
        case .custom:    return nil
        }
    }
}

public struct DSStatusBadge: View {
    let status: DSStatus
    let size: Size
    let showIcon: Bool

    public enum Size { case sm, md }

    /// Status tag: 13pt semibold on a soft fill, 6pt corners, no icon by default — the word
    /// and its color carry the status. Same tag on every screen that shows a session.
    public init(_ status: DSStatus, size: Size = .sm, showIcon: Bool = false) {
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
            RoundedRectangle(cornerRadius: 6, style: .continuous).fill(status.softFill)
        )
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status: \(status.label)")
    }

    private var iconSize: CGFloat { size == .sm ? 11 : 13 }
    private var textSize: CGFloat { size == .sm ? 13 : 15 }
    private var hPad: CGFloat { size == .sm ? 8 : 10 }
    private var vPad: CGFloat { size == .sm ? 4 : 5 }
}
