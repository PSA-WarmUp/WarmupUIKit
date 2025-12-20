//
//  ProfileCard.swift
//  WarmupUIKit
//
//  Reusable profile card component for trainers, coaches, and users
//

import SwiftUI

// MARK: - Profile Displayable Protocol

/// Protocol for any entity that can be displayed in a ProfileCard
public protocol ProfileDisplayable: Identifiable {
    var id: String { get }
    var displayName: String? { get }
    var avatarUrl: String? { get }
    var bio: String? { get }
    var isFollowing: Bool? { get }
}

// MARK: - Profile Card Style

/// Defines the visual style of a profile card
public enum ProfileCardStyle {
    /// Full width list card
    case list
    /// Fixed width spotlight card (for horizontal scroll)
    case spotlight
    /// Compact inline card
    case compact
}

// MARK: - Profile Card

/// A reusable profile card component that displays user/trainer information.
///
/// Usage:
/// ```swift
/// ProfileCard(
///     name: "John Smith",
///     avatarUrl: trainer.avatarUrl,
///     bio: trainer.bio,
///     stats: [.init(icon: "star.fill", value: "4.8")],
///     tags: ["Strength", "HIIT"],
///     isFollowing: false,
///     onFollow: { },
///     onTap: { }
/// )
/// ```
public struct ProfileCard: View {

    // MARK: - Properties

    let name: String
    let avatarUrl: String?
    let bio: String?
    let location: String?
    let stats: [StatsRow.StatData]
    let tags: [String]
    let isFollowing: Bool
    let acceptingClients: Bool
    let style: ProfileCardStyle
    let onFollow: (() -> Void)?
    let onUnfollow: (() -> Void)?
    let onTap: (() -> Void)?

    // MARK: - State

    @State private var isFollowingState: Bool

    // MARK: - Initialization

    public init(
        name: String,
        avatarUrl: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        stats: [StatsRow.StatData] = [],
        tags: [String] = [],
        isFollowing: Bool = false,
        acceptingClients: Bool = false,
        style: ProfileCardStyle = .list,
        onFollow: (() -> Void)? = nil,
        onUnfollow: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.location = location
        self.stats = stats
        self.tags = tags
        self.isFollowing = isFollowing
        self.acceptingClients = acceptingClients
        self.style = style
        self.onFollow = onFollow
        self.onUnfollow = onUnfollow
        self.onTap = onTap
        _isFollowingState = State(initialValue: isFollowing)
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch style {
            case .list:
                listStyleCard
            case .spotlight:
                spotlightStyleCard
            case .compact:
                compactStyleCard
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }

    // MARK: - List Style

    private var listStyleCard: some View {
        HStack(alignment: .top, spacing: DynamicTheme.Spacing.md) {
            // Avatar
            AvatarView(
                url: avatarUrl,
                size: .large,
                badge: acceptingClients ? .accepting : .none
            )

            // Info
            VStack(alignment: .leading, spacing: DynamicTheme.Spacing.xs) {
                // Name
                Text(name)
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.text)
                    .lineLimit(1)

                // Location
                if let location = location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DynamicTheme.Colors.textTertiary)
                        Text(location)
                            .font(DynamicTheme.Typography.caption)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }

                // Stats
                if !stats.isEmpty {
                    StatsRow(stats: stats)
                }

                // Bio
                if let bio = bio {
                    Text(bio)
                        .font(DynamicTheme.Typography.body)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .padding(.top, DynamicTheme.Spacing.xs)
                }

                // Tags
                if !tags.isEmpty {
                    TagsRow(tags: tags, size: .small, maxTags: 3)
                        .padding(.top, DynamicTheme.Spacing.xs)
                }
            }

            Spacer()

            // Follow Button
            if onFollow != nil || onUnfollow != nil {
                followButton
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .fill(DynamicTheme.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.border, lineWidth: 1)
        )
    }

    // MARK: - Spotlight Style

    private var spotlightStyleCard: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.sm) {
            // Avatar centered
            HStack {
                Spacer()
                AvatarView(
                    url: avatarUrl,
                    size: .xlarge,
                    badge: acceptingClients ? .accepting : .none
                )
                Spacer()
            }

            // Name
            Text(name)
                .font(DynamicTheme.Typography.headline)
                .foregroundColor(DynamicTheme.Colors.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            // Location
            if let location = location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                    Text(location)
                        .font(DynamicTheme.Typography.caption)
                }
                .foregroundColor(DynamicTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Bio
            if let bio = bio {
                Text(bio)
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 36)
            }

            // Tags
            if !tags.isEmpty {
                TagsRow(tags: tags, size: .small, maxTags: 2)
            }

            // Stats
            if !stats.isEmpty {
                HStack {
                    Spacer()
                    StatsRow(stats: stats, spacing: 8)
                    Spacer()
                }
            }

            Spacer()

            // Follow Button
            if onFollow != nil || onUnfollow != nil {
                followButtonWide
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .fill(DynamicTheme.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.border, lineWidth: 1)
        )
    }

    // MARK: - Compact Style

    private var compactStyleCard: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            AvatarView(
                url: avatarUrl,
                size: .medium,
                badge: acceptingClients ? .accepting : .none
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(DynamicTheme.Typography.subheadline.weight(.medium))
                    .foregroundColor(DynamicTheme.Colors.text)
                    .lineLimit(1)

                if !stats.isEmpty {
                    StatsRow(stats: stats, spacing: 6)
                }
            }

            Spacer()

            if onFollow != nil || onUnfollow != nil {
                followButtonCompact
            }
        }
        .padding(DynamicTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                .fill(DynamicTheme.Colors.surface)
        )
    }

    // MARK: - Follow Buttons

    private var followButton: some View {
        Button(action: handleFollowAction) {
            if isFollowingState {
                HStack(spacing: DynamicTheme.Spacing.xs) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12))
                    Text("Following")
                        .font(DynamicTheme.Typography.caption)
                }
                .foregroundColor(DynamicTheme.Colors.text)
                .padding(.horizontal, DynamicTheme.Spacing.md)
                .padding(.vertical, DynamicTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                        .fill(DynamicTheme.Colors.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                        .stroke(DynamicTheme.Colors.border, lineWidth: 1)
                )
            } else {
                HStack(spacing: DynamicTheme.Spacing.xs) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 12))
                    Text("Follow")
                        .font(DynamicTheme.Typography.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, DynamicTheme.Spacing.md)
                .padding(.vertical, DynamicTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                        .fill(DynamicTheme.Colors.primary)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var followButtonWide: some View {
        Button(action: handleFollowAction) {
            HStack {
                Spacer()
                if isFollowingState {
                    HStack(spacing: DynamicTheme.Spacing.xs) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
                        Text("Following")
                    }
                    .font(DynamicTheme.Typography.subheadline.weight(.medium))
                    .foregroundColor(DynamicTheme.Colors.text)
                } else {
                    HStack(spacing: DynamicTheme.Spacing.xs) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 12))
                        Text("Follow")
                    }
                    .font(DynamicTheme.Typography.subheadline.weight(.medium))
                    .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.vertical, DynamicTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                    .fill(isFollowingState ? DynamicTheme.Colors.cardBackground : DynamicTheme.Colors.primary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.small)
                    .stroke(isFollowingState ? DynamicTheme.Colors.border : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var followButtonCompact: some View {
        Button(action: handleFollowAction) {
            Image(systemName: isFollowingState ? "checkmark.circle.fill" : "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(isFollowingState ? DynamicTheme.Colors.textSecondary : DynamicTheme.Colors.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Actions

    private func handleFollowAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFollowingState.toggle()
        }

        if isFollowingState {
            onFollow?()
        } else {
            onUnfollow?()
        }
    }
}

// MARK: - Previews

#Preview("Profile Cards") {
    ScrollView {
        VStack(spacing: 20) {
            // List style
            ProfileCard(
                name: "Sarah Johnson",
                bio: "Certified personal trainer specializing in strength training and nutrition coaching",
                location: "San Francisco, CA",
                stats: [
                    .init(icon: "star.fill", value: "4.9", iconColor: .yellow),
                    .init(value: "127", label: "reviews"),
                    .init(value: "8y", label: "exp")
                ],
                tags: ["Strength Training", "Nutrition", "HIIT"],
                acceptingClients: true,
                style: .list,
                onFollow: {},
                onUnfollow: {}
            )

            // Spotlight style
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ProfileCard(
                        name: "Mike Chen",
                        bio: "Former athlete turned coach",
                        location: "New York, NY",
                        stats: [
                            .init(icon: "star.fill", value: "4.8", iconColor: .yellow)
                        ],
                        tags: ["CrossFit", "Olympic Lifting"],
                        isFollowing: true,
                        style: .spotlight,
                        onFollow: {},
                        onUnfollow: {}
                    )

                    ProfileCard(
                        name: "Emma Wilson",
                        bio: "Yoga and mindfulness expert",
                        location: "Austin, TX",
                        stats: [
                            .init(icon: "star.fill", value: "5.0", iconColor: .yellow)
                        ],
                        tags: ["Yoga", "Meditation"],
                        acceptingClients: true,
                        style: .spotlight,
                        onFollow: {},
                        onUnfollow: {}
                    )
                }
            }

            // Compact style
            VStack(spacing: 8) {
                ProfileCard(
                    name: "Quick Add Trainer",
                    stats: [.init(icon: "star.fill", value: "4.7", iconColor: .yellow)],
                    style: .compact,
                    onFollow: {}
                )

                ProfileCard(
                    name: "Another Trainer",
                    stats: [.init(icon: "star.fill", value: "4.5", iconColor: .yellow)],
                    isFollowing: true,
                    style: .compact,
                    onFollow: {},
                    onUnfollow: {}
                )
            }
        }
        .padding()
    }
}
