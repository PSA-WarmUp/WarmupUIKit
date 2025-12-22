//
//  SearchModels.swift
//  WarmupUIKit
//
//  Shared models for social search functionality
//

import Foundation

// MARK: - User Search DTO
/// Represents a user in search results with social context
public struct UserSearchDto: Codable, Identifiable, Equatable {
    public let id: String
    public let displayName: String
    public let avatarUrl: String?
    public let isTrainer: Bool?
    public let bio: String?
    public let specializations: String?
    public let city: String?
    public let state: String?
    public let rating: Double?
    public let totalReviews: Int?
    public let followStatus: String?  // "NONE", "PENDING", "FOLLOWING"
    public let isFollower: Bool?
    public let acceptingNewClients: Bool?

    // MARK: - Computed Properties

    /// Combined location string (city, state)
    public var location: String? {
        switch (city, state) {
        case let (city?, state?):
            return "\(city), \(state)"
        case let (city?, nil):
            return city
        case let (nil, state?):
            return state
        case (nil, nil):
            return nil
        }
    }

    /// Convert followStatus string to FollowRelationshipStatus enum
    public var followButtonStatus: FollowRelationshipStatus {
        guard let statusString = followStatus else {
            return .none
        }
        return FollowRelationshipStatus(rawValue: statusString) ?? .none
    }

    /// True if user can be messaged (following them)
    public var canMessage: Bool {
        followStatus == "FOLLOWING"
    }

    /// True if currently following this user
    public var isFollowing: Bool {
        followStatus == "FOLLOWING"
    }

    /// True if follow request is pending
    public var isPending: Bool {
        followStatus == "PENDING"
    }

    /// Formatted rating string (e.g., "4.5")
    public var formattedRating: String? {
        guard let rating = rating else { return nil }
        return String(format: "%.1f", rating)
    }

    /// Convert to UserSummary for compatibility with existing components
    public var toUserSummary: UserSummary {
        UserSummary(
            userId: id,
            displayName: displayName,
            avatarUrl: avatarUrl,
            isTrainer: isTrainer,
            isFollowing: isFollowing,
            isFollower: isFollower
        )
    }

    public init(
        id: String,
        displayName: String,
        avatarUrl: String? = nil,
        isTrainer: Bool? = nil,
        bio: String? = nil,
        specializations: String? = nil,
        city: String? = nil,
        state: String? = nil,
        rating: Double? = nil,
        totalReviews: Int? = nil,
        followStatus: String? = nil,
        isFollower: Bool? = nil,
        acceptingNewClients: Bool? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isTrainer = isTrainer
        self.bio = bio
        self.specializations = specializations
        self.city = city
        self.state = state
        self.rating = rating
        self.totalReviews = totalReviews
        self.followStatus = followStatus
        self.isFollower = isFollower
        self.acceptingNewClients = acceptingNewClients
    }
}

// MARK: - Social Search Response
/// Response from the social search endpoint with categorized results
public struct SocialSearchResponse: Codable, Equatable {
    public let following: [UserSearchDto]?
    public let followers: [UserSearchDto]?
    public let suggestions: [UserSearchDto]?
    public let metadata: SearchMetadata?

    /// All results combined (following first, then followers, then suggestions)
    public var allResults: [UserSearchDto] {
        var results: [UserSearchDto] = []
        if let following = following { results.append(contentsOf: following) }
        if let followers = followers { results.append(contentsOf: followers) }
        if let suggestions = suggestions { results.append(contentsOf: suggestions) }
        return results
    }

    /// True if there are any results
    public var hasResults: Bool {
        !allResults.isEmpty
    }

    /// Total count of all results
    public var totalCount: Int {
        (following?.count ?? 0) + (followers?.count ?? 0) + (suggestions?.count ?? 0)
    }

    public init(
        following: [UserSearchDto]? = nil,
        followers: [UserSearchDto]? = nil,
        suggestions: [UserSearchDto]? = nil,
        metadata: SearchMetadata? = nil
    ) {
        self.following = following
        self.followers = followers
        self.suggestions = suggestions
        self.metadata = metadata
    }
}

// MARK: - Search Metadata
/// Metadata about search results (pagination, query info)
public struct SearchMetadata: Codable, Equatable {
    public let query: String?
    public let totalResults: Int?
    public let page: Int?
    public let pageSize: Int?

    /// True if there are more results available
    public var hasMore: Bool {
        guard let total = totalResults, let page = page, let size = pageSize else {
            return false
        }
        return (page + 1) * size < total
    }

    public init(
        query: String? = nil,
        totalResults: Int? = nil,
        page: Int? = nil,
        pageSize: Int? = nil
    ) {
        self.query = query
        self.totalResults = totalResults
        self.page = page
        self.pageSize = pageSize
    }
}
