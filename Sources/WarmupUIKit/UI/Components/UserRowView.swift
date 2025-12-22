//
//  UserRowView.swift
//  WarmupUIKit
//
//  Reusable user row component for displaying users in lists
//

import SwiftUI

/// A row view displaying a user with avatar, name, badges, and optional follow button
public struct UserRowView: View {
    public let user: UserSummary
    public let followStatus: FollowButtonStatus
    public let showFollowButton: Bool
    public let onFollowTap: (() -> Void)?
    public let onTap: (() -> Void)?

    public init(
        user: UserSummary,
        followStatus: FollowButtonStatus = .notFollowing,
        showFollowButton: Bool = true,
        onFollowTap: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.user = user
        self.followStatus = followStatus
        self.showFollowButton = showFollowButton
        self.onFollowTap = onFollowTap
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            // Avatar
            avatarView

            // User info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(user.displayName)
                        .font(DynamicTheme.Typography.headline)
                        .foregroundColor(DynamicTheme.Colors.text)

                    if user.isTrainer == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    }
                }

                subtitleText
            }

            Spacer()

            // Follow button
            if showFollowButton, let onFollowTap = onFollowTap {
                FollowButton(status: followStatus, action: onFollowTap)
            }
        }
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.vertical, DynamicTheme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }

    // MARK: - Avatar View
    @ViewBuilder
    private var avatarView: some View {
        if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                avatarPlaceholder
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
        } else {
            avatarPlaceholder
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(DynamicTheme.Colors.primary.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay(
                Text(String(user.displayName.prefix(1)).uppercased())
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.primary)
            )
    }

    // MARK: - Subtitle
    @ViewBuilder
    private var subtitleText: some View {
        if user.isMutualFollow {
            Text("Follows you")
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        } else if user.isTrainer == true {
            Text("Trainer")
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        } else if user.isFollower == true {
            Text("Follows you")
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Compact User Row
/// A more compact user row for tight spaces (e.g., mentions, search results)
public struct CompactUserRowView: View {
    public let user: UserSummary
    public let onTap: (() -> Void)?

    public init(user: UserSummary, onTap: (() -> Void)? = nil) {
        self.user = user
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            // Avatar
            if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            // Name with badge
            HStack(spacing: 4) {
                Text(user.displayName)
                    .font(DynamicTheme.Typography.subheadline)
                    .foregroundColor(DynamicTheme.Colors.text)

                if user.isTrainer == true {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                        .foregroundColor(DynamicTheme.Colors.primary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, DynamicTheme.Spacing.sm)
        .padding(.vertical, DynamicTheme.Spacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(DynamicTheme.Colors.primary.opacity(0.2))
            .frame(width: 36, height: 36)
            .overlay(
                Text(String(user.displayName.prefix(1)).uppercased())
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.primary)
            )
    }
}

// MARK: - Preview
#if DEBUG
struct UserRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            UserRowView(
                user: UserSummary(
                    userId: "1",
                    displayName: "John Doe",
                    isTrainer: true,
                    isFollowing: false
                ),
                followStatus: .notFollowing,
                onFollowTap: {}
            )

            Divider()

            UserRowView(
                user: UserSummary(
                    userId: "2",
                    displayName: "Jane Smith",
                    isTrainer: false,
                    isFollower: true
                ),
                followStatus: .following,
                onFollowTap: {}
            )

            Divider()

            UserRowView(
                user: UserSummary(
                    userId: "3",
                    displayName: "Mike Johnson",
                    isTrainer: true,
                    isFollowing: true,
                    isFollower: true
                ),
                followStatus: .mutual,
                onFollowTap: {}
            )

            Divider()

            Text("Compact Variant")
                .font(DynamicTheme.Typography.caption)
                .padding(.top)

            CompactUserRowView(
                user: UserSummary(
                    userId: "4",
                    displayName: "Compact User",
                    isTrainer: true
                )
            )
        }
        .background(DynamicTheme.Colors.background)
        .previewLayout(.sizeThatFits)
    }
}
#endif
