//
//  FollowRequestCard.swift
//  WarmupUIKit
//
//  Card component for displaying follow requests with accept/decline actions
//

import SwiftUI

/// A card view for displaying follow requests in DMs or notifications
public struct FollowRequestCard: View {
    public let followRequest: FollowRequestContent
    public let isOwnMessage: Bool
    public let onAccept: () -> Void
    public let onDecline: () -> Void

    @State private var isProcessing = false

    public init(
        followRequest: FollowRequestContent,
        isOwnMessage: Bool = false,
        onAccept: @escaping () -> Void,
        onDecline: @escaping () -> Void
    ) {
        self.followRequest = followRequest
        self.isOwnMessage = isOwnMessage
        self.onAccept = onAccept
        self.onDecline = onDecline
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DynamicTheme.Spacing.md) {
            // Header with avatar and name
            HStack(spacing: DynamicTheme.Spacing.sm) {
                // Avatar
                avatarView

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(followRequest.requesterName)
                            .font(DynamicTheme.Typography.headline)
                            .foregroundColor(DynamicTheme.Colors.text)

                        if followRequest.requesterIsTrainer == true {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DynamicTheme.Colors.primary)
                        }
                    }

                    Text("wants to follow you")
                        .font(DynamicTheme.Typography.caption)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                }

                Spacer()
            }

            // Status or action buttons
            if followRequest.status == .pending && !isOwnMessage {
                // Show accept/decline buttons for pending requests (only for recipient)
                actionButtons
            } else {
                // Show status badge for non-pending states or for sender's view
                HStack {
                    Spacer()
                    statusBadge
                    Spacer()
                }
            }
        }
        .padding(DynamicTheme.Spacing.md)
        .background(DynamicTheme.Colors.cardBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Avatar
    @ViewBuilder
    private var avatarView: some View {
        if let avatarUrl = followRequest.requesterAvatarUrl, let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                avatarPlaceholder
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        } else {
            avatarPlaceholder
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(DynamicTheme.Colors.primary.opacity(0.2))
            .frame(width: 44, height: 44)
            .overlay(
                Text(String(followRequest.requesterName.prefix(1)).uppercased())
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.primary)
            )
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            Button(action: {
                isProcessing = true
                onAccept()
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark")
                    }
                    Text("Accept")
                }
                .font(DynamicTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DynamicTheme.Spacing.sm)
                .background(DynamicTheme.Colors.success)
                .cornerRadius(DynamicTheme.Radius.medium)
            }
            .disabled(isProcessing)

            Button(action: {
                isProcessing = true
                onDecline()
            }) {
                HStack {
                    Image(systemName: "xmark")
                    Text("Decline")
                }
                .font(DynamicTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DynamicTheme.Colors.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DynamicTheme.Spacing.sm)
                .background(DynamicTheme.Colors.bubbleBackground)
                .cornerRadius(DynamicTheme.Radius.medium)
            }
            .disabled(isProcessing)
        }
    }

    // MARK: - Status Badge
    @ViewBuilder
    private var statusBadge: some View {
        switch followRequest.status {
        case .pending:
            StatusBadge(
                text: "Pending",
                icon: "clock",
                style: .warning
            )

        case .accepted:
            StatusBadge(
                text: "Accepted",
                icon: "checkmark.circle.fill",
                style: .success
            )

        case .declined:
            StatusBadge(
                text: "Declined",
                icon: "xmark.circle.fill",
                style: .error
            )
        }
    }
}

// MARK: - Status Badge Component
/// A reusable badge for displaying status with icon and text
public struct StatusBadge: View {
    public let text: String
    public let icon: String?
    public let style: BadgeStyle

    public enum BadgeStyle {
        case neutral
        case info
        case warning
        case success
        case error
        case custom(foreground: Color, background: Color)

        var foregroundColor: Color {
            switch self {
            case .neutral: return DynamicTheme.Colors.textSecondary
            case .info: return DynamicTheme.Colors.info
            case .warning: return DynamicTheme.Colors.warning
            case .success: return DynamicTheme.Colors.success
            case .error: return DynamicTheme.Colors.error
            case .custom(let foreground, _): return foreground
            }
        }

        var backgroundColor: Color {
            switch self {
            case .neutral: return DynamicTheme.Colors.bubbleBackground
            case .info: return DynamicTheme.Colors.info.opacity(0.1)
            case .warning: return DynamicTheme.Colors.warning.opacity(0.1)
            case .success: return DynamicTheme.Colors.success.opacity(0.1)
            case .error: return DynamicTheme.Colors.error.opacity(0.1)
            case .custom(_, let background): return background
            }
        }
    }

    public init(text: String, icon: String? = nil, style: BadgeStyle = .neutral) {
        self.text = text
        self.icon = icon
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(DynamicTheme.Typography.caption)
        .foregroundColor(style.foregroundColor)
        .padding(.horizontal, DynamicTheme.Spacing.sm)
        .padding(.vertical, DynamicTheme.Spacing.xs)
        .background(style.backgroundColor)
        .cornerRadius(DynamicTheme.Radius.round)
    }
}

// MARK: - Preview
#if DEBUG
struct FollowRequestCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Pending - Actionable")
                .font(DynamicTheme.Typography.caption)

            FollowRequestCard(
                followRequest: FollowRequestContent(
                    followId: "1",
                    requesterId: "user1",
                    requesterName: "John Doe",
                    requesterIsTrainer: true,
                    status: .pending
                ),
                isOwnMessage: false,
                onAccept: {},
                onDecline: {}
            )

            Text("Pending - Sender View")
                .font(DynamicTheme.Typography.caption)

            FollowRequestCard(
                followRequest: FollowRequestContent(
                    followId: "2",
                    requesterId: "user2",
                    requesterName: "Jane Smith",
                    status: .pending
                ),
                isOwnMessage: true,
                onAccept: {},
                onDecline: {}
            )

            Text("Accepted")
                .font(DynamicTheme.Typography.caption)

            FollowRequestCard(
                followRequest: FollowRequestContent(
                    followId: "3",
                    requesterId: "user3",
                    requesterName: "Mike Johnson",
                    requesterIsTrainer: true,
                    status: .accepted
                ),
                onAccept: {},
                onDecline: {}
            )

            Text("Declined")
                .font(DynamicTheme.Typography.caption)

            FollowRequestCard(
                followRequest: FollowRequestContent(
                    followId: "4",
                    requesterId: "user4",
                    requesterName: "Sarah Wilson",
                    status: .declined
                ),
                onAccept: {},
                onDecline: {}
            )
        }
        .padding()
        .background(DynamicTheme.Colors.background)
        .previewLayout(.sizeThatFits)
    }
}
#endif
