//
//  CardContentViews.swift
//  WarmupUIKit
//
//  Card content layouts for feed posts — Quiet Pro V2 design
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
            HStack(spacing: DS.Space.v8) {
                Circle()
                    .fill(DS.Color.primarySoft)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DS.Color.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Complete")
                        .font(DS.Typo.captionMedium)
                        .foregroundColor(DS.Color.textSec)

                    Text(card.workoutType ?? "Workout")
                        .font(DS.Typo.headline)
                        .foregroundColor(DS.Color.text)
                }

                Spacer()

                if let prCount = card.personalRecordsCount, prCount > 0 {
                    prBadge(count: prCount)
                }
            }
            .padding(DS.Space.cardPad)

            Divider().background(DS.Color.hairline)

            // Metrics grid
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(icon: "clock.fill", value: formatDuration(duration), label: "Duration", color: DS.Color.primary)
                }
                if let sets = card.totalSets, sets > 0 {
                    metricItem(icon: "repeat", value: "\(sets)", label: "Sets", color: DS.Color.info)
                }
                if let reps = card.totalReps, reps > 0 {
                    metricItem(icon: "figure.strengthtraining.traditional", value: "\(reps)", label: "Reps", color: DS.Color.success)
                }
                if let calories = card.caloriesBurned, calories > 0 {
                    metricItem(icon: "flame.fill", value: "\(calories)", label: "Cal", color: DS.Color.warning)
                }
            }
            .padding(.vertical, DS.Space.cardPad)

            if let caption = card.caption, !caption.isEmpty {
                Divider().background(DS.Color.hairline)
                Text(caption)
                    .font(DS.Typo.body)
                    .foregroundColor(DS.Color.textSec)
                    .lineLimit(2)
                    .padding(DS.Space.cardPad)
            }
        }
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill").font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs").font(DS.Typo.captionMedium)
        }
        .foregroundColor(DS.Color.warning)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DS.Color.warningSoft)
        .cornerRadius(DS.Space.smallRadius)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            Text(value).font(DS.Typo.headline).foregroundColor(DS.Color.text)
            Text(label).font(DS.Typo.caption).foregroundColor(DS.Color.textTer)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
}

// MARK: - Friends Card Content (Extended)
public struct FriendsCardContent: View {
    public let post: FeedItem
    public let card: FriendsCardDto

    public init(post: FeedItem, card: FriendsCardDto) {
        self.post = post
        self.card = card
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: DS.Space.v8) {
                Circle()
                    .fill(DS.Color.primarySoft)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DS.Color.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Complete")
                        .font(DS.Typo.captionMedium)
                        .foregroundColor(DS.Color.textSec)
                    Text(card.workoutType ?? "Workout")
                        .font(DS.Typo.headline)
                        .foregroundColor(DS.Color.text)
                }

                Spacer()

                if let prCount = card.personalRecordsCount, prCount > 0 {
                    prBadge(count: prCount)
                }
            }
            .padding(DS.Space.cardPad)

            Divider().background(DS.Color.hairline)

            // Primary metrics
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(icon: "clock.fill", value: formatDuration(duration), label: "Duration", color: DS.Color.primary)
                }
                if let sets = card.totalSets, sets > 0 {
                    metricItem(icon: "repeat", value: "\(sets)", label: "Sets", color: DS.Color.info)
                }
                if let volume = card.totalVolume, volume > 0 {
                    metricItem(icon: "scalemass.fill", value: formatVolume(volume), label: card.volumeUnit ?? "lbs", color: DS.Color.success)
                }
                if let rpe = card.averageRpe, rpe > 0 {
                    metricItem(icon: "heart.fill", value: String(format: "%.1f", rpe), label: "Avg RPE", color: DS.Color.error)
                }
            }
            .padding(.vertical, DS.Space.cardPad)

            // Secondary metrics
            let hasSecondary = (card.distanceMiles ?? 0) > 0 || (card.caloriesBurned ?? 0) > 0
            if hasSecondary {
                Divider().background(DS.Color.hairline)
                HStack(spacing: DS.Space.v16) {
                    if let distance = card.distanceMiles, distance > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.run").font(.system(size: 14)).foregroundColor(DS.Color.textSec)
                            Text(String(format: "%.1f mi", distance)).font(DS.Typo.callout).foregroundColor(DS.Color.text)
                        }
                    }
                    if let calories = card.caloriesBurned, calories > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill").font(.system(size: 14)).foregroundColor(DS.Color.warning)
                            Text("\(calories) cal").font(DS.Typo.callout).foregroundColor(DS.Color.text)
                        }
                    }
                    Spacer()
                }
                .padding(DS.Space.cardPad)
            }

            if let caption = card.caption, !caption.isEmpty {
                Divider().background(DS.Color.hairline)
                Text(caption)
                    .font(DS.Typo.body)
                    .foregroundColor(DS.Color.text)
                    .lineLimit(3)
                    .padding(DS.Space.cardPad)
            }
        }
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill").font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs").font(DS.Typo.captionMedium)
        }
        .foregroundColor(DS.Color.warning)
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(DS.Color.warningSoft)
        .cornerRadius(DS.Space.smallRadius)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            Text(value).font(DS.Typo.headline).foregroundColor(DS.Color.text)
            Text(label).font(DS.Typo.caption).foregroundColor(DS.Color.textTer)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60; let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }

    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
}

// MARK: - Full Card Content (Trainer/Client/Self)
public struct FullCardContent: View {
    public let post: FeedItem
    public let card: FullCardDto

    public init(post: FeedItem, card: FullCardDto) {
        self.post = post
        self.card = card
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with program context
            VStack(alignment: .leading, spacing: DS.Space.v4) {
                if let programName = card.programName {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text.fill").font(.system(size: 10))
                        Text(programName).font(DS.Typo.caption)
                        if let workoutLabel = card.workoutLabel {
                            Text("·")
                            Text(workoutLabel).font(DS.Typo.caption)
                        }
                    }
                    .foregroundColor(DS.Color.primary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(DS.Color.primarySoft)
                    .cornerRadius(DS.Space.smallRadius)
                }

                HStack(spacing: DS.Space.v8) {
                    Circle()
                        .fill(DS.Color.primarySoft)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: headerIcon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(DS.Color.primary)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(headerTitle)
                            .font(DS.Typo.captionMedium)
                            .foregroundColor(DS.Color.textSec)
                        Text(card.workoutType ?? post.postType.displayName)
                            .font(DS.Typo.title3)
                            .foregroundColor(DS.Color.text)
                    }

                    Spacer()

                    if post.postType.isWorkout {
                        if let prCount = card.personalRecordsCount, prCount > 0 {
                            prBadge(count: prCount)
                        } else if let prFlags = card.prFlags, !prFlags.isEmpty {
                            prBadge(count: prFlags.count)
                        }
                    }
                }
            }
            .padding(DS.Space.cardPad)

            Divider().background(DS.Color.hairline)

            // Metrics grid
            HStack(spacing: 0) {
                if let duration = card.durationMinutes {
                    metricItem(icon: "clock.fill", value: formatDuration(duration), label: "Duration", color: DS.Color.primary)
                }
                if let sets = card.totalSets, sets > 0 {
                    metricItem(icon: "repeat", value: "\(sets)", label: "Sets", color: DS.Color.info)
                }
                if let volume = card.totalVolume, volume > 0 {
                    metricItem(icon: "scalemass.fill", value: formatVolume(volume), label: card.volumeUnit ?? "lbs", color: DS.Color.success)
                }
                if let avgRpe = card.averageRpe, avgRpe > 0 {
                    metricItem(icon: "heart.fill", value: String(format: "%.1f", avgRpe), label: "Avg RPE", color: DS.Color.error)
                } else if let rpe = card.rpe {
                    metricItem(icon: "heart.fill", value: "\(rpe)", label: "RPE", color: DS.Color.error)
                }
            }
            .padding(.vertical, DS.Space.cardPad)

            // PR Progression bar chart
            if let prProgression = post.prProgression,
               let points = prProgression.dataPoints, !points.isEmpty {
                Divider().background(DS.Color.hairline)
                PRProgressionChart(progression: prProgression)
            }

            // PR Achievements (scrollable tags)
            if let prFlags = card.prFlags, !prFlags.isEmpty {
                Divider().background(DS.Color.hairline)

                VStack(alignment: .leading, spacing: DS.Space.v8) {
                    Text("PERSONAL RECORDS")
                        .font(DS.Typo.captionMedium)
                        .foregroundColor(DS.Color.textTer)
                        .padding(.horizontal, DS.Space.cardPad)
                        .padding(.top, DS.Space.v8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Space.v8) {
                            ForEach(prFlags, id: \.self) { pr in
                                HStack(spacing: 4) {
                                    Image(systemName: "trophy.fill").font(.system(size: 10))
                                    Text(pr).font(DS.Typo.caption)
                                }
                                .foregroundColor(DS.Color.warning)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(DS.Color.warningSoft)
                                .cornerRadius(DS.Space.smallRadius)
                            }
                        }
                        .padding(.horizontal, DS.Space.cardPad)
                    }
                }
                .padding(.bottom, DS.Space.v8)
            }

            // Trainer Notes
            if let trainerNotes = card.trainerNotes, !trainerNotes.isEmpty {
                Divider().background(DS.Color.hairline)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.shield.checkmark.fill").font(.system(size: 10))
                        Text("Trainer Notes").font(DS.Typo.captionMedium)
                    }
                    .foregroundColor(DS.Color.textTer)
                    Text(trainerNotes).font(DS.Typo.body).foregroundColor(DS.Color.text)
                }
                .padding(DS.Space.cardPad)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Color.primarySoft)
                .cornerRadius(DS.Space.innerRadius)
                .padding(.horizontal, DS.Space.cardPad)
                .padding(.vertical, DS.Space.v8)
            }

            // Caption
            if let caption = card.caption, !caption.isEmpty {
                Divider().background(DS.Color.hairline)
                Text(caption).font(DS.Typo.body).foregroundColor(DS.Color.text).padding(DS.Space.cardPad)
            }

            // Client reflection
            if let reflection = card.clientReflection, !reflection.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "quote.opening").font(.system(size: 10))
                        Text("Reflection").font(DS.Typo.captionMedium)
                    }
                    .foregroundColor(DS.Color.textTer)
                    Text(reflection).font(DS.Typo.body).foregroundColor(DS.Color.text).italic()
                }
                .padding(DS.Space.cardPad)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Color.primarySoft)
                .cornerRadius(DS.Space.innerRadius)
                .padding(.horizontal, DS.Space.cardPad)
                .padding(.bottom, DS.Space.cardPad)
            }
        }
    }

    private var headerTitle: String {
        switch post.postType {
        case .workout, .workoutSummary: return "Workout Complete"
        case .weeklySummary: return "Week in Review"
        case .programCompletion: return "Program Complete"
        case .reflection: return "Reflection"
        default: return post.postType.displayName
        }
    }

    private var headerIcon: String {
        switch post.postType {
        case .workout, .workoutSummary: return "dumbbell.fill"
        case .weeklySummary: return "calendar"
        case .programCompletion: return "checkmark.seal.fill"
        case .reflection: return "text.quote"
        default: return post.postType.iconName
        }
    }

    private func prBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill").font(.system(size: 12))
            Text(count == 1 ? "PR" : "\(count) PRs").font(DS.Typo.captionMedium)
        }
        .foregroundColor(DS.Color.warning)
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(DS.Color.warningSoft)
        .cornerRadius(DS.Space.smallRadius)
    }

    private func metricItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            Text(value).font(DS.Typo.headline).foregroundColor(DS.Color.text)
            Text(label).font(DS.Typo.caption).foregroundColor(DS.Color.textTer)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60; let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }

    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
}

// MARK: - Exercise Highlight Row
public struct ExerciseHighlightRow: View {
    public let exercise: ExerciseHighlightDto

    public init(exercise: ExerciseHighlightDto) {
        self.exercise = exercise
    }

    public var body: some View {
        HStack(spacing: DS.Space.v8) {
            Circle()
                .fill(exercise.isPR == true ? DS.Color.warningSoft : DS.Color.cardHi)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: exercise.isPR == true ? "trophy.fill" : "figure.strengthtraining.traditional")
                        .font(.system(size: 12))
                        .foregroundColor(exercise.isPR == true ? DS.Color.warning : DS.Color.textSec)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(exercise.name ?? "Exercise")
                    .font(DS.Typo.callout)
                    .foregroundColor(DS.Color.text)
                if let summary = exercise.summary {
                    Text(summary).font(DS.Typo.caption).foregroundColor(DS.Color.textSec)
                }
            }

            Spacer()

            if exercise.isPR == true {
                Text("PR")
                    .font(DS.Typo.captionMedium)
                    .foregroundColor(DS.Color.warning)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(DS.Color.warningSoft)
                    .cornerRadius(DS.Space.v4)
            }
        }
        .padding(.horizontal, DS.Space.cardPad)
        .padding(.vertical, DS.Space.v4)
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
            HStack(spacing: DS.Space.v8) {
                Circle()
                    .fill(DS.Color.primarySoft)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: post.postType.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DS.Color.primary)
                    )

                Text(post.postType.displayName)
                    .font(DS.Typo.headline)
                    .foregroundColor(DS.Color.text)

                Spacer()
            }
            .padding(DS.Space.cardPad)

            if let caption = post.caption, !caption.isEmpty {
                Divider().background(DS.Color.hairline)
                Text(caption)
                    .font(DS.Typo.body)
                    .foregroundColor(DS.Color.textSec)
                    .lineLimit(2)
                    .padding(DS.Space.cardPad)
            }
        }
    }
}

// MARK: - Metric View Component (Legacy)
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
                Text(value).font(DS.Typo.headline).foregroundColor(DS.Color.text)
                if isPR {
                    Image(systemName: "trophy.fill").font(.system(size: 10)).foregroundColor(DS.Color.warning)
                }
            }
            Text(label).font(DS.Typo.caption).foregroundColor(DS.Color.textTer)
        }
        .frame(minWidth: 60)
    }
}
