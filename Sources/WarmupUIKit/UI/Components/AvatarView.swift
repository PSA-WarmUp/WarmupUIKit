//
//  AvatarView.swift
//  WarmupUIKit
//
//  Reusable avatar component with optional status badge
//

import SwiftUI

// MARK: - Avatar Size

/// Predefined avatar sizes for consistent UI
public enum AvatarSize: CGFloat {
    case small = 32
    case medium = 48
    case large = 64
    case xlarge = 80
    case xxlarge = 120

    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 20
        case .large: return 24
        case .xlarge: return 32
        case .xxlarge: return 48
        }
    }

    var badgeSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 16
        case .xlarge: return 20
        case .xxlarge: return 24
        }
    }

    var badgeIconSize: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 7
        case .large: return 8
        case .xlarge: return 10
        case .xxlarge: return 12
        }
    }
}

// MARK: - Avatar Badge

/// Badge types that can be displayed on an avatar
public enum AvatarBadge {
    case none
    case online
    case offline
    case verified
    case accepting // Accepting new clients
    case custom(color: Color, icon: String?)

    var isVisible: Bool {
        if case .none = self { return false }
        return true
    }

    var color: Color {
        switch self {
        case .none: return .clear
        case .online: return DynamicTheme.Colors.success
        case .offline: return DynamicTheme.Colors.textTertiary
        case .verified: return DynamicTheme.Colors.primary
        case .accepting: return DynamicTheme.Colors.success
        case .custom(let color, _): return color
        }
    }

    var icon: String? {
        switch self {
        case .none, .online, .offline: return nil
        case .verified: return "checkmark.seal.fill"
        case .accepting: return "checkmark"
        case .custom(_, let icon): return icon
        }
    }
}

// MARK: - Avatar View

/// A reusable avatar component that displays a user's profile image with optional badge.
///
/// Usage:
/// ```swift
/// AvatarView(url: user.avatarUrl, size: .large)
/// AvatarView(url: trainer.avatarUrl, size: .medium, badge: .accepting)
/// AvatarView(initials: "JD", size: .small)
/// ```
public struct AvatarView: View {

    // MARK: - Properties

    let url: String?
    let initials: String?
    let size: AvatarSize
    let badge: AvatarBadge
    let placeholderIcon: String
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat

    // MARK: - Initialization

    /// Creates an avatar view with a URL
    public init(
        url: String?,
        size: AvatarSize = .medium,
        badge: AvatarBadge = .none,
        placeholderIcon: String = "person.fill",
        backgroundColor: Color = DynamicTheme.Colors.cardBackground,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.url = url
        self.initials = nil
        self.size = size
        self.badge = badge
        self.placeholderIcon = placeholderIcon
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    /// Creates an avatar view with initials
    public init(
        initials: String,
        size: AvatarSize = .medium,
        badge: AvatarBadge = .none,
        backgroundColor: Color = DynamicTheme.Colors.primary,
        textColor: Color = .white,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.url = nil
        self.initials = initials
        self.size = size
        self.badge = badge
        self.placeholderIcon = "person.fill"
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent

            if badge.isVisible {
                badgeView
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var avatarContent: some View {
        if let urlString = url, let imageUrl = URL(string: urlString) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
            .frame(width: size.rawValue, height: size.rawValue)
            .clipShape(Circle())
            .overlay(borderOverlay)
        } else if let initials = initials {
            initialsView(initials)
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size.rawValue, height: size.rawValue)
            .overlay(
                Image(systemName: placeholderIcon)
                    .font(.system(size: size.iconSize))
                    .foregroundColor(DynamicTheme.Colors.textTertiary)
            )
            .overlay(borderOverlay)
    }

    private func initialsView(_ initials: String) -> some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size.rawValue, height: size.rawValue)
            .overlay(
                Text(initials.prefix(2).uppercased())
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundColor(.white)
            )
            .overlay(borderOverlay)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let borderColor = borderColor, borderWidth > 0 {
            Circle()
                .stroke(borderColor, lineWidth: borderWidth)
        }
    }

    private var badgeView: some View {
        ZStack {
            Circle()
                .fill(badge.color)
                .frame(width: size.badgeSize, height: size.badgeSize)

            if let icon = badge.icon {
                Image(systemName: icon)
                    .font(.system(size: size.badgeIconSize, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .overlay(
            Circle()
                .stroke(DynamicTheme.Colors.surface, lineWidth: 2)
        )
    }
}

// MARK: - Avatar Group

/// Displays a horizontal stack of overlapping avatars
public struct AvatarGroup: View {

    let urls: [String?]
    let size: AvatarSize
    let maxDisplay: Int
    let overlapOffset: CGFloat

    public init(
        urls: [String?],
        size: AvatarSize = .small,
        maxDisplay: Int = 4,
        overlapOffset: CGFloat? = nil
    ) {
        self.urls = urls
        self.size = size
        self.maxDisplay = maxDisplay
        self.overlapOffset = overlapOffset ?? (size.rawValue * 0.3)
    }

    public var body: some View {
        HStack(spacing: -overlapOffset) {
            ForEach(Array(urls.prefix(maxDisplay).enumerated()), id: \.offset) { index, url in
                AvatarView(
                    url: url,
                    size: size,
                    borderColor: DynamicTheme.Colors.surface,
                    borderWidth: 2
                )
                .zIndex(Double(maxDisplay - index))
            }

            if urls.count > maxDisplay {
                overflowBadge
            }
        }
    }

    private var overflowBadge: some View {
        Circle()
            .fill(DynamicTheme.Colors.cardBackground)
            .frame(width: size.rawValue, height: size.rawValue)
            .overlay(
                Text("+\(urls.count - maxDisplay)")
                    .font(.system(size: size.iconSize * 0.8, weight: .semibold))
                    .foregroundColor(DynamicTheme.Colors.text)
            )
            .overlay(
                Circle()
                    .stroke(DynamicTheme.Colors.surface, lineWidth: 2)
            )
    }
}

// MARK: - Previews

#Preview("Avatar Sizes") {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            AvatarView(url: nil, size: .small)
            AvatarView(url: nil, size: .medium)
            AvatarView(url: nil, size: .large)
            AvatarView(url: nil, size: .xlarge)
        }

        HStack(spacing: 16) {
            AvatarView(initials: "JD", size: .small)
            AvatarView(initials: "SK", size: .medium)
            AvatarView(initials: "AB", size: .large)
        }

        HStack(spacing: 16) {
            AvatarView(url: nil, size: .medium, badge: .online)
            AvatarView(url: nil, size: .medium, badge: .verified)
            AvatarView(url: nil, size: .medium, badge: .accepting)
        }

        AvatarGroup(urls: [nil, nil, nil, nil, nil, nil], size: .medium)
    }
    .padding()
}
