//
//  ConversationModel.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 9/28/25.
//

import Foundation

// MARK: - Conversation Models
public struct ConversationModel: Codable, Identifiable {
    public let id: String
    public let participantIds: [String]
    public let conversationType: ConversationType

    // Other participant info (for direct conversations)
    public let otherParticipantId: String?
    public let otherParticipantName: String?
    public let otherParticipantProfileImage: String?
    public let otherParticipantRole: String?

    // Last message info
    public let lastMessageId: String?
    public let lastMessageContent: String?
    public let lastMessageSenderId: String?
    public let lastMessageSenderName: String?
    public let lastMessageAt: String?

    // Current user's metadata
    public let lastReadAt: String?
    public let unreadCount: Int?
    public let isMuted: Bool?
    public let isArchived: Bool?
    public let isPinned: Bool?

    public let createdAt: String?
    public let updatedAt: String?

    // Additional fields for group conversations (future)
    public let title: String?
    public let description: String?
    public let avatarUrl: String?

    public init(
        id: String,
        participantIds: [String],
        conversationType: ConversationType,
        otherParticipantId: String? = nil,
        otherParticipantName: String? = nil,
        otherParticipantProfileImage: String? = nil,
        otherParticipantRole: String? = nil,
        lastMessageId: String? = nil,
        lastMessageContent: String? = nil,
        lastMessageSenderId: String? = nil,
        lastMessageSenderName: String? = nil,
        lastMessageAt: String? = nil,
        lastReadAt: String? = nil,
        unreadCount: Int? = nil,
        isMuted: Bool? = nil,
        isArchived: Bool? = nil,
        isPinned: Bool? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        title: String? = nil,
        description: String? = nil,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.participantIds = participantIds
        self.conversationType = conversationType
        self.otherParticipantId = otherParticipantId
        self.otherParticipantName = otherParticipantName
        self.otherParticipantProfileImage = otherParticipantProfileImage
        self.otherParticipantRole = otherParticipantRole
        self.lastMessageId = lastMessageId
        self.lastMessageContent = lastMessageContent
        self.lastMessageSenderId = lastMessageSenderId
        self.lastMessageSenderName = lastMessageSenderName
        self.lastMessageAt = lastMessageAt
        self.lastReadAt = lastReadAt
        self.unreadCount = unreadCount
        self.isMuted = isMuted
        self.isArchived = isArchived
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.description = description
        self.avatarUrl = avatarUrl
    }

    // Computed properties
    public var displayName: String {
        return otherParticipantName ?? title ?? "Unknown"
    }

    public var hasUnreadMessages: Bool {
        return (unreadCount ?? 0) > 0
    }

    public var lastMessageDate: Date? {
        guard let lastMessageAt = lastMessageAt else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastMessageAt)
    }

    public var lastMessageTimeString: String {
        guard let date = lastMessageDate else { return "" }

        let now = Date()
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return "Yesterday"
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

public enum ConversationType: String, Codable {
    case direct = "DIRECT"
    case group = "GROUP"
}

// MARK: - Create Conversation Request
public struct CreateDirectConversationRequest: Codable {
    public let otherUserId: String

    public init(otherUserId: String) {
        self.otherUserId = otherUserId
    }
}

// MARK: - Conversation Actions
public struct ConversationAction: Codable {
    // Used for archive/unarchive, mute/unmute, pin/unpin actions
    public init() {}
}
