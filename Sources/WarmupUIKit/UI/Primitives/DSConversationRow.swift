//
//  DSConversationRow.swift
//  WarmupUIKit
//
//  One conversation in a Messages list, the same in both apps:
//
//    (avatar)  Maya Chen  🔕                    9:41
//              You: See you Thursday            ●
//
//  Name 16pt (bold when unread), mono time, one-line preview (primary text when unread),
//  a coral dot for unread, a bell-slash when muted. 68pt tall, padded for a DSRowGroup.
//  Value-based so each app can feed it from its own conversation model; the avatar is a
//  view so a group can show its stacked avatar. Plain content — the enclosing
//  NavigationLink / Button owns the tap.
//

import SwiftUI

public struct DSConversationRow<Avatar: View>: View {
    let name: String
    let time: String
    let preview: String
    let isUnread: Bool
    let isMuted: Bool
    let isPinned: Bool
    let avatar: Avatar

    public init(name: String,
                time: String,
                preview: String,
                isUnread: Bool,
                isMuted: Bool = false,
                isPinned: Bool = false,
                @ViewBuilder avatar: () -> Avatar) {
        self.name = name
        self.time = time
        self.preview = preview
        self.isUnread = isUnread
        self.isMuted = isMuted
        self.isPinned = isPinned
        self.avatar = avatar()
    }

    public var body: some View {
        HStack(spacing: 12) {
            avatar
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(name)
                        .font(.system(size: 16, weight: isUnread ? .bold : .semibold))
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(1)
                    if isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(DS.Color.textTer)
                            .accessibilityLabel("Muted")
                    }
                    Spacer(minLength: 4)
                    Text(time)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(DS.Color.textSec)
                        .lineLimit(1)
                }
                if !preview.isEmpty {
                    Text(preview)
                        .font(.system(size: 14))
                        .foregroundStyle(isUnread ? DS.Color.text : DS.Color.textSec)
                        .lineLimit(1)
                }
            }
            if isUnread {
                Circle()
                    .fill(DS.Color.primary)
                    .frame(width: 10, height: 10)
                    .accessibilityLabel("Unread")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: 68)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(isPinned ? "Pinned" : "")
    }
}

public extension DSConversationRow where Avatar == DSAvatar {
    /// A one-to-one conversation: photo or initials.
    init(name: String, imageURL: String?, time: String, preview: String,
         isUnread: Bool, isMuted: Bool = false, isPinned: Bool = false) {
        self.init(name: name, time: time, preview: preview, isUnread: isUnread,
                  isMuted: isMuted, isPinned: isPinned) {
            DSAvatar(name, url: imageURL, size: 44)
        }
    }
}

/// The preview line for a conversation row: "You: …" for your own last message, "Maya: …" for
/// someone else's in a group, the bare text otherwise.
public enum DSConversationPreview {
    public static func text(_ content: String?, senderId: String?, senderName: String?,
                            currentUserId: String?, isGroup: Bool) -> String {
        let text = content ?? ""
        guard !text.isEmpty else { return "" }
        if let senderId, senderId == currentUserId { return "You: \(text)" }
        if isGroup, let first = senderName?.split(separator: " ").first, !first.isEmpty {
            return "\(first): \(text)"
        }
        return text
    }
}
