//
//  StatsRow.swift
//  WarmupUIKit
//
//  Reusable stats display components
//

import SwiftUI

// MARK: - Stat Item

/// A single stat item with icon, value, and label
public struct StatItem: View {

    let icon: String?
    let value: String
    let label: String?
    let iconColor: Color
    let valueColor: Color
    let labelColor: Color
    let size: StatSize

    public enum StatSize {
        case compact
        case regular
        case large

        var valueFont: Font {
            switch self {
            case .compact: return DynamicTheme.Typography.subheadline.weight(.semibold)
            case .regular: return DynamicTheme.Typography.headline
            case .large: return DynamicTheme.Typography.title2.weight(.bold)
            }
        }

        var labelFont: Font {
            switch self {
            case .compact: return DynamicTheme.Typography.caption
            case .regular: return DynamicTheme.Typography.caption
            case .large: return DynamicTheme.Typography.subheadline
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .compact: return 12
            case .regular: return 14
            case .large: return 18
            }
        }

        var spacing: CGFloat {
            switch self {
            case .compact: return 2
            case .regular: return 4
            case .large: return 6
            }
        }
    }

    public init(
        icon: String? = nil,
        value: String,
        label: String? = nil,
        iconColor: Color = DynamicTheme.Colors.primary,
        valueColor: Color = DynamicTheme.Colors.text,
        labelColor: Color = DynamicTheme.Colors.textSecondary,
        size: StatSize = .regular
    ) {
        self.icon = icon
        self.value = value
        self.label = label
        self.iconColor = iconColor
        self.valueColor = valueColor
        self.labelColor = labelColor
        self.size = size
    }

    public var body: some View {
        HStack(spacing: size.spacing) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
                    .foregroundColor(iconColor)
            }

            Text(value)
                .font(size.valueFont)
                .foregroundColor(valueColor)

            if let label = label {
                Text(label)
                    .font(size.labelFont)
                    .foregroundColor(labelColor)
            }
        }
    }
}

// MARK: - Stats Row

/// A horizontal row of stat items
public struct StatsRow: View {

    let stats: [StatData]
    let spacing: CGFloat
    let dividerColor: Color
    let showDividers: Bool

    public struct StatData: Identifiable {
        public let id = UUID()
        public let icon: String?
        public let value: String
        public let label: String?
        public let iconColor: Color

        public init(
            icon: String? = nil,
            value: String,
            label: String? = nil,
            iconColor: Color = DynamicTheme.Colors.primary
        ) {
            self.icon = icon
            self.value = value
            self.label = label
            self.iconColor = iconColor
        }
    }

    public init(
        stats: [StatData],
        spacing: CGFloat = 12,
        dividerColor: Color = DynamicTheme.Colors.textTertiary,
        showDividers: Bool = true
    ) {
        self.stats = stats
        self.spacing = spacing
        self.dividerColor = dividerColor
        self.showDividers = showDividers
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                StatItem(
                    icon: stat.icon,
                    value: stat.value,
                    label: stat.label,
                    iconColor: stat.iconColor
                )

                if showDividers && index < stats.count - 1 {
                    Text("•")
                        .foregroundColor(dividerColor)
                }
            }
        }
    }
}

// MARK: - Stat Card

/// A card-style stat display with icon, value, and label stacked vertically
public struct StatCard: View {

    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    let backgroundColor: Color

    public init(
        icon: String,
        value: String,
        label: String,
        iconColor: Color = DynamicTheme.Colors.primary,
        backgroundColor: Color = DynamicTheme.Colors.cardBackground
    ) {
        self.icon = icon
        self.value = value
        self.label = label
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        VStack(spacing: DynamicTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)

            Text(value)
                .font(DynamicTheme.Typography.title2.weight(.bold))
                .foregroundColor(DynamicTheme.Colors.text)

            Text(label)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DynamicTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .fill(backgroundColor)
        )
    }
}

// MARK: - Stats Grid

/// A grid of stat cards
public struct StatsGrid: View {

    let stats: [StatCardData]
    let columns: Int

    public struct StatCardData: Identifiable {
        public let id = UUID()
        public let icon: String
        public let value: String
        public let label: String
        public let iconColor: Color

        public init(
            icon: String,
            value: String,
            label: String,
            iconColor: Color = DynamicTheme.Colors.primary
        ) {
            self.icon = icon
            self.value = value
            self.label = label
            self.iconColor = iconColor
        }
    }

    public init(stats: [StatCardData], columns: Int = 2) {
        self.stats = stats
        self.columns = columns
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: DynamicTheme.Spacing.sm), count: columns),
            spacing: DynamicTheme.Spacing.sm
        ) {
            ForEach(stats) { stat in
                StatCard(
                    icon: stat.icon,
                    value: stat.value,
                    label: stat.label,
                    iconColor: stat.iconColor
                )
            }
        }
    }
}

// MARK: - Rating View

/// A star rating display
public struct RatingView: View {

    let rating: Double
    let maxRating: Int
    let totalReviews: Int?
    let starColor: Color
    let emptyStarColor: Color
    let size: CGFloat

    public init(
        rating: Double,
        maxRating: Int = 5,
        totalReviews: Int? = nil,
        starColor: Color = .yellow,
        emptyStarColor: Color = DynamicTheme.Colors.textTertiary,
        size: CGFloat = 14
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.totalReviews = totalReviews
        self.starColor = starColor
        self.emptyStarColor = emptyStarColor
        self.size = size
    }

    public var body: some View {
        HStack(spacing: 4) {
            // Stars
            HStack(spacing: 2) {
                ForEach(0..<maxRating, id: \.self) { index in
                    starImage(for: index)
                        .font(.system(size: size))
                }
            }

            // Rating value
            Text(String(format: "%.1f", rating))
                .font(DynamicTheme.Typography.caption.weight(.medium))
                .foregroundColor(DynamicTheme.Colors.text)

            // Review count
            if let reviews = totalReviews {
                Text("(\(reviews))")
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func starImage(for index: Int) -> some View {
        let fillAmount = rating - Double(index)

        if fillAmount >= 1 {
            Image(systemName: "star.fill")
                .foregroundColor(starColor)
        } else if fillAmount > 0 {
            Image(systemName: "star.leadinghalf.filled")
                .foregroundColor(starColor)
        } else {
            Image(systemName: "star")
                .foregroundColor(emptyStarColor)
        }
    }
}

// MARK: - Previews

#Preview("Stats") {
    VStack(spacing: 24) {
        // Single stat items
        HStack(spacing: 20) {
            StatItem(icon: "star.fill", value: "4.8", label: "rating")
            StatItem(icon: "person.2.fill", value: "45", label: "clients")
            StatItem(icon: "clock.fill", value: "8y", label: "exp")
        }

        // Stats row with dividers
        StatsRow(stats: [
            .init(icon: "star.fill", value: "4.8", iconColor: .yellow),
            .init(value: "127", label: "reviews"),
            .init(value: "5y", label: "exp")
        ])

        // Stat cards
        StatsGrid(stats: [
            .init(icon: "flame.fill", value: "1,234", label: "Calories", iconColor: .orange),
            .init(icon: "figure.run", value: "45", label: "Workouts", iconColor: .green),
            .init(icon: "clock.fill", value: "32h", label: "Training", iconColor: .blue),
            .init(icon: "trophy.fill", value: "12", label: "PRs", iconColor: .yellow)
        ])

        // Rating view
        RatingView(rating: 4.5, totalReviews: 127)
    }
    .padding()
}
