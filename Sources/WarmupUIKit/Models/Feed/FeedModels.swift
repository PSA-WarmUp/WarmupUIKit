//
//  FeedModels.swift
//  WarmupUIKit
//
//  Social Feed data models matching the OpenAPI specification
//  Shared between trainer and client apps
//

import Foundation

// MARK: - Feed Response
public struct FeedResponse: Codable {
    public let items: [FeedItem]?
    public let pageInfo: PageInfo?
    public let metadata: FeedMetadata?

    public init(items: [FeedItem]?, pageInfo: PageInfo?, metadata: FeedMetadata?) {
        self.items = items
        self.pageInfo = pageInfo
        self.metadata = metadata
    }
}

public struct PageInfo: Codable {
    public let page: Int?
    public let size: Int?
    public let totalElements: Int64?
    public let totalPages: Int?

    public var hasMore: Bool {
        guard let page = page, let totalPages = totalPages else { return false }
        return page < totalPages - 1
    }

    public init(page: Int?, size: Int?, totalElements: Int64?, totalPages: Int?) {
        self.page = page
        self.size = size
        self.totalElements = totalElements
        self.totalPages = totalPages
    }
}

public struct FeedMetadata: Codable {
    public let lastRefresh: String?
    public let newPostsAvailable: Int?
    public let feedType: String?

    public init(lastRefresh: String?, newPostsAvailable: Int?, feedType: String?) {
        self.lastRefresh = lastRefresh
        self.newPostsAvailable = newPostsAvailable
        self.feedType = feedType
    }
}

// MARK: - Feed Item (Post)
public struct FeedItem: Codable, Identifiable {
    public let id: String
    public let author: AuthorInfo?
    public let postType: PostType
    public let perspective: PostPerspective?
    public let visibility: PostVisibility?
    public let createdAt: String?

    // Card variants - backend sends the appropriate one based on viewer access
    public let publicCard: PublicCardDto?
    public let friendsCard: FriendsCardDto?
    public let fullCard: FullCardDto?
    public let milestone: MilestoneCardDto?
    public let shoutout: ShoutoutCardDto?

    // Top-level workout data (backend may send this directly instead of nested in card objects)
    public let workoutType: String?
    public let title: String?
    public let programName: String?
    public let workoutLabel: String?
    public let durationMinutes: Int?
    public let totalSets: Int?
    public let totalReps: Int?
    public let totalVolume: Double?
    public let volumeUnit: String?
    public let averageRpe: Double?
    public let personalRecordsCount: Int?
    public let prFlags: [String]?
    public let trainerNotes: String?
    public let clientReflection: String?
    public let caption: String?

    // Engagement metrics
    public let likeCount: Int?
    public let commentCount: Int?
    public let viewerLiked: Bool?
    public let viewerCanComment: Bool?
    public let viewerCanLike: Bool?
    public let availableActions: [String]?

    // Linked content
    public let linkedWorkoutId: String?

    // MARK: - Computed Properties

    public var displayName: String {
        author?.displayName ?? "Unknown"
    }

    public var avatarUrl: String? {
        author?.avatarUrl
    }

    public var isOwnPost: Bool {
        author?.isCurrentUser ?? false
    }

    public var hasLiked: Bool {
        viewerLiked ?? false
    }

    public var likes: Int {
        likeCount ?? 0
    }

    public var comments: Int {
        commentCount ?? 0
    }

    public var canLike: Bool {
        viewerCanLike ?? true
    }

    public var canComment: Bool {
        viewerCanComment ?? true
    }

    /// Creates a copy of this FeedItem with updated like state (for optimistic updates)
    public func withLikeState(liked: Bool, likeCount: Int) -> FeedItem {
        FeedItem(
            id: id,
            author: author,
            postType: postType,
            perspective: perspective,
            visibility: visibility,
            createdAt: createdAt,
            publicCard: publicCard,
            friendsCard: friendsCard,
            fullCard: fullCard,
            milestone: milestone,
            shoutout: shoutout,
            workoutType: workoutType,
            title: title,
            programName: programName,
            workoutLabel: workoutLabel,
            durationMinutes: durationMinutes,
            totalSets: totalSets,
            totalReps: totalReps,
            totalVolume: totalVolume,
            volumeUnit: volumeUnit,
            averageRpe: averageRpe,
            personalRecordsCount: personalRecordsCount,
            prFlags: prFlags,
            trainerNotes: trainerNotes,
            clientReflection: clientReflection,
            caption: caption,
            likeCount: likeCount,
            commentCount: commentCount,
            viewerLiked: liked,
            viewerCanComment: viewerCanComment,
            viewerCanLike: viewerCanLike,
            availableActions: availableActions,
            linkedWorkoutId: linkedWorkoutId
        )
    }

    public var timeAgo: String {
        // Try to get from card data first
        if let time = publicCard?.timeAgo { return time }
        if let time = friendsCard?.timeAgo { return time }
        if let time = fullCard?.timeAgo { return time }

        // Fallback to computing from createdAt
        guard let createdAt = createdAt else { return "" }
        return formatTimeAgo(from: createdAt)
    }

    /// Gets workout type from card or top-level field
    public var displayWorkoutType: String? {
        publicCard?.workoutType ?? friendsCard?.workoutType ?? fullCard?.workoutType ?? workoutType ?? title
    }

    /// Gets caption from card or top-level field
    public var displayCaption: String? {
        publicCard?.caption ?? friendsCard?.caption ?? fullCard?.caption ?? caption
    }

    /// Gets duration from card or top-level field
    public var displayDurationMinutes: Int? {
        publicCard?.durationMinutes ?? friendsCard?.durationMinutes ?? fullCard?.durationMinutes ?? durationMinutes
    }

    /// Synthesizes a FullCardDto from top-level workout data when card variants are nil
    /// This allows the FullCardContent view to render even when backend sends data at top level
    public var synthesizedFullCard: FullCardDto? {
        // If any card variant exists, don't synthesize
        if fullCard != nil || friendsCard != nil || publicCard != nil {
            return nil
        }

        // Check if we have any workout data to synthesize from
        let hasWorkoutData = workoutType != nil || title != nil ||
            durationMinutes != nil || totalSets != nil ||
            totalVolume != nil || averageRpe != nil ||
            prFlags != nil || trainerNotes != nil

        guard hasWorkoutData else { return nil }

        return FullCardDto(
            workoutType: workoutType ?? title,
            durationMinutes: durationMinutes,
            caloriesBurned: nil,
            avgHeartRate: nil,
            totalVolume: totalVolume,
            volumeUnit: volumeUnit,
            distanceMiles: nil,
            pace: nil,
            programName: programName,
            workoutLabel: workoutLabel,
            exercises: nil,
            rpe: nil,
            trainerNotes: trainerNotes,
            clientReflection: clientReflection,
            caption: caption,
            prFlags: prFlags,
            timeAgo: nil,
            totalSets: totalSets,
            totalReps: totalReps,
            personalRecordsCount: personalRecordsCount,
            averageRpe: averageRpe
        )
    }

    /// Returns the best available card data for rendering
    public var effectiveFullCard: FullCardDto? {
        fullCard ?? synthesizedFullCard
    }

    private func formatTimeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return ""
            }
            return calculateTimeAgo(from: date)
        }
        return calculateTimeAgo(from: date)
    }

    private func calculateTimeAgo(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1w ago" : "\(weeks)w ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1d ago" : "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1h ago" : "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1m ago" : "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }

    public init(
        id: String,
        author: AuthorInfo?,
        postType: PostType,
        perspective: PostPerspective?,
        visibility: PostVisibility?,
        createdAt: String?,
        publicCard: PublicCardDto?,
        friendsCard: FriendsCardDto?,
        fullCard: FullCardDto?,
        milestone: MilestoneCardDto?,
        shoutout: ShoutoutCardDto?,
        workoutType: String?,
        title: String?,
        programName: String?,
        workoutLabel: String?,
        durationMinutes: Int?,
        totalSets: Int?,
        totalReps: Int?,
        totalVolume: Double?,
        volumeUnit: String?,
        averageRpe: Double?,
        personalRecordsCount: Int?,
        prFlags: [String]?,
        trainerNotes: String?,
        clientReflection: String?,
        caption: String?,
        likeCount: Int?,
        commentCount: Int?,
        viewerLiked: Bool?,
        viewerCanComment: Bool?,
        viewerCanLike: Bool?,
        availableActions: [String]?,
        linkedWorkoutId: String?
    ) {
        self.id = id
        self.author = author
        self.postType = postType
        self.perspective = perspective
        self.visibility = visibility
        self.createdAt = createdAt
        self.publicCard = publicCard
        self.friendsCard = friendsCard
        self.fullCard = fullCard
        self.milestone = milestone
        self.shoutout = shoutout
        self.workoutType = workoutType
        self.title = title
        self.programName = programName
        self.workoutLabel = workoutLabel
        self.durationMinutes = durationMinutes
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalVolume = totalVolume
        self.volumeUnit = volumeUnit
        self.averageRpe = averageRpe
        self.personalRecordsCount = personalRecordsCount
        self.prFlags = prFlags
        self.trainerNotes = trainerNotes
        self.clientReflection = clientReflection
        self.caption = caption
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.viewerLiked = viewerLiked
        self.viewerCanComment = viewerCanComment
        self.viewerCanLike = viewerCanLike
        self.availableActions = availableActions
        self.linkedWorkoutId = linkedWorkoutId
    }
}

// MARK: - Author Info
public struct AuthorInfo: Codable {
    public let userId: String?
    public let displayName: String?
    public let avatarUrl: String?
    public let isTrainer: Bool?
    public let isCurrentUser: Bool?

    // Custom decoding to handle both avatarUrl and profileImageUrl from backend
    enum CodingKeys: String, CodingKey {
        case userId
        case displayName
        case avatarUrl
        case profileImageUrl
        case isTrainer
        case isCurrentUser
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        // Try avatarUrl first, fall back to profileImageUrl
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
            ?? container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        isTrainer = try container.decodeIfPresent(Bool.self, forKey: .isTrainer)
        isCurrentUser = try container.decodeIfPresent(Bool.self, forKey: .isCurrentUser)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encodeIfPresent(isTrainer, forKey: .isTrainer)
        try container.encodeIfPresent(isCurrentUser, forKey: .isCurrentUser)
    }

    public init(userId: String?, displayName: String?, avatarUrl: String?, isTrainer: Bool?, isCurrentUser: Bool?) {
        self.userId = userId
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isTrainer = isTrainer
        self.isCurrentUser = isCurrentUser
    }
}

// MARK: - Post Types
public enum PostType: String, Codable, CaseIterable {
    case workoutSummary = "WORKOUT_SUMMARY"
    case workout = "WORKOUT"  // Backend may send either WORKOUT or WORKOUT_SUMMARY
    case milestone = "MILESTONE"
    case trainerShoutout = "TRAINER_SHOUTOUT"
    case reflection = "REFLECTION"
    case weeklySummary = "WEEKLY_SUMMARY"
    case programCompletion = "PROGRAM_COMPLETION"

    public var displayName: String {
        switch self {
        case .workoutSummary, .workout: return "Workout"
        case .milestone: return "Milestone"
        case .trainerShoutout: return "Shoutout"
        case .reflection: return "Reflection"
        case .weeklySummary: return "Weekly Summary"
        case .programCompletion: return "Program Complete"
        }
    }

    public var iconName: String {
        switch self {
        case .workoutSummary, .workout: return "figure.run"
        case .milestone: return "trophy.fill"
        case .trainerShoutout: return "megaphone.fill"
        case .reflection: return "text.quote"
        case .weeklySummary: return "calendar"
        case .programCompletion: return "checkmark.seal.fill"
        }
    }

    /// Check if this is a workout-type post
    public var isWorkout: Bool {
        self == .workout || self == .workoutSummary
    }
}

// MARK: - Post Perspective
public enum PostPerspective: String, Codable {
    case `self` = "SELF"       // Client posting about own workout
    case coach = "COACH"       // Trainer posting about client
    case system = "SYSTEM"     // Auto-generated milestone cards
}

// MARK: - Post Visibility
public enum PostVisibility: String, Codable, CaseIterable {
    case `public` = "PUBLIC"
    case friends = "FRIENDS"
    case trainerClient = "TRAINER_CLIENT"
    case `private` = "PRIVATE"

    public var displayName: String {
        switch self {
        case .public: return "Public"
        case .friends: return "Friends"
        case .trainerClient: return "Trainer Only"
        case .private: return "Private"
        }
    }

    public var description: String {
        switch self {
        case .public: return "Anyone can see"
        case .friends: return "Your connections"
        case .trainerClient: return "Just you and your trainer"
        case .private: return "Only you"
        }
    }

    public var iconName: String {
        switch self {
        case .public: return "globe"
        case .friends: return "person.2.fill"
        case .trainerClient: return "person.badge.shield.checkmark.fill"
        case .private: return "lock.fill"
        }
    }
}

// MARK: - Card DTOs

/// Minimal card for public viewers (Garmin-style)
public struct PublicCardDto: Codable {
    public let workoutType: String?
    public let durationMinutes: Int?
    public let caloriesBurned: Int?
    public let avgHeartRate: Int?
    public let timeAgo: String?
    public let caption: String?
    // New metrics from WorkoutLog
    public let totalSets: Int?
    public let totalReps: Int?
    public let personalRecordsCount: Int?

    public init(workoutType: String?, durationMinutes: Int?, caloriesBurned: Int?, avgHeartRate: Int?, timeAgo: String?, caption: String?, totalSets: Int?, totalReps: Int?, personalRecordsCount: Int?) {
        self.workoutType = workoutType
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.avgHeartRate = avgHeartRate
        self.timeAgo = timeAgo
        self.caption = caption
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.personalRecordsCount = personalRecordsCount
    }
}

/// Extended card for friends
public struct FriendsCardDto: Codable {
    public let workoutType: String?
    public let durationMinutes: Int?
    public let caloriesBurned: Int?
    public let avgHeartRate: Int?
    public let totalVolume: Double?
    public let volumeUnit: String?
    public let distanceMiles: Double?
    public let pace: String?
    public let caption: String?
    public let timeAgo: String?
    // New metrics from WorkoutLog
    public let totalSets: Int?
    public let totalReps: Int?
    public let personalRecordsCount: Int?
    public let averageRpe: Double?

    public init(workoutType: String?, durationMinutes: Int?, caloriesBurned: Int?, avgHeartRate: Int?, totalVolume: Double?, volumeUnit: String?, distanceMiles: Double?, pace: String?, caption: String?, timeAgo: String?, totalSets: Int?, totalReps: Int?, personalRecordsCount: Int?, averageRpe: Double?) {
        self.workoutType = workoutType
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.avgHeartRate = avgHeartRate
        self.totalVolume = totalVolume
        self.volumeUnit = volumeUnit
        self.distanceMiles = distanceMiles
        self.pace = pace
        self.caption = caption
        self.timeAgo = timeAgo
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.personalRecordsCount = personalRecordsCount
        self.averageRpe = averageRpe
    }
}

/// Full detail card for trainer/client/self views
public struct FullCardDto: Codable {
    public let workoutType: String?
    public let durationMinutes: Int?
    public let caloriesBurned: Int?
    public let avgHeartRate: Int?
    public let totalVolume: Double?
    public let volumeUnit: String?
    public let distanceMiles: Double?
    public let pace: String?
    public let programName: String?
    public let workoutLabel: String?
    public let exercises: [ExerciseHighlightDto]?
    public let rpe: Int?
    public let trainerNotes: String?
    public let clientReflection: String?
    public let caption: String?
    public let prFlags: [String]?
    public let timeAgo: String?
    // New metrics from WorkoutLog
    public let totalSets: Int?
    public let totalReps: Int?
    public let personalRecordsCount: Int?
    public let averageRpe: Double?

    public init(workoutType: String?, durationMinutes: Int?, caloriesBurned: Int?, avgHeartRate: Int?, totalVolume: Double?, volumeUnit: String?, distanceMiles: Double?, pace: String?, programName: String?, workoutLabel: String?, exercises: [ExerciseHighlightDto]?, rpe: Int?, trainerNotes: String?, clientReflection: String?, caption: String?, prFlags: [String]?, timeAgo: String?, totalSets: Int?, totalReps: Int?, personalRecordsCount: Int?, averageRpe: Double?) {
        self.workoutType = workoutType
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.avgHeartRate = avgHeartRate
        self.totalVolume = totalVolume
        self.volumeUnit = volumeUnit
        self.distanceMiles = distanceMiles
        self.pace = pace
        self.programName = programName
        self.workoutLabel = workoutLabel
        self.exercises = exercises
        self.rpe = rpe
        self.trainerNotes = trainerNotes
        self.clientReflection = clientReflection
        self.caption = caption
        self.prFlags = prFlags
        self.timeAgo = timeAgo
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.personalRecordsCount = personalRecordsCount
        self.averageRpe = averageRpe
    }
}

/// Exercise highlight in full card
public struct ExerciseHighlightDto: Codable, Identifiable {
    public var id: String { exerciseId ?? UUID().uuidString }
    public let exerciseId: String?
    public let name: String?
    public let summary: String?
    public let isPR: Bool?

    public init(exerciseId: String?, name: String?, summary: String?, isPR: Bool?) {
        self.exerciseId = exerciseId
        self.name = name
        self.summary = summary
        self.isPR = isPR
    }
}

/// Milestone celebration card
public struct MilestoneCardDto: Codable {
    public let type: String?
    public let title: String?
    public let subtitle: String?
    public let iconType: String?
    public let showCongratsButton: Bool?

    public var iconName: String {
        switch iconType?.lowercased() {
        case "trophy": return "trophy.fill"
        case "fire", "flame": return "flame.fill"
        case "star": return "star.fill"
        case "medal": return "medal.fill"
        case "streak": return "bolt.fill"
        default: return "trophy.fill"
        }
    }

    public init(type: String?, title: String?, subtitle: String?, iconType: String?, showCongratsButton: Bool?) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.iconType = iconType
        self.showCongratsButton = showCongratsButton
    }
}

/// Trainer shoutout card
public struct ShoutoutCardDto: Codable {
    public let trainerId: String?
    public let trainerName: String?
    public let trainerAvatarUrl: String?
    public let clientId: String?
    public let clientName: String?
    public let clientAvatarUrl: String?
    public let message: String?
    public let achievements: [String]?

    public init(trainerId: String?, trainerName: String?, trainerAvatarUrl: String?, clientId: String?, clientName: String?, clientAvatarUrl: String?, message: String?, achievements: [String]?) {
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.trainerAvatarUrl = trainerAvatarUrl
        self.clientId = clientId
        self.clientName = clientName
        self.clientAvatarUrl = clientAvatarUrl
        self.message = message
        self.achievements = achievements
    }
}

// MARK: - Reaction Types
public enum ReactionType: String, Codable, CaseIterable {
    case like = "LIKE"
    case fire = "FIRE"
    case clap = "CLAP"
    case strong = "STRONG"
    case heart = "HEART"

    public var emoji: String {
        switch self {
        case .like: return "👍"
        case .fire: return "🔥"
        case .clap: return "👏"
        case .strong: return "💪"
        case .heart: return "❤️"
        }
    }

    public var iconName: String {
        switch self {
        case .like: return "hand.thumbsup.fill"
        case .fire: return "flame.fill"
        case .clap: return "hands.clap.fill"
        case .strong: return "figure.strengthtraining.traditional"
        case .heart: return "heart.fill"
        }
    }
}

// MARK: - Liker DTO
/// Represents a user who liked a post
public struct LikerDto: Codable, Identifiable {
    public let userId: String
    public let displayName: String
    public let avatarUrl: String?
    public let isTrainer: Bool?
    public let likedAt: String?

    public var id: String { userId }

    public init(userId: String, displayName: String, avatarUrl: String?, isTrainer: Bool?, likedAt: String?) {
        self.userId = userId
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isTrainer = isTrainer
        self.likedAt = likedAt
    }
}

// MARK: - Share Card Response
/// Privacy-safe share card data for external sharing
public struct ShareCardResponse: Codable {
    public let postId: String
    public let cardType: String?
    public let title: String?
    public let subtitle: String?
    public let imageUrl: String?
    public let shareUrl: String?
    public let metrics: ShareCardMetrics?

    public init(postId: String, cardType: String?, title: String?, subtitle: String?, imageUrl: String?, shareUrl: String?, metrics: ShareCardMetrics?) {
        self.postId = postId
        self.cardType = cardType
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.shareUrl = shareUrl
        self.metrics = metrics
    }
}

public struct ShareCardMetrics: Codable {
    public let primaryValue: String?
    public let primaryLabel: String?
    public let secondaryValue: String?
    public let secondaryLabel: String?

    public init(primaryValue: String?, primaryLabel: String?, secondaryValue: String?, secondaryLabel: String?) {
        self.primaryValue = primaryValue
        self.primaryLabel = primaryLabel
        self.secondaryValue = secondaryValue
        self.secondaryLabel = secondaryLabel
    }
}
