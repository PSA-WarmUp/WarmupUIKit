//
//  FollowModels.swift
//  WarmupUIKit
//
//  Shared models for the Follow/Friends system
//

import Foundation

// MARK: - Follow Button Status
/// The visual state of a follow button
public enum FollowButtonStatus: Equatable {
    case notFollowing
    case following
    case pending
    case mutual
    case loading

    public var buttonTitle: String {
        switch self {
        case .notFollowing: return "Follow"
        case .following: return "Following"
        case .pending: return "Requested"
        case .mutual: return "Friends"
        case .loading: return ""
        }
    }
}

// MARK: - Follow Status (API Response)
/// Status values from follow action API responses
public enum FollowStatus: String, Codable {
    case active = "ACTIVE"      // Following relationship is active
    case pending = "PENDING"    // Follow request pending approval
    case blocked = "BLOCKED"    // User is blocked

    public var isActive: Bool { self == .active }
    public var isPending: Bool { self == .pending }
}

// MARK: - Follow Relationship Status (Check Endpoint)
/// Status values from the follow check endpoint
public enum FollowRelationshipStatus: String, Codable {
    case none = "NONE"           // Not following
    case pending = "PENDING"     // Follow request sent, awaiting approval
    case following = "FOLLOWING" // Actively following

    public var buttonTitle: String {
        switch self {
        case .none: return "Follow"
        case .pending: return "Requested"
        case .following: return "Following"
        }
    }

    public var toButtonStatus: FollowButtonStatus {
        switch self {
        case .none: return .notFollowing
        case .pending: return .pending
        case .following: return .following
        }
    }
}

// MARK: - User Summary
/// Lightweight user model for follow lists and search results
public struct UserSummary: Codable, Identifiable, Equatable {
    public let userId: String
    public let displayName: String
    public let avatarUrl: String?
    public let isTrainer: Bool?
    public let isFollowing: Bool?      // Am I following them?
    public let isFollower: Bool?       // Are they following me?

    public var id: String { userId }

    public var isMutualFollow: Bool {
        (isFollowing ?? false) && (isFollower ?? false)
    }

    public init(
        userId: String,
        displayName: String,
        avatarUrl: String? = nil,
        isTrainer: Bool? = nil,
        isFollowing: Bool? = nil,
        isFollower: Bool? = nil
    ) {
        self.userId = userId
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isTrainer = isTrainer
        self.isFollowing = isFollowing
        self.isFollower = isFollower
    }
}

// MARK: - Follow Request Content (for DM messages)
/// Content for FOLLOW_REQUEST message type
public struct FollowRequestContent: Codable, Equatable {
    public let followId: String
    public let requesterId: String
    public let requesterName: String
    public let requesterAvatarUrl: String?
    public let requesterIsTrainer: Bool?
    public let status: FollowRequestStatus
    public let respondedAt: String?

    public var isPending: Bool { status == .pending }
    public var isAccepted: Bool { status == .accepted }
    public var isDeclined: Bool { status == .declined }

    public init(
        followId: String,
        requesterId: String,
        requesterName: String,
        requesterAvatarUrl: String? = nil,
        requesterIsTrainer: Bool? = nil,
        status: FollowRequestStatus,
        respondedAt: String? = nil
    ) {
        self.followId = followId
        self.requesterId = requesterId
        self.requesterName = requesterName
        self.requesterAvatarUrl = requesterAvatarUrl
        self.requesterIsTrainer = requesterIsTrainer
        self.status = status
        self.respondedAt = respondedAt
    }
}

// MARK: - Follow Request Status
public enum FollowRequestStatus: String, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
}

// MARK: - Follow Stats
public struct FollowStats: Codable, Equatable {
    public let followersCount: Int
    public let followingCount: Int
    public let pendingRequestsCount: Int?

    public var hasPendingRequests: Bool {
        (pendingRequestsCount ?? 0) > 0
    }

    public init(followersCount: Int, followingCount: Int, pendingRequestsCount: Int? = nil) {
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.pendingRequestsCount = pendingRequestsCount
    }
}
