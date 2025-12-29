//
//  NotificationModels.swift
//  WarmupUIKit
//
//  Shared notification models for WarmUp iOS apps
//

import Foundation

// MARK: - App Notification

public struct AppNotification: Codable, Identifiable {
    public let id: String
    public let type: NotificationType
    public let title: String
    public let body: String  // Backend uses "body" not "message"
    public let data: NotificationData?
    public let isRead: Bool
    public let sentAt: String  // Backend uses "sentAt" not "createdAt"
    public let readAt: String?

    /// Convenience property for display
    public var message: String { body }

    public var createdAtDate: Date? {
        ISO8601DateFormatter().date(from: sentAt)
    }

    /// Creates a copy with updated isRead status
    public func withIsRead(_ read: Bool) -> AppNotification {
        AppNotification(
            id: id,
            type: type,
            title: title,
            body: body,
            data: data,
            isRead: read,
            sentAt: sentAt,
            readAt: read ? ISO8601DateFormatter().string(from: Date()) : readAt
        )
    }

    public init(
        id: String,
        type: NotificationType,
        title: String,
        body: String,
        data: NotificationData?,
        isRead: Bool,
        sentAt: String,
        readAt: String?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.data = data
        self.isRead = isRead
        self.sentAt = sentAt
        self.readAt = readAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case body
        case data
        case isRead
        case sentAt
        case readAt
    }
}

// MARK: - Notification Type

public enum NotificationType: String, Codable {
    // Workout notifications
    case workoutReminder = "WORKOUT_REMINDER"
    case workoutProposal = "WORKOUT_PROPOSAL"
    case workoutAccepted = "WORKOUT_ACCEPTED"
    case workoutCompleted = "WORKOUT_COMPLETED"

    // Social/Follow notifications
    case followRequest = "FOLLOW_REQUEST"
    case followAccepted = "FOLLOW_ACCEPTED"
    case newFollower = "NEW_FOLLOWER"

    // Message notifications
    case newMessage = "NEW_MESSAGE"

    // Post/Feed notifications
    case postLiked = "POST_LIKED"
    case postCommented = "POST_COMMENTED"
    case postMentioned = "POST_MENTIONED"
    case postShared = "POST_SHARED"

    // Consultation notification types
    case consultationBooked = "CONSULTATION_BOOKED"
    case consultationConfirmed = "CONSULTATION_CONFIRMED"
    case consultationDeclined = "CONSULTATION_DECLINED"
    case consultationCancelled = "CONSULTATION_CANCELLED"
    case consultationReminder24h = "CONSULTATION_REMINDER_24H"
    case consultationReminder1h = "CONSULTATION_REMINDER_1H"
    case consultationReminder15m = "CONSULTATION_REMINDER_15M"
    case consultationRescheduled = "CONSULTATION_RESCHEDULED"

    // Program notifications
    case programAssigned = "PROGRAM_ASSIGNED"
    case programCompleted = "PROGRAM_COMPLETED"

    // Achievement notifications
    case milestone = "MILESTONE"

    // General/fallback (also used for unknown types)
    case general = "GENERAL"
    case unknown = "UNKNOWN"

    public var icon: String {
        switch self {
        case .workoutReminder, .workoutProposal, .workoutAccepted, .workoutCompleted:
            return "dumbbell.fill"
        case .followRequest, .followAccepted, .newFollower:
            return "person.badge.plus"
        case .newMessage:
            return "message.fill"
        case .postLiked:
            return "heart.fill"
        case .postCommented:
            return "bubble.left.fill"
        case .postMentioned:
            return "at"
        case .postShared:
            return "arrowshape.turn.up.right.fill"
        case .consultationBooked, .consultationConfirmed, .consultationDeclined,
             .consultationCancelled, .consultationReminder24h,
             .consultationReminder1h, .consultationReminder15m, .consultationRescheduled:
            return "calendar.badge.clock"
        case .programAssigned, .programCompleted:
            return "list.bullet.clipboard"
        case .milestone:
            return "trophy.fill"
        case .general, .unknown:
            return "bell.fill"
        }
    }

    /// Custom decoder that falls back to .unknown for unrecognized types
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = NotificationType(rawValue: rawValue) ?? .unknown
    }
}

// MARK: - Notification Data

public struct NotificationData: Codable {
    // Workout related
    public let workoutId: String?
    public let clientId: String?
    public let trainerId: String?

    // Consultation related
    public let consultationId: String?

    // Program related
    public let programId: String?

    // Message related
    public let conversationId: String?

    // Post/Feed related
    public let postId: String?
    public let commenterId: String?
    public let commenterName: String?
    public let action: String?

    // Follow related
    public let followId: String?

    // Generic
    public let userId: String?

    public init(
        workoutId: String? = nil,
        clientId: String? = nil,
        trainerId: String? = nil,
        consultationId: String? = nil,
        programId: String? = nil,
        conversationId: String? = nil,
        postId: String? = nil,
        commenterId: String? = nil,
        commenterName: String? = nil,
        action: String? = nil,
        followId: String? = nil,
        userId: String? = nil
    ) {
        self.workoutId = workoutId
        self.clientId = clientId
        self.trainerId = trainerId
        self.consultationId = consultationId
        self.programId = programId
        self.conversationId = conversationId
        self.postId = postId
        self.commenterId = commenterId
        self.commenterName = commenterName
        self.action = action
        self.followId = followId
        self.userId = userId
    }
}

// MARK: - Notification List Response

/// Response model matching Spring Boot Pageable response format
public struct NotificationListResponse: Codable {
    public let content: [AppNotification]
    public let totalElements: Int
    public let totalPages: Int
    public let number: Int  // current page (0-indexed)
    public let size: Int    // page size
    public let last: Bool
    public let first: Bool
    public let empty: Bool

    /// Convenience properties for backwards compatibility
    public var notifications: [AppNotification] { content }
    public var total: Int { totalElements }
    public var page: Int { number }
    public var limit: Int { size }

    /// Initialize with default values for empty response
    public init(
        content: [AppNotification] = [],
        totalElements: Int = 0,
        totalPages: Int = 0,
        number: Int = 0,
        size: Int = 20,
        last: Bool = true,
        first: Bool = true,
        empty: Bool = true
    ) {
        self.content = content
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.number = number
        self.size = size
        self.last = last
        self.first = first
        self.empty = empty
    }
}

// MARK: - Unread Count Response

public struct UnreadCountResponse: Codable {
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public init(from decoder: Decoder) throws {
        // Try to decode as object with count property first
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let count = try? container.decode(Int.self, forKey: .count) {
            self.count = count
        } else if let singleValue = try? decoder.singleValueContainer(),
                  let count = try? singleValue.decode(Int.self) {
            // Handle case where it's just a number
            self.count = count
        } else {
            self.count = 0
        }
    }

    enum CodingKeys: String, CodingKey {
        case count
    }
}
