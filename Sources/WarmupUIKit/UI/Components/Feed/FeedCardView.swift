//
//  FeedCardView.swift
//  WarmupUIKit
//
//  Main feed card component that renders different card variants
//  Shared between trainer and client apps
//

import SwiftUI

public struct FeedCardView: View {
    public let post: FeedItem
    public let onLike: () -> Void
    public let onComment: () -> Void
    public let onMore: () -> Void
    public let onTap: () -> Void
    public var onCongrats: (() -> Void)? = nil

    public init(
        post: FeedItem,
        onLike: @escaping () -> Void,
        onComment: @escaping () -> Void,
        onMore: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onCongrats: (() -> Void)? = nil
    ) {
        self.post = post
        self.onLike = onLike
        self.onComment = onComment
        self.onMore = onMore
        self.onTap = onTap
        self.onCongrats = onCongrats
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                FeedCardHeader(post: post, onMore: onMore)

                // Content - varies by post type
                cardContent

                // Footer with actions
                FeedCardFooter(
                    post: post,
                    onLike: onLike,
                    onComment: onComment,
                    onCongrats: onCongrats
                )
            }
            .background(DynamicTheme.Colors.cardBackground)
            .cornerRadius(DynamicTheme.Radius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var cardContent: some View {
        switch post.postType {
        case .milestone:
            MilestoneCardContent(post: post)
        case .trainerShoutout:
            ShoutoutCardContent(post: post)
        default:
            // Workout summary, weekly summary, and other types
            // Use effectiveFullCard which synthesizes from top-level fields if needed
            if let fullCard = post.effectiveFullCard {
                FullCardContent(post: post, card: fullCard)
            } else if let friendsCard = post.friendsCard {
                FriendsCardContent(post: post, card: friendsCard)
            } else if let publicCard = post.publicCard {
                PublicCardContent(post: post, card: publicCard)
            } else {
                // Fallback minimal content
                MinimalCardContent(post: post)
            }
        }
    }
}

// MARK: - Card Header
public struct FeedCardHeader: View {
    public let post: FeedItem
    public let onMore: () -> Void

    public init(post: FeedItem, onMore: @escaping () -> Void) {
        self.post = post
        self.onMore = onMore
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            // Avatar
            if let avatarUrl = post.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            // Name and time
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(post.displayName)
                        .font(DynamicTheme.Typography.headline)
                        .foregroundColor(DynamicTheme.Colors.text)

                    if post.author?.isTrainer == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    }
                }

                Text(post.timeAgo)
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }

            Spacer()

            // More button
            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(DynamicTheme.Spacing.md)
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(DynamicTheme.Colors.bubbleBackground)
            .frame(width: 40, height: 40)
            .overlay(
                Text(String(post.displayName.prefix(1)).uppercased())
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            )
    }
}

// MARK: - Card Footer
public struct FeedCardFooter: View {
    public let post: FeedItem
    public let onLike: () -> Void
    public let onComment: () -> Void
    public var onCongrats: (() -> Void)? = nil

    public init(post: FeedItem, onLike: @escaping () -> Void, onComment: @escaping () -> Void, onCongrats: (() -> Void)? = nil) {
        self.post = post
        self.onLike = onLike
        self.onComment = onComment
        self.onCongrats = onCongrats
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.sm) {
            // Engagement text
            if post.likes > 0 || post.comments > 0 {
                HStack(spacing: DynamicTheme.Spacing.md) {
                    if post.likes > 0 {
                        Text("\(post.likes) \(post.likes == 1 ? "like" : "likes")")
                            .font(DynamicTheme.Typography.caption)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                    }
                    if post.comments > 0 {
                        Text("\(post.comments) \(post.comments == 1 ? "comment" : "comments")")
                            .font(DynamicTheme.Typography.caption)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, DynamicTheme.Spacing.md)
            } else {
                Text("Be the first to like this")
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textTertiary)
                    .padding(.horizontal, DynamicTheme.Spacing.md)
            }

            Divider()
                .background(DynamicTheme.Colors.border)

            // Action buttons
            HStack(spacing: 0) {
                // Like button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.hasLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(post.hasLiked ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)

                        Text("Like")
                            .font(DynamicTheme.Typography.subheadline)
                            .foregroundColor(post.hasLiked ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DynamicTheme.Spacing.sm)
                }

                // Comment button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                            .foregroundColor(DynamicTheme.Colors.textSecondary)

                        Text("Comment")
                            .font(DynamicTheme.Typography.subheadline)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DynamicTheme.Spacing.sm)
                }

                // Congrats button (for milestones)
                if let onCongrats = onCongrats, post.postType == .milestone {
                    Button(action: onCongrats) {
                        HStack(spacing: 6) {
                            Image(systemName: "hands.clap.fill")
                                .font(.system(size: 18))
                                .foregroundColor(DynamicTheme.Colors.warning)

                            Text("Congrats")
                                .font(DynamicTheme.Typography.subheadline)
                                .foregroundColor(DynamicTheme.Colors.warning)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DynamicTheme.Spacing.sm)
                    }
                }
            }
            .padding(.horizontal, DynamicTheme.Spacing.sm)
        }
        .padding(.bottom, DynamicTheme.Spacing.sm)
    }
}

// MARK: - Milestone Card Content
public struct MilestoneCardContent: View {
    public let post: FeedItem

    public init(post: FeedItem) {
        self.post = post
    }

    public var body: some View {
        VStack(spacing: DynamicTheme.Spacing.md) {
            if let milestone = post.milestone {
                // Icon
                Circle()
                    .fill(DynamicTheme.Colors.warning.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: milestone.iconName)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(DynamicTheme.Colors.warning)
                    )

                // Title
                if let title = milestone.title {
                    Text(title)
                        .font(DynamicTheme.Typography.title2)
                        .foregroundColor(DynamicTheme.Colors.text)
                        .multilineTextAlignment(.center)
                }

                // Subtitle
                if let subtitle = milestone.subtitle {
                    Text(subtitle)
                        .font(DynamicTheme.Typography.body)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DynamicTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [DynamicTheme.Colors.warning.opacity(0.1), DynamicTheme.Colors.warning.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Shoutout Card Content
public struct ShoutoutCardContent: View {
    public let post: FeedItem

    public init(post: FeedItem) {
        self.post = post
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.md) {
            if let shoutout = post.shoutout {
                // Client being highlighted
                if let clientName = shoutout.clientName {
                    HStack(spacing: DynamicTheme.Spacing.sm) {
                        // Client avatar
                        if let avatarUrl = shoutout.clientAvatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(DynamicTheme.Colors.bubbleBackground)
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(DynamicTheme.Colors.primary.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(String(clientName.prefix(1)).uppercased())
                                        .font(DynamicTheme.Typography.headline)
                                        .foregroundColor(DynamicTheme.Colors.primary)
                                )
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shoutout to")
                                .font(DynamicTheme.Typography.caption)
                                .foregroundColor(DynamicTheme.Colors.textSecondary)

                            Text(clientName)
                                .font(DynamicTheme.Typography.title3)
                                .foregroundColor(DynamicTheme.Colors.text)
                        }

                        Spacer()

                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    }
                }

                // Message
                if let message = shoutout.message {
                    Text(message)
                        .font(DynamicTheme.Typography.body)
                        .foregroundColor(DynamicTheme.Colors.text)
                        .padding(DynamicTheme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DynamicTheme.Colors.primaryBackground)
                        .cornerRadius(DynamicTheme.Radius.small)
                }

                // Achievements
                if let achievements = shoutout.achievements, !achievements.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DynamicTheme.Spacing.sm) {
                            ForEach(achievements, id: \.self) { achievement in
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                    Text(achievement)
                                        .font(DynamicTheme.Typography.caption)
                                }
                                .foregroundColor(DynamicTheme.Colors.warning)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(DynamicTheme.Colors.warning.opacity(0.1))
                                .cornerRadius(DynamicTheme.Radius.round)
                            }
                        }
                    }
                }
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.bubbleBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.bottom, DynamicTheme.Spacing.md)
    }
}
