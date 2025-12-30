//
//  TrainerExercisePreferences.swift
//  WarmupUIKit
//
//  Created by Claude Code on 12/29/25.
//

import Foundation

// MARK: - Recent Exercise Model

/// Represents an exercise that a trainer has recently used
public struct RecentExercise: Codable, Identifiable, Sendable {
    public var id: String { exerciseId }

    public let exerciseId: String
    public let exerciseName: String
    public let category: String?
    public let equipment: String?
    public let lastUsedAt: String  // ISO8601 format
    public let usageCount: Int
    public let videoS3Key: String?

    /// Computed score for sorting (recency + frequency weighted)
    public var score: Double?

    public init(
        exerciseId: String,
        exerciseName: String,
        category: String? = nil,
        equipment: String? = nil,
        lastUsedAt: String,
        usageCount: Int,
        videoS3Key: String? = nil,
        score: Double? = nil
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.category = category
        self.equipment = equipment
        self.lastUsedAt = lastUsedAt
        self.usageCount = usageCount
        self.videoS3Key = videoS3Key
        self.score = score
    }

    /// Parse last used date
    public var lastUsedDate: Date? {
        ISO8601DateFormatter().date(from: lastUsedAt)
    }
}

// MARK: - Exercise Scheme Model

/// Represents a trainer's most-used exercise configuration (sets, reps, etc.)
public struct ExerciseScheme: Codable, Identifiable, Sendable {
    public var id: String { exerciseId }

    public let exerciseId: String
    public let exerciseName: String?
    public let sets: Int
    public let reps: Int?
    public let minReps: Int?
    public let maxReps: Int?
    public let weight: Double?
    public let weightUnit: String?
    public let restSeconds: Int?
    public let effortType: String?  // "RPE" | "RIR" | nil
    public let effortValue: Int?    // 1-10 for RPE, 0-5 for RIR

    public init(
        exerciseId: String,
        exerciseName: String? = nil,
        sets: Int = 3,
        reps: Int? = 12,
        minReps: Int? = nil,
        maxReps: Int? = nil,
        weight: Double? = nil,
        weightUnit: String? = "lbs",
        restSeconds: Int? = 60,
        effortType: String? = nil,
        effortValue: Int? = nil
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.minReps = minReps
        self.maxReps = maxReps
        self.weight = weight
        self.weightUnit = weightUnit
        self.restSeconds = restSeconds
        self.effortType = effortType
        self.effortValue = effortValue
    }

    /// Get parsed effort type enum
    public var effortTypeEnum: EffortType {
        guard let effortType = effortType else { return .none }
        return EffortType(rawValue: effortType) ?? .none
    }

    /// Display string for the scheme (e.g., "3x8-12 @ RPE 8")
    public var displayString: String {
        var parts: [String] = []

        // Sets
        parts.append("\(sets)x")

        // Reps (range or single)
        if let min = minReps, let max = maxReps, min != max {
            parts.append("\(min)-\(max)")
        } else if let reps = reps {
            parts.append("\(reps)")
        }

        // Effort
        if let effortValue = effortValue {
            switch effortTypeEnum {
            case .rpe:
                parts.append("@ RPE \(effortValue)")
            case .rir:
                parts.append("@ \(effortValue) RIR")
            case .none:
                if let weight = weight {
                    parts.append("@ \(Int(weight)) \(weightUnit ?? "lbs")")
                }
            }
        }

        return parts.joined(separator: "")
    }
}

// MARK: - Smart Defaults Model

/// Smart defaults returned for an exercise based on trainer/client history
public struct SmartDefaults: Codable, Sendable {
    public let sets: Int?
    public let reps: Int?
    public let minReps: Int?
    public let maxReps: Int?
    public let weight: Double?
    public let weightUnit: String?
    public let durationSeconds: Int?
    public let restSeconds: Int?
    public let effortType: String?
    public let effortValue: Int?
    public let source: String?  // "CLIENT_HISTORY" | "TRAINER_HISTORY" | "DEFAULT"

    public init(
        sets: Int? = 3,
        reps: Int? = 12,
        minReps: Int? = nil,
        maxReps: Int? = nil,
        weight: Double? = nil,
        weightUnit: String? = "lbs",
        durationSeconds: Int? = nil,
        restSeconds: Int? = 60,
        effortType: String? = nil,
        effortValue: Int? = nil,
        source: String? = "DEFAULT"
    ) {
        self.sets = sets
        self.reps = reps
        self.minReps = minReps
        self.maxReps = maxReps
        self.weight = weight
        self.weightUnit = weightUnit
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.effortType = effortType
        self.effortValue = effortValue
        self.source = source
    }

    /// Standard fallback defaults
    public static var fallback: SmartDefaults {
        SmartDefaults(
            sets: 3,
            reps: 12,
            restSeconds: 60,
            source: "DEFAULT"
        )
    }
}

// MARK: - Trainer Preferences Model

/// Trainer's workout/exercise preferences and settings
public struct TrainerExercisePreferences: Codable, Sendable {
    public let trainerId: String

    // Default effort settings
    public let defaultEffortType: String?     // "RPE" | "RIR" | nil
    public let defaultWorkoutIntensity: Int?  // 1-10 scale

    // Default exercise settings
    public let defaultSets: Int?
    public let defaultReps: Int?
    public let defaultRestSeconds: Int?

    // Recent exercises (cached)
    public let recentExercises: [RecentExercise]?

    // Favorite exercise IDs
    public let favoriteExerciseIds: [String]?

    // Most-used exercise schemes
    public let mostUsedSchemes: [ExerciseScheme]?

    public init(
        trainerId: String,
        defaultEffortType: String? = nil,
        defaultWorkoutIntensity: Int? = nil,
        defaultSets: Int? = 3,
        defaultReps: Int? = 12,
        defaultRestSeconds: Int? = 60,
        recentExercises: [RecentExercise]? = nil,
        favoriteExerciseIds: [String]? = nil,
        mostUsedSchemes: [ExerciseScheme]? = nil
    ) {
        self.trainerId = trainerId
        self.defaultEffortType = defaultEffortType
        self.defaultWorkoutIntensity = defaultWorkoutIntensity
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestSeconds = defaultRestSeconds
        self.recentExercises = recentExercises
        self.favoriteExerciseIds = favoriteExerciseIds
        self.mostUsedSchemes = mostUsedSchemes
    }

    /// Get parsed default effort type enum
    public var defaultEffortTypeEnum: EffortType {
        guard let effortType = defaultEffortType else { return .none }
        return EffortType(rawValue: effortType) ?? .none
    }

    /// Get smart defaults for a specific exercise
    public func smartDefaults(for exerciseId: String) -> SmartDefaults? {
        guard let scheme = mostUsedSchemes?.first(where: { $0.exerciseId == exerciseId }) else {
            return nil
        }

        return SmartDefaults(
            sets: scheme.sets,
            reps: scheme.reps,
            minReps: scheme.minReps,
            maxReps: scheme.maxReps,
            weight: scheme.weight,
            weightUnit: scheme.weightUnit,
            restSeconds: scheme.restSeconds,
            effortType: scheme.effortType,
            effortValue: scheme.effortValue,
            source: "TRAINER_HISTORY"
        )
    }

    /// Check if an exercise is favorited
    public func isFavorite(_ exerciseId: String) -> Bool {
        favoriteExerciseIds?.contains(exerciseId) ?? false
    }
}

// MARK: - Update Preferences Request

/// Request model for updating trainer preferences
public struct UpdateTrainerPreferencesRequest: Codable, Sendable {
    public let defaultEffortType: String?
    public let defaultWorkoutIntensity: Int?
    public let defaultSets: Int?
    public let defaultReps: Int?
    public let defaultRestSeconds: Int?

    public init(
        defaultEffortType: String? = nil,
        defaultWorkoutIntensity: Int? = nil,
        defaultSets: Int? = nil,
        defaultReps: Int? = nil,
        defaultRestSeconds: Int? = nil
    ) {
        self.defaultEffortType = defaultEffortType
        self.defaultWorkoutIntensity = defaultWorkoutIntensity
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestSeconds = defaultRestSeconds
    }
}

// MARK: - Record Usage Request

/// Request model for recording exercise usage
public struct RecordExerciseUsageRequest: Codable, Sendable {
    public let context: String  // "WORKOUT_CREATION" | "WORKOUT_COMPLETION"
    public let workoutId: String?
    public let clientId: String?
    public let scheme: ExerciseScheme?

    public init(
        context: String,
        workoutId: String? = nil,
        clientId: String? = nil,
        scheme: ExerciseScheme? = nil
    ) {
        self.context = context
        self.workoutId = workoutId
        self.clientId = clientId
        self.scheme = scheme
    }
}
