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

// MARK: - Utilities
// Extensions, helpers, constants
