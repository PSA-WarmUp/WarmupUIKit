//
//  DeletedMessageBubble.swift
//  WarmupUIKit
//
//  Placeholder view for deleted messages
//

import SwiftUI

// MARK: - Deleted Message Bubble

/// A placeholder view displayed when a message has been deleted.
/// Shows "This message was deleted" text with muted styling.
/// Positioned based on sender alignment (left/right).
///
/// Usage:
/// ```swift
/// DeletedMessageBubble(isFromCurrentUser: true)
/// DeletedMessageBubble(isFromCurrentUser: false)
/// ```
public struct DeletedMessageBubble: View {

    // MARK: - Properties

    let isFromCurrentUser: Bool
    let maxWidthRatio: CGFloat

    // MARK: - Initialization

    public init(
        isFromCurrentUser: Bool,
        maxWidthRatio: CGFloat = 0.75
    ) {
        self.isFromCurrentUser = isFromCurrentUser
        self.maxWidthRatio = maxWidthRatio
    }

    // MARK: - Body

    public var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: UIScreen.main.bounds.width * (1 - maxWidthRatio))
            }

            deletedContent

            if !isFromCurrentUser {
                Spacer(minLength: UIScreen.main.bounds.width * (1 - maxWidthRatio))
            }
        }
        .padding(.horizontal, DynamicTheme.Spacing.md)
    }

    // MARK: - Subviews

    private var deletedContent: some View {
        HStack(spacing: DynamicTheme.Spacing.xs) {
            Image(systemName: "nosign")
                .font(.system(size: 12))

            Text("This message was deleted")
                .font(DynamicTheme.Typography.caption)
                .italic()
        }
        .foregroundColor(DynamicTheme.Colors.textTertiary)
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.vertical, DynamicTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .fill(DynamicTheme.Colors.bubbleBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                        .stroke(DynamicTheme.Colors.border.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Compact Deleted Message

/// A more compact version for use in conversation previews or lists
public struct CompactDeletedMessageText: View {

    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "nosign")
                .font(.system(size: 10))
            Text("This message was deleted")
                .font(DynamicTheme.Typography.caption)
                .italic()
        }
        .foregroundColor(DynamicTheme.Colors.textTertiary)
    }
}

// MARK: - Previews

#Preview("Deleted Message Bubbles") {
    VStack(spacing: 16) {
        Text("Sent by current user (right)")
            .font(.caption)
            .foregroundColor(.secondary)
        DeletedMessageBubble(isFromCurrentUser: true)

        Divider()

        Text("Sent by other user (left)")
            .font(.caption)
            .foregroundColor(.secondary)
        DeletedMessageBubble(isFromCurrentUser: false)

        Divider()

        Text("Compact version (for previews)")
            .font(.caption)
            .foregroundColor(.secondary)
        CompactDeletedMessageText()
    }
    .padding()
}
