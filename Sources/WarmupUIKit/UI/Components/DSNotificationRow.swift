//
//  DSNotificationRow.swift
//  WarmupUIKit
//
//  One notification, the same in both apps:
//
//    (icon)  Workout proposed                      2h
//            Maya proposed Upper pull for you.      ●
//            Thu, Nov 19 · 5:00 PM
//
//  Icon on a tone (done = green, waiting = amber, people/messages = blue, else neutral),
//  title 16pt (bold while unread), message 15pt secondary, the local date when the payload
//  carries one, mono relative time, a coral dot while unread. Padded for a DSRowGroup.
//  Plain content — wrap it in a Button for the tap.
//

import SwiftUI

public struct DSNotificationRow: View {
    let notification: AppNotification

    public init(_ notification: AppNotification) {
        self.notification = notification
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(tone.bg)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(tone.fg)
            }
            .frame(width: 40, height: 40)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .semibold : .bold))
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(2)
                    Spacer(minLength: 4)
                    if !timeAgo.isEmpty {
                        Text(timeAgo)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(DS.Color.textSec)
                            .lineLimit(1)
                    }
                }
                if !notification.message.isEmpty {
                    Text(notification.message)
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Color.textSec)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // The message carries no date — the server can't know the reader's timezone —
                // so the local date is rendered here when the payload has one.
                if let scheduledAt = WarmupDate.localDateTime(fromIso: notification.data?.scheduledAtIso) {
                    Text(scheduledAt)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.Color.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !notification.isRead {
                Circle()
                    .fill(DS.Color.primary)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
                    .accessibilityLabel("Unread")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var tone: (bg: Color, fg: Color) {
        switch notification.type {
        case .workoutCompleted, .workoutAccepted, .scheduleAccepted, .programCompleted,
             .followAccepted, .consultationConfirmed, .milestone:
            return (DS.Color.successSoft, DS.Color.success)
        case .workoutProposal, .scheduleProposal, .workoutReminder, .workoutRescheduled, .consultationBooked,
             .consultationReminder24h, .consultationReminder1h, .consultationReminder15m,
             .consultationRescheduled, .quoteRequested, .reviewEligible:
            return (DS.Color.warningSoft, DS.Color.warning)
        case .newMessage, .followRequest, .newFollower, .postLiked, .postCommented,
             .postMentioned, .postShared:
            return (DS.Color.infoSoft, DS.Color.info)
        default:
            return (DS.Color.cardHi, DS.Color.textSec)
        }
    }

    private var timeAgo: String {
        guard let date = notification.createdAtDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
