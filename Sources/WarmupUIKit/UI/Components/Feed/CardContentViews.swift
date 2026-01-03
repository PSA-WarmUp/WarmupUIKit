//
//  CardContentViews.swift
//  WarmupUIKit
//
//  Different card content layouts for feed posts
//  Shared between trainer and client apps
//

import SwiftUI

// MARK: - Public Card Content (Minimal - Card Style)
public struct PublicCardContent: View {
    public let post: FeedItem
    public let card: PublicCardDto

    public init(post: FeedItem, card: PublicCardDto) {
        self.post = post
        self.card = card
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header with workout type
            HStack(spacing: DynamicTheme.Spacing.sm) {
                // Workout icon in colored circle
                Circle()
                    .fill(DynamicTheme.Colors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Complete")
                        .font(DynamicTheme.Typography.captionMedium)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)

                    Text(card.workoutType ?? "Workout")
                        .font(DynamicTheme.Typography.headline)
                        .foregroundColor(DynamicTheme.Colors.text)
                }

                Spacer()

                // PR Badge if any PRs
                if let prCount = card.personalRecordsCount, prCount > 0 {
                    prBadge(count: prCount)
                }
            }
            .padding(DynamicTheme.Spacing.md)

            Divider()
                .background(DynamicTheme.Colors.border)

            // Metrics grid
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(
                        icon: "clock.fill",
                        value: formatDuration(duration),
                        label: "Duration",
                        color: DynamicTheme.Colors.primary
                    )
                }

                if let sets = card.totalSets, sets > 0 {
                    metricItem(
                        icon: "repeat",
                        value: "\(sets)",
                        label: "Sets",
                        color: DynamicTheme.Colors.info
                    )
                }

                if let reps = card.totalReps, reps > 0 {
                    metricItem(
                        icon: "figure.strengthtraining.traditional",
                        value: "\(reps)",
                        label: "Reps",
                        color: DynamicTheme.Colors.success
                    )
                }

                if let calories = card.caloriesBurned, calories > 0 {
                    metricItem(
                        icon: "flame.fill",
                        value: "\(calories)",
                        label: "Cal",
                        color: DynamicTheme.Colors.warning
                    )
                }
            }
            .padding(.vertical, DynamicTheme.Spacing.md)

            // Caption (if any)
            if let caption = card.caption, !caption.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                Text(caption)
                    .font(DynamicTheme.Typography.body)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .padding(DynamicTheme.Spacing.md)
            }
        }
        .background(DynamicTheme.Colors.bubbleBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.bottom, DynamicTheme.Spacing.md)
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs")
                .font(DynamicTheme.Typography.captionMedium)
        }
        .foregroundColor(DynamicTheme.Colors.warning)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DynamicTheme.Colors.warning.opacity(0.15))
        .cornerRadius(DynamicTheme.Radius.round)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(DynamicTheme.Typography.headline)
                .foregroundColor(DynamicTheme.Colors.text)

            Text(label)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

// MARK: - Friends Card Content (Extended - Card Style)
public struct FriendsCardContent: View {
    public let post: FeedItem
    public let card: FriendsCardDto

    public init(post: FeedItem, card: FriendsCardDto) {
        self.post = post
        self.card = card
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack(spacing: DynamicTheme.Spacing.sm) {
                Circle()
                    .fill(DynamicTheme.Colors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Complete")
                        .font(DynamicTheme.Typography.captionMedium)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)

                    Text(card.workoutType ?? "Workout")
                        .font(DynamicTheme.Typography.headline)
                        .foregroundColor(DynamicTheme.Colors.text)
                }

                Spacer()

                if let prCount = card.personalRecordsCount, prCount > 0 {
                    prBadge(count: prCount)
                }
            }
            .padding(DynamicTheme.Spacing.md)

            Divider()
                .background(DynamicTheme.Colors.border)

            // Primary metrics row
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(
                        icon: "clock.fill",
                        value: formatDuration(duration),
                        label: "Duration",
                        color: DynamicTheme.Colors.primary
                    )
                }

                if let sets = card.totalSets, sets > 0 {
                    metricItem(
                        icon: "repeat",
                        value: "\(sets)",
                        label: "Sets",
                        color: DynamicTheme.Colors.info
                    )
                }

                if let volume = card.totalVolume, volume > 0 {
                    metricItem(
                        icon: "scalemass.fill",
                        value: formatVolume(volume),
                        label: card.volumeUnit ?? "lbs",
                        color: DynamicTheme.Colors.success
                    )
                }

                if let rpe = card.averageRpe, rpe > 0 {
                    metricItem(
                        icon: "heart.fill",
                        value: String(format: "%.1f", rpe),
                        label: "Avg RPE",
                        color: DynamicTheme.Colors.error
                    )
                }
            }
            .padding(.vertical, DynamicTheme.Spacing.md)

            // Secondary metrics (if available)
            let hasSecondaryMetrics = (card.distanceMiles ?? 0) > 0 || (card.caloriesBurned ?? 0) > 0
            if hasSecondaryMetrics {
                Divider()
                    .background(DynamicTheme.Colors.border)

                HStack(spacing: DynamicTheme.Spacing.lg) {
                    if let distance = card.distanceMiles, distance > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 14))
                                .foregroundColor(DynamicTheme.Colors.textSecondary)
                            Text(String(format: "%.1f mi", distance))
                                .font(DynamicTheme.Typography.subheadline)
                                .foregroundColor(DynamicTheme.Colors.text)
                        }
                    }

                    if let calories = card.caloriesBurned, calories > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundColor(DynamicTheme.Colors.warning)
                            Text("\(calories) cal")
                                .font(DynamicTheme.Typography.subheadline)
                                .foregroundColor(DynamicTheme.Colors.text)
                        }
                    }

                    Spacer()
                }
                .padding(DynamicTheme.Spacing.md)
            }

            // Caption
            if let caption = card.caption, !caption.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                Text(caption)
                    .font(DynamicTheme.Typography.body)
                    .foregroundColor(DynamicTheme.Colors.text)
                    .lineLimit(3)
                    .padding(DynamicTheme.Spacing.md)
            }
        }
        .background(DynamicTheme.Colors.bubbleBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.bottom, DynamicTheme.Spacing.md)
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs")
                .font(DynamicTheme.Typography.captionMedium)
        }
        .foregroundColor(DynamicTheme.Colors.warning)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DynamicTheme.Colors.warning.opacity(0.15))
        .cornerRadius(DynamicTheme.Radius.round)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(DynamicTheme.Typography.headline)
                .foregroundColor(DynamicTheme.Colors.text)

            Text(label)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }
}

// MARK: - Full Card Content (Trainer/Client/Self - Card Style)
public struct FullCardContent: View {
    public let post: FeedItem
    public let card: FullCardDto

    public init(post: FeedItem, card: FullCardDto) {
        self.post = post
        self.card = card
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header with program context
            VStack(alignment: .leading, spacing: DynamicTheme.Spacing.xs) {
                // Program badge (if available)
                if let programName = card.programName {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 10))
                        Text(programName)
                            .font(DynamicTheme.Typography.caption)
                        if let workoutLabel = card.workoutLabel {
                            Text("·")
                            Text(workoutLabel)
                                .font(DynamicTheme.Typography.caption)
                        }
                    }
                    .foregroundColor(DynamicTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DynamicTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(DynamicTheme.Radius.xs)
                }

                HStack(spacing: DynamicTheme.Spacing.sm) {
                    Circle()
                        .fill(DynamicTheme.Colors.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: headerIcon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(DynamicTheme.Colors.primary)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(headerTitle)
                            .font(DynamicTheme.Typography.captionMedium)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)

                        Text(card.workoutType ?? post.postType.displayName)
                            .font(DynamicTheme.Typography.title3)
                            .foregroundColor(DynamicTheme.Colors.text)
                    }

                    Spacer()

                    // PR Badge (only for workout types)
                    if post.postType.isWorkout {
                        if let prCount = card.personalRecordsCount, prCount > 0 {
                            prBadge(count: prCount)
                        } else if let prFlags = card.prFlags, !prFlags.isEmpty {
                            prBadge(count: prFlags.count)
                        }
                    }
                }
            }
            .padding(DynamicTheme.Spacing.md)

            Divider()
                .background(DynamicTheme.Colors.border)

            // Main metrics grid
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(
                        icon: "clock.fill",
                        value: formatDuration(duration),
                        label: "Duration",
                        color: DynamicTheme.Colors.primary
                    )
                }

                if let sets = card.totalSets, sets > 0 {
                    metricItem(
                        icon: "repeat",
                        value: "\(sets)",
                        label: "Sets",
                        color: DynamicTheme.Colors.info
                    )
                }

                if let volume = card.totalVolume, volume > 0 {
                    metricItem(
                        icon: "scalemass.fill",
                        value: formatVolume(volume),
                        label: card.volumeUnit ?? "lbs",
                        color: DynamicTheme.Colors.success
                    )
                }

                // Use averageRpe from WorkoutLog if available
                if let avgRpe = card.averageRpe, avgRpe > 0 {
                    metricItem(
                        icon: "heart.fill",
                        value: String(format: "%.1f", avgRpe),
                        label: "Avg RPE",
                        color: DynamicTheme.Colors.error
                    )
                } else if let rpe = card.rpe {
                    metricItem(
                        icon: "heart.fill",
                        value: "\(rpe)",
                        label: "RPE",
                        color: DynamicTheme.Colors.error
                    )
                }
            }
            .padding(.vertical, DynamicTheme.Spacing.md)

            // PR Achievements (scrollable tags)
            if let prFlags = card.prFlags, !prFlags.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                VStack(alignment: .leading, spacing: DynamicTheme.Spacing.sm) {
                    Text("PERSONAL RECORDS")
                        .font(DynamicTheme.Typography.captionMedium)
                        .foregroundColor(DynamicTheme.Colors.textTertiary)
                        .padding(.horizontal, DynamicTheme.Spacing.md)
                        .padding(.top, DynamicTheme.Spacing.sm)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DynamicTheme.Spacing.sm) {
                            ForEach(prFlags, id: \.self) { pr in
                                HStack(spacing: 4) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 10))
                                    Text(pr)
                                        .font(DynamicTheme.Typography.caption)
                                }
                                .foregroundColor(DynamicTheme.Colors.warning)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(DynamicTheme.Colors.warning.opacity(0.1))
                                .cornerRadius(DynamicTheme.Radius.round)
                            }
                        }
                        .padding(.horizontal, DynamicTheme.Spacing.md)
                    }
                }
                .padding(.bottom, DynamicTheme.Spacing.sm)
            }

            // Trainer Notes (if any)
            if let trainerNotes = card.trainerNotes, !trainerNotes.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 10))
                        Text("Trainer Notes")
                            .font(DynamicTheme.Typography.captionMedium)
                    }
                    .foregroundColor(DynamicTheme.Colors.textTertiary)

                    Text(trainerNotes)
                        .font(DynamicTheme.Typography.body)
                        .foregroundColor(DynamicTheme.Colors.text)
                }
                .padding(DynamicTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DynamicTheme.Colors.primaryBackground)
                .cornerRadius(DynamicTheme.Radius.small)
                .padding(.horizontal, DynamicTheme.Spacing.md)
                .padding(.vertical, DynamicTheme.Spacing.sm)
            }

            // Caption
            if let caption = card.caption, !caption.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                Text(caption)
                    .font(DynamicTheme.Typography.body)
                    .foregroundColor(DynamicTheme.Colors.text)
                    .padding(DynamicTheme.Spacing.md)
            }

            // Client reflection
            if let reflection = card.clientReflection, !reflection.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 10))
                        Text("Reflection")
                            .font(DynamicTheme.Typography.captionMedium)
                    }
                    .foregroundColor(DynamicTheme.Colors.textTertiary)

                    Text(reflection)
                        .font(DynamicTheme.Typography.body)
                        .foregroundColor(DynamicTheme.Colors.text)
                        .italic()
                }
                .padding(DynamicTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DynamicTheme.Colors.primaryBackground)
                .cornerRadius(DynamicTheme.Radius.small)
                .padding(.horizontal, DynamicTheme.Spacing.md)
                .padding(.bottom, DynamicTheme.Spacing.md)
            }
        }
        .background(DynamicTheme.Colors.bubbleBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.bottom, DynamicTheme.Spacing.md)
    }

    // MARK: - Header Configuration

    private var headerTitle: String {
        switch post.postType {
        case .workout, .workoutSummary:
            return "Workout Complete"
        case .weeklySummary:
            return "Week in Review"
        case .programCompletion:
            return "Program Complete"
        case .reflection:
            return "Reflection"
        default:
            return post.postType.displayName
        }
    }

    private var headerIcon: String {
        switch post.postType {
        case .workout, .workoutSummary:
            return "dumbbell.fill"
        case .weeklySummary:
            return "calendar"
        case .programCompletion:
            return "checkmark.seal.fill"
        case .reflection:
            return "text.quote"
        default:
            return post.postType.iconName
        }
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs")
                .font(DynamicTheme.Typography.captionMedium)
        }
        .foregroundColor(DynamicTheme.Colors.warning)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DynamicTheme.Colors.warning.opacity(0.15))
        .cornerRadius(DynamicTheme.Radius.round)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(DynamicTheme.Typography.headline)
                .foregroundColor(DynamicTheme.Colors.text)

            Text(label)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }
}

// MARK: - Exercise Highlight Row
public struct ExerciseHighlightRow: View {
    public let exercise: ExerciseHighlightDto

    public init(exercise: ExerciseHighlightDto) {
        self.exercise = exercise
    }

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.sm) {
            Circle()
                .fill(exercise.isPR == true ? DynamicTheme.Colors.warning.opacity(0.15) : DynamicTheme.Colors.bubbleBackground)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: exercise.isPR == true ? "trophy.fill" : "figure.strengthtraining.traditional")
                        .font(.system(size: 12))
                        .foregroundColor(exercise.isPR == true ? DynamicTheme.Colors.warning : DynamicTheme.Colors.textSecondary)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(exercise.name ?? "Exercise")
                    .font(DynamicTheme.Typography.subheadline)
                    .foregroundColor(DynamicTheme.Colors.text)

                if let summary = exercise.summary {
                    Text(summary)
                        .font(DynamicTheme.Typography.caption)
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                }
            }

            Spacer()

            if exercise.isPR == true {
                Text("PR")
                    .font(DynamicTheme.Typography.captionMedium)
                    .foregroundColor(DynamicTheme.Colors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(DynamicTheme.Colors.warning.opacity(0.15))
                    .cornerRadius(DynamicTheme.Radius.xs)
            }
        }
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.vertical, DynamicTheme.Spacing.xs)
    }
}

// MARK: - Minimal Card Content (Fallback)
public struct MinimalCardContent: View {
    public let post: FeedItem

    public init(post: FeedItem) {
        self.post = post
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: DynamicTheme.Spacing.sm) {
                Circle()
                    .fill(DynamicTheme.Colors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: post.postType.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DynamicTheme.Colors.primary)
                    )

                Text(post.postType.displayName)
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.text)

                Spacer()
            }
            .padding(DynamicTheme.Spacing.md)

            if let caption = post.caption, !caption.isEmpty {
                Divider()
                    .background(DynamicTheme.Colors.border)

                Text(caption)
                    .font(DynamicTheme.Typography.body)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .padding(DynamicTheme.Spacing.md)
            }
        }
        .background(DynamicTheme.Colors.bubbleBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium)
                .stroke(DynamicTheme.Colors.border, lineWidth: 1)
        )
        .padding(.horizontal, DynamicTheme.Spacing.md)
        .padding(.bottom, DynamicTheme.Spacing.md)
    }
}

// MARK: - Metric View Component (Legacy - kept for compatibility)
public struct MetricView: View {
    public let value: String
    public let label: String
    public var isPR: Bool = false

    public init(value: String, label: String, isPR: Bool = false) {
        self.value = value
        self.label = label
        self.isPR = isPR
    }

    public var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text(value)
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.text)

                if isPR {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundColor(DynamicTheme.Colors.warning)
                }
            }

            Text(label)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textTertiary)
        }
        .frame(minWidth: 60)
    }
}
