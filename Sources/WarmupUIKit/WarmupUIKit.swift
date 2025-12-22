//
//  WarmupUIKit.swift
//  WarmupUIKit
//
//  Shared library for WarmUp iOS apps (Trainer & Client)
//

import Foundation
import SwiftUI

/// WarmupUIKit module version
public let WarmupUIKitVersion = "1.0.0"

/// Re-export all public types for convenient importing
/// Usage: import WarmupUIKit

// MARK: - Models
// Auth, Users, Workouts, Messaging, Programs, API responses
// Social: FollowModels (FollowButtonStatus, FollowStatus, UserSummary, FollowRequestContent, etc.)
// Search: UserSearchDto, SocialSearchResponse, SearchMetadata

// MARK: - Networking
// NetworkService, APIEndpoints, AuthService

// MARK: - Services
// AuthService

// MARK: - UI Components
// Shared SwiftUI components and theme
// - DynamicTheme: Colors, Typography, Spacing, Radius, Animations, Shadows
// - QuickActionButton: Reusable button in bubble, chip, filled, outlined styles
// - QuickActionRow: Horizontal scrolling row of quick action buttons
// - QuickActionGrid: Grid layout for quick actions
// - TrainerQuickActions: Pre-configured actions for trainer app
// - ClientQuickActions: Pre-configured actions for client app
//
// Social Components:
// - FollowButton: Follow/Following/Requested/Mutual button states
// - CompactFollowButton: Circular icon variant
// - UserRowView: User row with avatar, name, badges, follow button
// - CompactUserRowView: Compact variant for mentions/search
// - FollowRequestCard: Follow request card with accept/decline actions
// - StatusBadge: Generic status badge (neutral, info, warning, success, error)

// MARK: - Utilities
// Extensions, helpers, constants
