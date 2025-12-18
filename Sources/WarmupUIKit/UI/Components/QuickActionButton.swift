//
//  QuickActionButton.swift
//  WarmupUIKit
//
//  Reusable quick action button components for WarmUp apps
//

import SwiftUI

// MARK: - Quick Action Button Style

/// Defines the visual style of a QuickActionButton
public enum QuickActionButtonStyle {
    /// Pill/capsule shape with subtle background - ideal for suggestion bubbles
    case bubble
    /// Pill/capsule with colored tint background - ideal for action chips
    case chip
    /// Filled primary button style
    case filled
    /// Outline/bordered style
    case outlined
}

// MARK: - Quick Action Button

/// A reusable quick action button that matches WarmUp design system.
/// Use for suggestion bubbles, action chips, and contextual quick actions.
public struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let style: QuickActionButtonStyle
    let action: () -> Void

    public init(
        icon: String,
        title: String,
        color: Color = DynamicTheme.Colors.primary,
        style: QuickActionButtonStyle = .bubble,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DynamicTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: iconWeight))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(titleFont)
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView)
            .overlay(overlayView)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Style Properties

    private var iconSize: CGFloat {
        switch style {
        case .bubble:
            return 14
        case .chip:
            return 14
        case .filled:
            return 16
        case .outlined:
            return 14
        }
    }

    private var iconWeight: Font.Weight {
        switch style {
        case .bubble:
            return .regular
        case .chip:
            return .semibold
        case .filled:
            return .semibold
        case .outlined:
            return .medium
        }
    }

    private var iconColor: Color {
        switch style {
        case .bubble:
            return color
        case .chip:
            return color
        case .filled:
            return .white
        case .outlined:
            return color
        }
    }

    private var titleFont: Font {
        switch style {
        case .bubble:
            return DynamicTheme.Typography.caption
        case .chip:
            return DynamicTheme.Typography.subheadline
        case .filled:
            return DynamicTheme.Typography.headline
        case .outlined:
            return DynamicTheme.Typography.subheadline
        }
    }

    private var textColor: Color {
        switch style {
        case .bubble:
            return DynamicTheme.Colors.text
        case .chip:
            return DynamicTheme.Colors.text
        case .filled:
            return .white
        case .outlined:
            return DynamicTheme.Colors.text
        }
    }

    private var horizontalPadding: CGFloat {
        switch style {
        case .bubble:
            return DynamicTheme.Spacing.md
        case .chip:
            return DynamicTheme.Spacing.md
        case .filled:
            return DynamicTheme.Spacing.lg
        case .outlined:
            return DynamicTheme.Spacing.md
        }
    }

    private var verticalPadding: CGFloat {
        switch style {
        case .bubble:
            return DynamicTheme.Spacing.sm
        case .chip:
            return DynamicTheme.Spacing.sm
        case .filled:
            return DynamicTheme.Spacing.sm + 2
        case .outlined:
            return DynamicTheme.Spacing.sm
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .bubble:
            Capsule()
                .fill(DynamicTheme.Colors.cardBackground)
        case .chip:
            Capsule()
                .fill(color.opacity(0.1))
        case .filled:
            Capsule()
                .fill(color)
        case .outlined:
            Capsule()
                .fill(Color.clear)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .bubble:
            Capsule()
                .strokeBorder(DynamicTheme.Colors.border, lineWidth: 1)
        case .chip:
            Capsule()
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        case .filled:
            EmptyView()
        case .outlined:
            Capsule()
                .strokeBorder(DynamicTheme.Colors.border, lineWidth: 1)
        }
    }
}

// MARK: - Quick Action Icon Button

/// A circular icon-only quick action button
public struct QuickActionIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let isFilled: Bool
    let action: () -> Void

    public init(
        icon: String,
        color: Color = DynamicTheme.Colors.primary,
        size: CGFloat = 44,
        isFilled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.isFilled = isFilled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(isFilled ? color : DynamicTheme.Colors.cardBackground)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.36, weight: .semibold))
                        .foregroundColor(isFilled ? .white : DynamicTheme.Colors.textSecondary)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Bubble Style") {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            QuickActionButton(
                icon: "plus.circle.fill",
                title: "Create Workout",
                color: DynamicTheme.Colors.primary,
                style: .bubble
            ) {}

            QuickActionButton(
                icon: "doc.text.fill",
                title: "Build Program",
                color: DynamicTheme.Colors.info,
                style: .bubble
            ) {}
        }
    }
    .padding()
    .background(DynamicTheme.Colors.background)
}

#Preview("Chip Style") {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            QuickActionButton(
                icon: "figure.run",
                title: "Start Session",
                color: DynamicTheme.Colors.primary,
                style: .chip
            ) {}

            QuickActionButton(
                icon: "person.2",
                title: "View Clients",
                color: DynamicTheme.Colors.success,
                style: .chip
            ) {}
        }
    }
    .padding()
    .background(DynamicTheme.Colors.background)
}

#Preview("All Styles") {
    VStack(spacing: 16) {
        QuickActionButton(
            icon: "plus",
            title: "Bubble",
            style: .bubble
        ) {}

        QuickActionButton(
            icon: "plus",
            title: "Chip",
            style: .chip
        ) {}

        QuickActionButton(
            icon: "plus",
            title: "Filled",
            style: .filled
        ) {}

        QuickActionButton(
            icon: "plus",
            title: "Outlined",
            style: .outlined
        ) {}
    }
    .padding()
    .background(DynamicTheme.Colors.background)
}

#Preview("Icon Buttons") {
    HStack(spacing: 12) {
        QuickActionIconButton(icon: "mic.fill") {}
        QuickActionIconButton(icon: "arrow.up", isFilled: true) {}
        QuickActionIconButton(icon: "keyboard") {}
    }
    .padding()
    .background(DynamicTheme.Colors.background)
}
