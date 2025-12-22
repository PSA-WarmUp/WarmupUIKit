//
//  FollowButton.swift
//  WarmupUIKit
//
//  Reusable follow button with multiple states
//

import SwiftUI

/// A button that displays follow state and handles follow/unfollow actions
public struct FollowButton: View {
    public let status: FollowButtonStatus
    public let action: () -> Void

    public init(status: FollowButtonStatus, action: @escaping () -> Void) {
        self.status = status
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                switch status {
                case .notFollowing:
                    Text("Follow")
                        .foregroundColor(.white)
                        .padding(.horizontal, DynamicTheme.Spacing.md)
                        .padding(.vertical, DynamicTheme.Spacing.xs)
                        .background(DynamicTheme.Colors.primary)
                        .cornerRadius(DynamicTheme.Radius.round)

                case .following:
                    Text("Following")
                        .foregroundColor(DynamicTheme.Colors.primary)
                        .padding(.horizontal, DynamicTheme.Spacing.md)
                        .padding(.vertical, DynamicTheme.Spacing.xs)
                        .background(DynamicTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(DynamicTheme.Radius.round)

                case .pending:
                    Text("Requested")
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                        .padding(.horizontal, DynamicTheme.Spacing.md)
                        .padding(.vertical, DynamicTheme.Spacing.xs)
                        .background(DynamicTheme.Colors.bubbleBackground)
                        .cornerRadius(DynamicTheme.Radius.round)

                case .mutual:
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                        Text("Friends")
                    }
                    .foregroundColor(DynamicTheme.Colors.success)
                    .padding(.horizontal, DynamicTheme.Spacing.md)
                    .padding(.vertical, DynamicTheme.Spacing.xs)
                    .background(DynamicTheme.Colors.success.opacity(0.1))
                    .cornerRadius(DynamicTheme.Radius.round)

                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DynamicTheme.Colors.primary))
                        .frame(width: 60)
                }
            }
            .font(DynamicTheme.Typography.subheadline)
        }
        .disabled(status == .loading)
    }
}

// MARK: - Compact Follow Button Variant
/// A more compact follow button for tight spaces
public struct CompactFollowButton: View {
    public let status: FollowButtonStatus
    public let action: () -> Void

    public init(status: FollowButtonStatus, action: @escaping () -> Void) {
        self.status = status
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                switch status {
                case .notFollowing:
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(DynamicTheme.Colors.primary)
                        .clipShape(Circle())

                case .following:
                    Image(systemName: "checkmark")
                        .foregroundColor(DynamicTheme.Colors.primary)
                        .frame(width: 28, height: 28)
                        .background(DynamicTheme.Colors.primary.opacity(0.1))
                        .clipShape(Circle())

                case .pending:
                    Image(systemName: "clock")
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(DynamicTheme.Colors.bubbleBackground)
                        .clipShape(Circle())

                case .mutual:
                    Image(systemName: "person.2.fill")
                        .foregroundColor(DynamicTheme.Colors.success)
                        .frame(width: 28, height: 28)
                        .background(DynamicTheme.Colors.success.opacity(0.1))
                        .clipShape(Circle())

                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DynamicTheme.Colors.primary))
                        .frame(width: 28, height: 28)
                }
            }
            .font(.system(size: 12, weight: .semibold))
        }
        .disabled(status == .loading)
    }
}

// MARK: - Preview
#if DEBUG
struct FollowButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Follow Button States")
                .font(DynamicTheme.Typography.headline)

            FollowButton(status: .notFollowing) {}
            FollowButton(status: .pending) {}
            FollowButton(status: .following) {}
            FollowButton(status: .mutual) {}
            FollowButton(status: .loading) {}

            Divider()

            Text("Compact Variants")
                .font(DynamicTheme.Typography.headline)

            HStack(spacing: 16) {
                CompactFollowButton(status: .notFollowing) {}
                CompactFollowButton(status: .pending) {}
                CompactFollowButton(status: .following) {}
                CompactFollowButton(status: .mutual) {}
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
