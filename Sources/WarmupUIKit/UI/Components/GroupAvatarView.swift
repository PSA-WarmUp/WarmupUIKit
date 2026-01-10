//
//  GroupAvatarView.swift
//  WarmupUIKit
//
//  Reusable group avatar component with stacked avatars or initials fallback
//

import SwiftUI

// MARK: - Group Avatar View

/// A reusable avatar component specifically for group conversations.
/// Displays a custom avatar image, stacked participant avatars, or initials fallback.
///
/// Usage:
/// ```swift
/// GroupAvatarView(title: "Fitness Squad", avatarUrl: nil, size: .large)
/// GroupAvatarView(title: "Team A", participantAvatars: avatarUrls, size: .medium)
/// ```
public struct GroupAvatarView: View {

    // MARK: - Properties

    let title: String?
    let avatarUrl: String?
    let participantAvatars: [String?]?
    let size: AvatarSize
    let showStackedAvatars: Bool
    let backgroundColor: Color

    // MARK: - Initialization

    public init(
        title: String?,
        avatarUrl: String? = nil,
        participantAvatars: [String?]? = nil,
        size: AvatarSize = .medium,
        showStackedAvatars: Bool = true,
        backgroundColor: Color = DynamicTheme.Colors.primary
    ) {
        self.title = title
        self.avatarUrl = avatarUrl
        self.participantAvatars = participantAvatars
        self.size = size
        self.showStackedAvatars = showStackedAvatars
        self.backgroundColor = backgroundColor
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if let avatarUrl = avatarUrl, let url = URL(string: avatarUrl) {
                // Custom group avatar image
                customAvatarImage(url: url)
            } else if showStackedAvatars,
                      let avatars = participantAvatars,
                      avatars.count >= 2 {
                // Stacked participant avatars
                stackedAvatarsView(avatars: avatars)
            } else {
                // Initials fallback
                initialsView
            }
        }
    }

    // MARK: - Subviews

    private func customAvatarImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                initialsView
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                initialsView
            @unknown default:
                initialsView
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
    }

    private func stackedAvatarsView(avatars: [String?]) -> some View {
        let displayAvatars = Array(avatars.prefix(4))
        let miniSize = size.rawValue * 0.55
        let offset = size.rawValue * 0.25

        return ZStack {
            // Background circle
            Circle()
                .fill(DynamicTheme.Colors.cardBackground)
                .frame(width: size.rawValue, height: size.rawValue)

            // Stacked mini avatars in 2x2 grid pattern
            if displayAvatars.count >= 4 {
                fourAvatarGrid(avatars: displayAvatars, miniSize: miniSize, offset: offset)
            } else if displayAvatars.count == 3 {
                threeAvatarLayout(avatars: displayAvatars, miniSize: miniSize, offset: offset)
            } else {
                twoAvatarLayout(avatars: displayAvatars, miniSize: miniSize, offset: offset)
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(DynamicTheme.Colors.border, lineWidth: 1)
        )
    }

    private func fourAvatarGrid(avatars: [String?], miniSize: CGFloat, offset: CGFloat) -> some View {
        let smallOffset = offset * 0.6
        return ZStack {
            miniAvatar(url: avatars[0], size: miniSize)
                .offset(x: -smallOffset, y: -smallOffset)
            miniAvatar(url: avatars[1], size: miniSize)
                .offset(x: smallOffset, y: -smallOffset)
            miniAvatar(url: avatars[2], size: miniSize)
                .offset(x: -smallOffset, y: smallOffset)
            miniAvatar(url: avatars[3], size: miniSize)
                .offset(x: smallOffset, y: smallOffset)
        }
    }

    private func threeAvatarLayout(avatars: [String?], miniSize: CGFloat, offset: CGFloat) -> some View {
        let smallOffset = offset * 0.6
        return ZStack {
            miniAvatar(url: avatars[0], size: miniSize)
                .offset(x: 0, y: -smallOffset)
            miniAvatar(url: avatars[1], size: miniSize)
                .offset(x: -smallOffset, y: smallOffset)
            miniAvatar(url: avatars[2], size: miniSize)
                .offset(x: smallOffset, y: smallOffset)
        }
    }

    private func twoAvatarLayout(avatars: [String?], miniSize: CGFloat, offset: CGFloat) -> some View {
        let smallOffset = offset * 0.5
        return ZStack {
            miniAvatar(url: avatars[0], size: miniSize * 1.1)
                .offset(x: -smallOffset, y: 0)
            miniAvatar(url: avatars[safe: 1] ?? nil, size: miniSize * 1.1)
                .offset(x: smallOffset, y: 0)
        }
    }

    private func miniAvatar(url: String?, size: CGFloat) -> some View {
        Group {
            if let urlString = url, let imageUrl = URL(string: urlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Circle()
                            .fill(DynamicTheme.Colors.bubbleBackground)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: size * 0.4))
                                    .foregroundColor(DynamicTheme.Colors.textTertiary)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(DynamicTheme.Colors.bubbleBackground)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundColor(DynamicTheme.Colors.textTertiary)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(DynamicTheme.Colors.surface, lineWidth: 1)
        )
    }

    private var initialsView: some View {
        Circle()
            .fill(backgroundColor.opacity(0.2))
            .frame(width: size.rawValue, height: size.rawValue)
            .overlay(
                Group {
                    if let title = title, !title.isEmpty {
                        Text(groupInitials)
                            .font(.system(size: size.rawValue * 0.4, weight: .semibold))
                            .foregroundColor(backgroundColor)
                    } else {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: size.iconSize))
                            .foregroundColor(backgroundColor)
                    }
                }
            )
    }

    // MARK: - Helpers

    private var groupInitials: String {
        guard let title = title, !title.isEmpty else { return "G" }
        let words = title.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(title.prefix(2)).uppercased()
    }
}

// MARK: - Array Extension

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Previews

#Preview("Group Avatar Styles") {
    VStack(spacing: 24) {
        HStack(spacing: 20) {
            VStack {
                GroupAvatarView(title: "Fitness Squad", size: .large)
                Text("Initials").font(.caption)
            }

            VStack {
                GroupAvatarView(
                    title: "Team",
                    participantAvatars: [nil, nil, nil, nil],
                    size: .large
                )
                Text("4 Avatars").font(.caption)
            }

            VStack {
                GroupAvatarView(
                    title: "Duo",
                    participantAvatars: [nil, nil],
                    size: .large
                )
                Text("2 Avatars").font(.caption)
            }
        }

        HStack(spacing: 16) {
            GroupAvatarView(title: "A", size: .small)
            GroupAvatarView(title: "BC", size: .medium)
            GroupAvatarView(title: "DEF", size: .large)
            GroupAvatarView(title: "GHIJ", size: .xlarge)
        }
    }
    .padding()
}
