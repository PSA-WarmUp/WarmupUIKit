//
//  ExerciseTabsView.swift
//  WarmupUIKit
//
//  Tabbed view for Recent/Favorites/All exercises
//

import SwiftUI

// MARK: - Exercise Tab Enum

public enum ExerciseTab: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case favorites = "Favorites"
    case all = "All"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .recent: return "clock.arrow.circlepath"
        case .favorites: return "star.fill"
        case .all: return "list.bullet"
        }
    }
}

// MARK: - Exercise Tab Selector

/// A horizontal tab selector for switching between exercise views
public struct ExerciseTabSelector: View {
    @Binding public var selectedTab: ExerciseTab

    public init(selectedTab: Binding<ExerciseTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(ExerciseTab.allCases) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedTab == tab ? .semibold : .regular)
                        }
                        .foregroundColor(selectedTab == tab ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)

                        // Indicator
                        Rectangle()
                            .fill(selectedTab == tab ? DynamicTheme.Colors.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(DynamicTheme.Colors.cardBackground)
    }
}

// MARK: - Exercise Quick Access Bar

/// Horizontal scrolling bar showing recent or favorite exercises for quick access
public struct ExerciseQuickAccessBar: View {
    public let exercises: [Exercise]
    public let onExerciseSelected: (Exercise) -> Void
    public let onShowMore: () -> Void

    public var title: String = "Recent"
    public var emptyMessage: String = "No recent exercises"

    public init(
        exercises: [Exercise],
        title: String = "Recent",
        emptyMessage: String = "No recent exercises",
        onExerciseSelected: @escaping (Exercise) -> Void,
        onShowMore: @escaping () -> Void
    ) {
        self.exercises = exercises
        self.title = title
        self.emptyMessage = emptyMessage
        self.onExerciseSelected = onExerciseSelected
        self.onShowMore = onShowMore
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)

                Spacer()

                Button(action: onShowMore) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(DynamicTheme.Colors.primary)
                }
            }
            .padding(.horizontal)

            if exercises.isEmpty {
                Text(emptyMessage)
                    .font(.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Scrollable exercise chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(exercises.prefix(10)) { exercise in
                            ExerciseChip(
                                exercise: exercise,
                                onTap: { onExerciseSelected(exercise) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .background(DynamicTheme.Colors.cardBackground.opacity(0.5))
    }
}

// MARK: - Exercise Chip

/// Compact exercise chip for quick access bar
public struct ExerciseChip: View {
    public let exercise: Exercise
    public let onTap: () -> Void

    public init(exercise: Exercise, onTap: @escaping () -> Void) {
        self.exercise = exercise
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // Category icon
                Image(systemName: categoryIcon)
                    .font(.system(size: 12))
                    .foregroundColor(DynamicTheme.Colors.primary)

                Text(exercise.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DynamicTheme.Colors.text)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DynamicTheme.Colors.background)
            .cornerRadius(DynamicTheme.Radius.round)
            .overlay(
                RoundedRectangle(cornerRadius: DynamicTheme.BorderRadius.full)
                    .stroke(DynamicTheme.Colors.border, lineWidth: 1)
            )
        }
    }

    private var categoryIcon: String {
        switch exercise.category?.lowercased() {
        case "chest": return "figure.strengthtraining.traditional"
        case "back": return "figure.rowing"
        case "legs": return "figure.run"
        case "shoulders": return "figure.arms.open"
        case "arms": return "figure.boxing"
        case "core": return "figure.core.training"
        case "cardio": return "heart.fill"
        default: return "dumbbell.fill"
        }
    }
}

// MARK: - Favorite Button

/// Toggle button for favoriting an exercise
public struct FavoriteButton: View {
    @Binding public var isFavorite: Bool
    public var onToggle: ((Bool) -> Void)?

    public init(isFavorite: Binding<Bool>, onToggle: ((Bool) -> Void)? = nil) {
        self._isFavorite = isFavorite
        self.onToggle = onToggle
    }

    public var body: some View {
        Button(action: toggle) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : DynamicTheme.Colors.textSecondary)
                .font(.system(size: 18))
        }
    }

    private func toggle() {
        isFavorite.toggle()
        onToggle?(isFavorite)
    }
}

// MARK: - Preview

#if DEBUG
struct ExerciseTabsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ExerciseTabSelector(selectedTab: .constant(.recent))

            ExerciseQuickAccessBar(
                exercises: [
                    Exercise(id: "1", name: "Bench Press", category: "Chest"),
                    Exercise(id: "2", name: "Squat", category: "Legs"),
                    Exercise(id: "3", name: "Deadlift", category: "Back"),
                ],
                onExerciseSelected: { _ in },
                onShowMore: {}
            )

            FavoriteButton(isFavorite: .constant(true))
        }
        .background(DynamicTheme.Colors.background)
    }
}
#endif
