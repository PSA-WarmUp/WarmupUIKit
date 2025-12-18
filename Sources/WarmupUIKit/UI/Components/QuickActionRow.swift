//
//  QuickActionRow.swift
//  WarmupUIKit
//
//  Horizontal scrolling container for quick action buttons
//

import SwiftUI

// MARK: - Quick Action Item

/// Defines a quick action item for use in QuickActionRow
public struct QuickActionItem: Identifiable {
    public let id: String
    public let icon: String
    public let title: String
    public let color: Color
    public let action: () -> Void

    public init(
        id: String = UUID().uuidString,
        icon: String,
        title: String,
        color: Color = DynamicTheme.Colors.primary,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.color = color
        self.action = action
    }
}

// MARK: - Quick Action Row

/// A horizontal scrolling row of quick action buttons.
/// Perfect for suggestion bubbles, action menus, and contextual actions.
public struct QuickActionRow: View {
    let items: [QuickActionItem]
    let style: QuickActionButtonStyle
    let showBackground: Bool

    public init(
        items: [QuickActionItem],
        style: QuickActionButtonStyle = .bubble,
        showBackground: Bool = true
    ) {
        self.items = items
        self.style = style
        self.showBackground = showBackground
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DynamicTheme.Spacing.sm) {
                ForEach(items) { item in
                    QuickActionButton(
                        icon: item.icon,
                        title: item.title,
                        color: item.color,
                        style: style,
                        action: item.action
                    )
                }
            }
            .padding(.horizontal, DynamicTheme.Spacing.md)
            .padding(.vertical, DynamicTheme.Spacing.sm)
        }
        .background(
            showBackground
                ? DynamicTheme.Colors.surface.opacity(0.8)
                : Color.clear
        )
    }
}

// MARK: - Quick Action Grid

/// A grid layout for quick actions - useful for action menus
public struct QuickActionGrid: View {
    let items: [QuickActionItem]
    let columns: Int
    let style: QuickActionButtonStyle

    public init(
        items: [QuickActionItem],
        columns: Int = 2,
        style: QuickActionButtonStyle = .chip
    ) {
        self.items = items
        self.columns = columns
        self.style = style
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: DynamicTheme.Spacing.sm), count: columns)
    }

    public var body: some View {
        LazyVGrid(columns: gridColumns, spacing: DynamicTheme.Spacing.sm) {
            ForEach(items) { item in
                QuickActionButton(
                    icon: item.icon,
                    title: item.title,
                    color: item.color,
                    style: style,
                    action: item.action
                )
            }
        }
        .padding(DynamicTheme.Spacing.md)
    }
}

// MARK: - Trainer Quick Actions

/// Pre-configured quick actions for trainer app
public struct TrainerQuickActions {
    public static func defaultActions(onAction: @escaping (String) -> Void) -> [QuickActionItem] {
        [
            QuickActionItem(
                icon: "plus.circle.fill",
                title: "Create Workout",
                color: DynamicTheme.Colors.primary
            ) { onAction("Create a new workout") },

            QuickActionItem(
                icon: "doc.text.fill",
                title: "Build Program",
                color: DynamicTheme.Colors.info
            ) { onAction("Create a training program") },

            QuickActionItem(
                icon: "person.badge.plus.fill",
                title: "Add Client",
                color: DynamicTheme.Colors.success
            ) { onAction("Add a new client") },

            QuickActionItem(
                icon: "calendar.badge.clock",
                title: "Schedule",
                color: DynamicTheme.Colors.warning
            ) { onAction("Show my schedule for today") },

            QuickActionItem(
                icon: "chart.bar.fill",
                title: "Analytics",
                color: DynamicTheme.Colors.error
            ) { onAction("Show client progress analytics") }
        ]
    }

    public static func sessionActions(onAction: @escaping (String) -> Void) -> [QuickActionItem] {
        [
            QuickActionItem(
                icon: "figure.run",
                title: "Start Session",
                color: DynamicTheme.Colors.primary
            ) { onAction("Start session") },

            QuickActionItem(
                icon: "doc.text",
                title: "Review Programs",
                color: DynamicTheme.Colors.info
            ) { onAction("Show programs") },

            QuickActionItem(
                icon: "person.2",
                title: "View Clients",
                color: DynamicTheme.Colors.success
            ) { onAction("Show clients") },

            QuickActionItem(
                icon: "calendar",
                title: "Today's Schedule",
                color: DynamicTheme.Colors.warning
            ) { onAction("Show schedule") }
        ]
    }
}

// MARK: - Client Quick Actions

/// Pre-configured quick actions for client app
public struct ClientQuickActions {
    public static func defaultActions(onAction: @escaping (String) -> Void) -> [QuickActionItem] {
        [
            QuickActionItem(
                icon: "figure.run",
                title: "Start Workout",
                color: DynamicTheme.Colors.primary
            ) { onAction("Start my workout") },

            QuickActionItem(
                icon: "calendar",
                title: "My Schedule",
                color: DynamicTheme.Colors.info
            ) { onAction("Show my workout schedule") },

            QuickActionItem(
                icon: "chart.line.uptrend.xyaxis",
                title: "Progress",
                color: DynamicTheme.Colors.success
            ) { onAction("Show my progress") },

            QuickActionItem(
                icon: "message.fill",
                title: "Ask Trainer",
                color: DynamicTheme.Colors.warning
            ) { onAction("Message my trainer") }
        ]
    }
}

// MARK: - Previews

#Preview("Quick Action Row - Bubble") {
    VStack {
        Spacer()
        QuickActionRow(
            items: TrainerQuickActions.defaultActions { _ in },
            style: .bubble
        )
    }
    .background(DynamicTheme.Colors.background)
}

#Preview("Quick Action Row - Chip") {
    VStack {
        Spacer()
        QuickActionRow(
            items: TrainerQuickActions.sessionActions { _ in },
            style: .chip,
            showBackground: false
        )
    }
    .background(DynamicTheme.Colors.background)
}

#Preview("Quick Action Grid") {
    QuickActionGrid(
        items: TrainerQuickActions.defaultActions { _ in },
        columns: 2,
        style: .chip
    )
    .background(DynamicTheme.Colors.background)
}

#Preview("Client Actions") {
    VStack {
        Spacer()
        QuickActionRow(
            items: ClientQuickActions.defaultActions { _ in },
            style: .bubble
        )
    }
    .background(DynamicTheme.Colors.background)
}
