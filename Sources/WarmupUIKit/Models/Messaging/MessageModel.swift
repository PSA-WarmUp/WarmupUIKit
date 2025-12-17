//
//  MessageModel.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 9/28/25.
//

import Foundation

// MARK: - Message Models
public struct MessageModel: Codable, Identifiable {
    public let id: String
    public let conversationId: String
    public let senderId: String
    public let senderName: String?
    public let senderProfileImage: String?
    public let recipientId: String?
    public let messageType: MessageType
    public let content: String?
    public let messageContent: MessageContent?
    public let status: MessageStatus
    public let sentAt: String
    public let deliveredAt: String?
    public let readReceipts: [ReadReceipt]?

    // Editing information
    public let isEdited: Bool?
    public let editedAt: String?

    // Reply information (future)
    public let replyToMessageId: String?
    // Note: replyToMessage would need to be loaded separately to avoid recursive struct

    // Read status for current user
    public let isReadByCurrentUser: Bool?
    public let readByCurrentUserAt: String?

    public init(
        id: String,
        conversationId: String,
        senderId: String,
        senderName: String? = nil,
        senderProfileImage: String? = nil,
        recipientId: String? = nil,
        messageType: MessageType,
        content: String? = nil,
        messageContent: MessageContent? = nil,
        status: MessageStatus,
        sentAt: String,
        deliveredAt: String? = nil,
        readReceipts: [ReadReceipt]? = nil,
        isEdited: Bool? = nil,
        editedAt: String? = nil,
        replyToMessageId: String? = nil,
        isReadByCurrentUser: Bool? = nil,
        readByCurrentUserAt: String? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderName = senderName
        self.senderProfileImage = senderProfileImage
        self.recipientId = recipientId
        self.messageType = messageType
        self.content = content
        self.messageContent = messageContent
        self.status = status
        self.sentAt = sentAt
        self.deliveredAt = deliveredAt
        self.readReceipts = readReceipts
        self.isEdited = isEdited
        self.editedAt = editedAt
        self.replyToMessageId = replyToMessageId
        self.isReadByCurrentUser = isReadByCurrentUser
        self.readByCurrentUserAt = readByCurrentUserAt
    }

    // Computed properties - requires currentUserId parameter
    public func isFromCurrentUser(currentUserId: String?) -> Bool {
        guard let userId = currentUserId else { return false }
        return senderId == userId
    }

    public func isOwnMessage(currentUserId: String?) -> Bool {
        return isFromCurrentUser(currentUserId: currentUserId)
    }

    public var isRead: Bool {
        return status == .read
    }

    public var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: sentAt) ?? Date()
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }

    public var sentDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: sentAt)
    }

    public var sentTimeString: String {
        guard let date = sentDate else { return "" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var displayContent: String {
        switch messageType {
        case .text:
            return content ?? messageContent?.text ?? ""
        case .workoutCard:
            return "💪 Shared a workout: \(messageContent?.workoutCard?.workoutTitle ?? "Workout")"
        case .workoutDraft:
            return "📝 Workout draft: \(messageContent?.workoutDraft?.title ?? "Draft")"
        case .workoutSessionShare:
            return "🏆 Completed workout: \(messageContent?.workoutSessionShareCard?.workoutTitle ?? "Workout")"
        case .workoutProposal:
            return "📅 Workout proposal: \(messageContent?.workoutProposal?.workoutTitle ?? "Workout")"
        case .exerciseVideo:
            return "🎥 Shared an exercise: \(messageContent?.exerciseVideo?.exerciseName ?? "Exercise")"
        case .externalLink:
            return "🔗 Shared a link: \(messageContent?.externalLink?.title ?? "Link")"
        case .fileAttachment:
            return "📎 Shared a file: \(messageContent?.fileAttachment?.fileName ?? "File")"
        case .scheduleView:
            return "📅 Schedule: \(messageContent?.dailySchedule?.formattedDate ?? "View schedule")"
        case .system:
            return content ?? "System message"
        }
    }
}

// MARK: - Message Content
public struct MessageContent: Codable {
    // Text message
    public let text: String?

    // Workout card
    public let workoutCard: WorkoutCard?

    // Workout draft (AI-generated, unsaved)
    // Note: Workout type needs to be defined in WarmupCore/Models/Workouts/
    public let workoutDraft: Workout?

    // Workout session share card
    public let workoutSessionShareCard: WorkoutSessionShareCard?

    // Workout proposal (for scheduling with Accept/Reject/Propose new time)
    public let workoutProposal: WorkoutProposalContent?

    // Exercise video
    public let exerciseVideo: ExerciseVideo?

    // External link
    public let externalLink: ExternalLink?

    // File attachment
    public let fileAttachment: FileAttachment?

    // Daily schedule (for SCHEDULE_VIEW message type)
    // Note: DailyScheduleDto type needs to be defined in WarmupCore/Models/Schedule/
    public let dailySchedule: DailyScheduleDto?

    public init(
        text: String? = nil,
        workoutCard: WorkoutCard? = nil,
        workoutDraft: Workout? = nil,
        workoutSessionShareCard: WorkoutSessionShareCard? = nil,
        workoutProposal: WorkoutProposalContent? = nil,
        exerciseVideo: ExerciseVideo? = nil,
        externalLink: ExternalLink? = nil,
        fileAttachment: FileAttachment? = nil,
        dailySchedule: DailyScheduleDto? = nil
    ) {
        self.text = text
        self.workoutCard = workoutCard
        self.workoutDraft = workoutDraft
        self.workoutSessionShareCard = workoutSessionShareCard
        self.workoutProposal = workoutProposal
        self.exerciseVideo = exerciseVideo
        self.externalLink = externalLink
        self.fileAttachment = fileAttachment
        self.dailySchedule = dailySchedule
    }
}

// MARK: - Workout Session Share Card
public struct WorkoutSessionShareCard: Codable {
    public let sessionId: String
    public let workoutId: String?
    public let workoutTitle: String?
    public let clientName: String?
    public let completedAt: String?
    public let duration: Int? // in minutes
    public let exerciseCount: Int?
    public let setsCompleted: Int?
    public let personalRecords: Int?
    public let thumbnailUrl: String?

    public init(
        sessionId: String,
        workoutId: String? = nil,
        workoutTitle: String? = nil,
        clientName: String? = nil,
        completedAt: String? = nil,
        duration: Int? = nil,
        exerciseCount: Int? = nil,
        setsCompleted: Int? = nil,
        personalRecords: Int? = nil,
        thumbnailUrl: String? = nil
    ) {
        self.sessionId = sessionId
        self.workoutId = workoutId
        self.workoutTitle = workoutTitle
        self.clientName = clientName
        self.completedAt = completedAt
        self.duration = duration
        self.exerciseCount = exerciseCount
        self.setsCompleted = setsCompleted
        self.personalRecords = personalRecords
        self.thumbnailUrl = thumbnailUrl
    }
}

public struct WorkoutCard: Codable {
    public let workoutId: String
    public let workoutTitle: String
    public let workoutDescription: String?
    public let thumbnailUrl: String?
    public let duration: Int? // in minutes
    public let difficulty: String?
    public let targetMuscles: [String]?
    public let exerciseCount: Int?

    public init(
        workoutId: String,
        workoutTitle: String,
        workoutDescription: String? = nil,
        thumbnailUrl: String? = nil,
        duration: Int? = nil,
        difficulty: String? = nil,
        targetMuscles: [String]? = nil,
        exerciseCount: Int? = nil
    ) {
        self.workoutId = workoutId
        self.workoutTitle = workoutTitle
        self.workoutDescription = workoutDescription
        self.thumbnailUrl = thumbnailUrl
        self.duration = duration
        self.difficulty = difficulty
        self.targetMuscles = targetMuscles
        self.exerciseCount = exerciseCount
    }
}

public struct ExerciseVideo: Codable {
    public let exerciseId: String
    public let exerciseName: String
    public let videoUrl: String?
    public let thumbnailUrl: String?
    public let duration: Int? // in seconds
    public let targetMuscle: String?
    public let equipment: String?
    public let difficulty: String?

    public init(
        exerciseId: String,
        exerciseName: String,
        videoUrl: String? = nil,
        thumbnailUrl: String? = nil,
        duration: Int? = nil,
        targetMuscle: String? = nil,
        equipment: String? = nil,
        difficulty: String? = nil
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.videoUrl = videoUrl
        self.thumbnailUrl = thumbnailUrl
        self.duration = duration
        self.targetMuscle = targetMuscle
        self.equipment = equipment
        self.difficulty = difficulty
    }
}

public struct ExternalLink: Codable {
    public let url: String
    public let title: String?
    public let description: String?
    public let imageUrl: String?
    public let domain: String?
    public let requiresWarning: Bool? // For external navigation warning

    public init(
        url: String,
        title: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil,
        domain: String? = nil,
        requiresWarning: Bool? = nil
    ) {
        self.url = url
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.domain = domain
        self.requiresWarning = requiresWarning
    }
}

public struct FileAttachment: Codable {
    public let fileId: String
    public let fileName: String
    public let fileType: String
    public let fileSize: Int?
    public let fileUrl: String?
    public let thumbnailUrl: String? // For images/videos

    public init(
        fileId: String,
        fileName: String,
        fileType: String,
        fileSize: Int? = nil,
        fileUrl: String? = nil,
        thumbnailUrl: String? = nil
    ) {
        self.fileId = fileId
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.fileUrl = fileUrl
        self.thumbnailUrl = thumbnailUrl
    }
}

// MARK: - Workout Proposal Content
public struct WorkoutProposalContent: Codable {
    public let workoutId: String?
    public let workoutTitle: String
    public let proposedDate: String // ISO8601 format
    public let proposedTime: String? // e.g., "10:00 AM"
    public let exerciseCount: Int
    public let estimatedDuration: Int? // in minutes
    public let programId: String?
    public let programName: String?
    public let trainerId: String
    public let trainerName: String
    public let status: WorkoutProposalStatus

    // Action tracking
    public let respondedAt: String?
    public let clientResponse: String? // Optional message from client
    public let alternateProposedDate: String? // If client proposes new time

    public enum WorkoutProposalStatus: String, Codable {
        case pending = "PENDING"
        case accepted = "ACCEPTED"
        case rejected = "REJECTED"
        case rescheduled = "RESCHEDULED"
    }

    public init(
        workoutId: String? = nil,
        workoutTitle: String,
        proposedDate: String,
        proposedTime: String? = nil,
        exerciseCount: Int,
        estimatedDuration: Int? = nil,
        programId: String? = nil,
        programName: String? = nil,
        trainerId: String,
        trainerName: String,
        status: WorkoutProposalStatus,
        respondedAt: String? = nil,
        clientResponse: String? = nil,
        alternateProposedDate: String? = nil
    ) {
        self.workoutId = workoutId
        self.workoutTitle = workoutTitle
        self.proposedDate = proposedDate
        self.proposedTime = proposedTime
        self.exerciseCount = exerciseCount
        self.estimatedDuration = estimatedDuration
        self.programId = programId
        self.programName = programName
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.status = status
        self.respondedAt = respondedAt
        self.clientResponse = clientResponse
        self.alternateProposedDate = alternateProposedDate
    }
}

public struct ReadReceipt: Codable {
    public let userId: String
    public let readAt: String

    public init(userId: String, readAt: String) {
        self.userId = userId
        self.readAt = readAt
    }
}

// MARK: - Enums
public enum MessageType: String, Codable {
    case text = "TEXT"
    case workoutCard = "WORKOUT_CARD"
    case workoutDraft = "WORKOUT_DRAFT"
    case workoutSessionShare = "WORKOUT_SESSION_SHARE"
    case workoutProposal = "WORKOUT_PROPOSAL"
    case exerciseVideo = "EXERCISE_VIDEO"
    case externalLink = "EXTERNAL_LINK"
    case fileAttachment = "FILE_ATTACHMENT"
    case scheduleView = "SCHEDULE_VIEW"
    case system = "SYSTEM"
}

public enum MessageStatus: String, Codable {
    case sending = "SENDING"
    case sent = "SENT"
    case delivered = "DELIVERED"
    case read = "READ"
    case failed = "FAILED"
}

// MARK: - Send Message Request
public struct SendMessageRequest: Codable {
    public let recipientId: String
    public let messageType: MessageType
    public let content: String?
    public let messageContent: MessageContent?
    public let replyToMessageId: String?

    public init(
        recipientId: String,
        messageType: MessageType,
        content: String? = nil,
        messageContent: MessageContent? = nil,
        replyToMessageId: String? = nil
    ) {
        self.recipientId = recipientId
        self.messageType = messageType
        self.content = content
        self.messageContent = messageContent
        self.replyToMessageId = replyToMessageId
    }
}

// MARK: - Message Actions
public struct EditMessageRequest: Codable {
    public let content: String

    public init(content: String) {
        self.content = content
    }
}

public struct MarkAsReadRequest: Codable {
    // Empty for now, just a POST request
    public init() {}
}

// MARK: - Supporting Types

// DailyScheduleDto for schedule view messages
public struct DailyScheduleDto: Codable {
    public let date: String?
    public let formattedDate: String?
    public let workouts: [ScheduleWorkoutItem]?

    public init(date: String? = nil, formattedDate: String? = nil, workouts: [ScheduleWorkoutItem]? = nil) {
        self.date = date
        self.formattedDate = formattedDate
        self.workouts = workouts
    }
}

public struct ScheduleWorkoutItem: Codable {
    public let workoutId: String
    public let title: String?
    public let scheduledTime: String?
    public let status: String?

    public init(workoutId: String, title: String? = nil, scheduledTime: String? = nil, status: String? = nil) {
        self.workoutId = workoutId
        self.title = title
        self.scheduledTime = scheduledTime
        self.status = status
    }
}

// Note: Workout type is defined in WarmupCore/Models/Workouts/Workout.swift
