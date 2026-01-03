//
//  ShareableWorkoutDto.swift
//  WarmupUIKit
//
//  DTO for shareable completed workouts from the workouts collection
//  Shared between trainer and client apps
//

import Foundation

/// Represents a completed workout that can be shared to the feed
public struct ShareableWorkoutDto: Codable, Identifiable {
    public let workoutId: String
    public let workoutLogId: String? // Deprecated: backend consolidated workout_logs into workouts
    public let title: String?
    public let completedAt: String?
    public let durationMinutes: Int?
    public let totalSets: Int?
    public let totalReps: Int?
    public let personalRecordsCount: Int?
    public let caloriesBurned: Int?
    public let totalVolume: Double?
    public let averageRpe: Double?
    public let workoutType: String?
    public let programName: String?
    public let exerciseHighlights: [ShareableExerciseHighlight]?
    public let alreadyShared: Bool?

    public var id: String { workoutId }

    // MARK: - Computed Properties

    public var displayTitle: String {
        title ?? workoutType ?? "Workout"
    }

    public var completedDate: Date? {
        guard let completedAt = completedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: completedAt) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: completedAt)
    }

    public var formattedCompletedAt: String {
        guard let date = completedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var formattedDuration: String? {
        guard let duration = durationMinutes else { return nil }
        if duration < 60 {
            return "\(duration)min"
        } else {
            let hours = duration / 60
            let mins = duration % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }

    public var formattedVolume: String? {
        guard let volume = totalVolume else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        if let formatted = formatter.string(from: NSNumber(value: volume)) {
            return "\(formatted) lbs"
        }
        return "\(Int(volume)) lbs"
    }

    public var hasPRs: Bool {
        guard let prCount = personalRecordsCount else { return false }
        return prCount > 0
    }

    public var formattedPRCount: String? {
        guard let prCount = personalRecordsCount, prCount > 0 else { return nil }
        return prCount == 1 ? "1 PR" : "\(prCount) PRs"
    }

    public var isAlreadyShared: Bool {
        alreadyShared ?? false
    }

    public init(workoutId: String, workoutLogId: String?, title: String?, completedAt: String?, durationMinutes: Int?, totalSets: Int?, totalReps: Int?, personalRecordsCount: Int?, caloriesBurned: Int?, totalVolume: Double?, averageRpe: Double?, workoutType: String?, programName: String?, exerciseHighlights: [ShareableExerciseHighlight]?, alreadyShared: Bool?) {
        self.workoutId = workoutId
        self.workoutLogId = workoutLogId
        self.title = title
        self.completedAt = completedAt
        self.durationMinutes = durationMinutes
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.personalRecordsCount = personalRecordsCount
        self.caloriesBurned = caloriesBurned
        self.totalVolume = totalVolume
        self.averageRpe = averageRpe
        self.workoutType = workoutType
        self.programName = programName
        self.exerciseHighlights = exerciseHighlights
        self.alreadyShared = alreadyShared
    }
}

// MARK: - Exercise Highlight for Shareable Workouts
public struct ShareableExerciseHighlight: Codable, Identifiable {
    public let exerciseName: String?
    public let summary: String?
    public let isPR: Bool?

    public var id: String { exerciseName ?? UUID().uuidString }

    // Alias for compatibility with views
    public var name: String? { exerciseName }

    public init(exerciseName: String?, summary: String?, isPR: Bool?) {
        self.exerciseName = exerciseName
        self.summary = summary
        self.isPR = isPR
    }
}
