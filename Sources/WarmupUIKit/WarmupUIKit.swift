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
// NetworkService, APIEndpoints, BaseAuthService

// MARK: - Services
// BaseAuthService (base class for app-specific auth implementations)

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
//
// Calendar Components:
// - CalendarEventDisplayable: Protocol for displayable calendar events
// - CalendarEventType: Workout, consultation, or custom event types
// - CalendarEventStatus: Event status (scheduled, inProgress, completed, etc.)
// - HourSlotView: Hour slot for hourly calendar view
// - CalendarDayCell: Day cell for week strip calendar
// - CalendarStatusBadge: Status badge for calendar events
// - CurrentTimeIndicator: Red line showing current time
// - CalendarEventCardView: Generic event card for hourly calendar
// - ConsultationEventCard: Specialized card for consultations
// - WeekNavigationHeader: Navigation header for week-based calendar
// - SelectedDayHeader: Header showing selected day with add button
// - CalendarLoadingView: Loading view for calendar content
//
// ImagePicker Components:
// - ImagePickerSource: Enum for camera vs photo library
// - ImagePickerView: UIImagePickerController wrapper for SwiftUI
// - ImageCropperView: Image cropping with circular mask for profiles
// - ProfilePhotoPicker: Complete photo picker flow with camera/library/cropping
// - CameraPickerWrapper: Camera-specific picker wrapper
// - CameraViewController: UIKit camera controller wrapper
// - ProfilePhotoPickerModifier: View modifier for photo picker
// - isCameraAvailable(): Check camera availability
// - UIImage.fixedOrientation(): Fix image orientation issues

// MARK: - Services
//
// Media Service:
// - MediaService: Upload/download service for S3 presigned URLs
// - UploadUrlResponse: Response model for upload URL requests
// - MediaService.compressImage(): Image compression helper
// - MediaService.generateImageFileName(): Unique filename generator
//
// Notification Service:
// - NotificationService: Fetch, mark read, and manage notifications
// - AppNotification: Notification model with id, type, title, body, data
// - NotificationType: Enum of all notification types (workout, social, message, etc.)
// - NotificationData: Associated data for notifications (workoutId, userId, etc.)
// - NotificationListResponse: Paginated response for notification list
// - UnreadCountResponse: Response for unread count endpoint

// MARK: - Exercise Preferences
//
// Models:
// - EffortType: Enum for effort tracking types (none, rpe, rir)
// - RecentExercise: Recently used exercise with usage count and score
// - ExerciseScheme: Trainer's most-used exercise configuration
// - SmartDefaults: Smart defaults for exercise based on history
// - TrainerExercisePreferences: Trainer's workout/exercise preferences
// - UpdateTrainerPreferencesRequest: Request to update preferences
// - RecordExerciseUsageRequest: Request to record exercise usage
// - QuickAddExerciseRequest: Request for quick-add exercise creation
//
// Service:
// - ExercisePreferencesService: Favorites, recent, smart defaults, quick-add
//
// UI Components:
// - QuickAddExerciseView: Inline quick-add exercise input
// - QuickAddExerciseRow: List row version of quick-add
// - ExerciseTab: Enum for Recent/Favorites/All tabs
// - ExerciseTabSelector: Horizontal tab selector
// - ExerciseQuickAccessBar: Horizontal scrolling recent/favorites bar
// - ExerciseChip: Compact exercise chip for quick access
// - FavoriteButton: Star button for favoriting exercises
// - WorkoutIntensitySettingsView: Workout-level intensity settings
// - EffortTypePicker: Compact inline effort type picker
// - EffortValueStepper: Stepper for RPE/RIR values
// - SetEditRowEnhanced: Enhanced set row with rep ranges & RPE/RIR
// - SetDisplayCompact: Compact read-only set display
// - SetCountCycler: Tappable set count cycler (2→3→4→5)

// MARK: - Feed Components
//
// Models:
// - FeedResponse: Paginated feed response with items, pageInfo, metadata
// - FeedItem: Individual feed post with author, type, cards, engagement metrics
// - AuthorInfo: Post author with userId, displayName, avatarUrl, isTrainer
// - PostType: Enum for post types (workout, milestone, shoutout, reflection, etc.)
// - PostPerspective: Enum for post perspective (self, coach, system)
// - PostVisibility: Enum for visibility (public, friends, trainerClient, private)
// - PublicCardDto: Minimal card for public viewers
// - FriendsCardDto: Extended card for friends
// - FullCardDto: Full detail card for trainer/client/self views
// - MilestoneCardDto: Milestone celebration card
// - ShoutoutCardDto: Trainer shoutout card
// - ShareableWorkoutDto: Completed workout that can be shared to feed
// - ReactionType: Enum for reactions (like, fire, clap, strong, heart)
// - LikerDto: User who liked a post
//
// UI Components:
// - FeedCardView: Main feed card that renders different card variants
// - FeedCardHeader: Card header with avatar, name, time, more button
// - FeedCardFooter: Card footer with like, comment, congrats actions
// - PublicCardContent: Minimal workout card for public viewers
// - FriendsCardContent: Extended workout card for friends
// - FullCardContent: Full workout card with PRs, trainer notes, caption
// - MilestoneCardContent: Milestone celebration card
// - ShoutoutCardContent: Trainer shoutout card
// - MinimalCardContent: Fallback minimal content
// - ExerciseHighlightRow: Exercise row with PR indicator
// - MetricView: Metric display component

// MARK: - Utilities
// Extensions, helpers, constants
