//
//  TagsView.swift
//  WarmupUIKit
//
//  Horizontal scrolling tag/pill components
//

import SwiftUI

// MARK: - Tag Style

/// Defines the visual style of tags
public enum TagStyle {
    /// Filled background with contrasting text
    case filled
    /// Tinted background with matching text
    case tinted
    /// Outlined with border
    case outlined

    func backgroundColor(for color: Color) -> Color {
        switch self {
        case .filled: return color
        case .tinted: return color.opacity(0.1)
        case .outlined: return .clear
        }
    }

    func textColor(for color: Color) -> Color {
        switch self {
        case .filled: return .white
        case .tinted: return color
        case .outlined: return color
        }
    }
}

// MARK: - Tag View

/// A single tag/pill component
public struct TagView: View {

    let text: String
    let icon: String?
    let color: Color
    let style: TagStyle
    let size: TagSize
    let onTap: (() -> Void)?
    let onRemove: (() -> Void)?

    public enum TagSize {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return DynamicTheme.Typography.caption
            case .medium: return DynamicTheme.Typography.subheadline
            case .large: return DynamicTheme.Typography.body
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return DynamicTheme.Spacing.sm
            case .medium: return DynamicTheme.Spacing.md
            case .large: return DynamicTheme.Spacing.md
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return DynamicTheme.Spacing.xs
            case .medium: return DynamicTheme.Spacing.sm
            case .large: return DynamicTheme.Spacing.sm
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }

    public init(
        _ text: String,
        icon: String? = nil,
        color: Color = DynamicTheme.Colors.primary,
        style: TagStyle = .tinted,
        size: TagSize = .medium,
        onTap: (() -> Void)? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.style = style
        self.size = size
        self.onTap = onTap
        self.onRemove = onRemove
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
            }

            Text(text)
                .font(size.font)
                .lineLimit(1)

            if onRemove != nil {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
            }
        }
        .foregroundColor(style.textColor(for: color))
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(style.backgroundColor(for: color))
        )
        .overlay(
            Group {
                if style == .outlined {
                    Capsule()
                        .stroke(color, lineWidth: 1)
                }
            }
        )
        .contentShape(Capsule())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Tags Row

/// A horizontal scrolling row of tags
public struct TagsRow: View {

    let tags: [String]
    let color: Color
    let style: TagStyle
    let size: TagView.TagSize
    let maxTags: Int?
    let onTagTap: ((String) -> Void)?

    public init(
        tags: [String],
        color: Color = DynamicTheme.Colors.primary,
        style: TagStyle = .tinted,
        size: TagView.TagSize = .medium,
        maxTags: Int? = nil,
        onTagTap: ((String) -> Void)? = nil
    ) {
        self.tags = tags
        self.color = color
        self.style = style
        self.size = size
        self.maxTags = maxTags
        self.onTagTap = onTagTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DynamicTheme.Spacing.xs) {
                ForEach(displayTags, id: \.self) { tag in
                    TagView(
                        tag,
                        color: color,
                        style: style,
                        size: size,
                        onTap: onTagTap != nil ? { onTagTap?(tag) } : nil
                    )
                }

                if let max = maxTags, tags.count > max {
                    TagView(
                        "+\(tags.count - max)",
                        color: DynamicTheme.Colors.textSecondary,
                        style: .tinted,
                        size: size
                    )
                }
            }
        }
    }

    private var displayTags: [String] {
        if let max = maxTags {
            return Array(tags.prefix(max))
        }
        return tags
    }
}

// MARK: - Tags Wrap View

/// A wrapping grid of tags (for when horizontal scroll isn't desired)
public struct TagsWrapView: View {

    let tags: [String]
    let color: Color
    let style: TagStyle
    let size: TagView.TagSize
    let spacing: CGFloat
    let onTagTap: ((String) -> Void)?

    public init(
        tags: [String],
        color: Color = DynamicTheme.Colors.primary,
        style: TagStyle = .tinted,
        size: TagView.TagSize = .medium,
        spacing: CGFloat = 8,
        onTagTap: ((String) -> Void)? = nil
    ) {
        self.tags = tags
        self.color = color
        self.style = style
        self.size = size
        self.spacing = spacing
        self.onTagTap = onTagTap
    }

    public var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                TagView(
                    tag,
                    color: color,
                    style: style,
                    size: size,
                    onTap: onTagTap != nil ? { onTagTap?(tag) } : nil
                )
            }
        }
    }
}

// MARK: - Flow Layout

/// A layout that wraps content to new lines
public struct FlowLayout: Layout {
    let spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))

            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

// MARK: - Specialization Parser Helper

public extension String {
    /// Parses a comma-separated or array-formatted string into tag array
    func parseAsTags() -> [String] {
        let cleaned = self
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\"", with: "")

        return cleaned
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Previews

#Preview("Tags") {
    VStack(spacing: 20) {
        // Single tags
        HStack {
            TagView("Fitness", style: .filled)
            TagView("Nutrition", style: .tinted)
            TagView("Strength", style: .outlined)
        }

        // Tags row
        TagsRow(
            tags: ["HIIT", "Strength Training", "Yoga", "Cardio", "CrossFit"],
            maxTags: 3
        )

        // Tags wrap
        TagsWrapView(
            tags: ["Weight Loss", "Muscle Building", "Endurance", "Flexibility", "Core Strength"],
            size: .small
        )
        .frame(width: 300)

        // Removable tags
        HStack {
            TagView("Removable", onRemove: {})
            TagView("With Icon", icon: "star.fill", onRemove: {})
        }
    }
    .padding()
}
