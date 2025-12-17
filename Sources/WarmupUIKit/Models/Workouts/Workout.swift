//
//  Workout.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 6/17/25.
//

import Foundation

// MARK: - Main Workout Model (CORRECT VERSION)
public struct Workout: Codable, Identifiable {
    /// Workout ID - may be nil for unsaved drafts from AI generation
    private let _id: String?

    /// Stable generated ID for drafts (generated once during decoding/init)
    private let _generatedId: String

    /// Identifiable conformance - uses real ID or stable generated ID for drafts
    public var id: String {
        _id ?? _generatedId
    }

    public let programId: String?
    public let trainerId: String?
    public let clientId: String?
    public var isSaved: Bool?
    public var originalWorkoutId: String?
    public var timesUsed: Int?
    public var lastUsedAt: String? // ISO8601 format

    /// Whether this workout has been persisted to the database
    public var isPersisted: Bool {
        _id != nil && !_id!.isEmpty
    }

    /// The actual database ID (nil for drafts)
    public var databaseId: String? {
        _id
    }

    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case programId, trainerId, clientId, isSaved, originalWorkoutId
        case timesUsed, lastUsedAt, proposedDate, scheduledDate, schedulingStatus
        case proposedBy, proposedAt, acceptedAt, completedAt, title, notesRaw
        case notesStructured, processingStatus, processingError, attachments
        case date, status, createdAt, updatedAt
        // Note: _generatedId is not encoded - it's transient
    }

    // Custom decoder to generate stable ID for drafts
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        _generatedId = "draft_\(UUID().uuidString)"

        programId = try container.decodeIfPresent(String.self, forKey: .programId)
        trainerId = try container.decodeIfPresent(String.self, forKey: .trainerId)
        clientId = try container.decodeIfPresent(String.self, forKey: .clientId)
        isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved)
        originalWorkoutId = try container.decodeIfPresent(String.self, forKey: .originalWorkoutId)
        timesUsed = try container.decodeIfPresent(Int.self, forKey: .timesUsed)
        lastUsedAt = try container.decodeIfPresent(String.self, forKey: .lastUsedAt)
        proposedDate = try container.decodeIfPresent(String.self, forKey: .proposedDate)
        scheduledDate = try container.decodeIfPresent(String.self, forKey: .scheduledDate)
        schedulingStatus = try container.decodeIfPresent(String.self, forKey: .schedulingStatus)
        proposedBy = try container.decodeIfPresent(String.self, forKey: .proposedBy)
        proposedAt = try container.decodeIfPresent(String.self, forKey: .proposedAt)
        acceptedAt = try container.decodeIfPresent(String.self, forKey: .acceptedAt)
        completedAt = try container.decodeIfPresent(String.self, forKey: .completedAt)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        notesRaw = try container.decodeIfPresent(String.self, forKey: .notesRaw)
        notesStructured = try container.decodeIfPresent(WorkoutStructure.self, forKey: .notesStructured)
        processingStatus = try container.decodeIfPresent(String.self, forKey: .processingStatus)
        processingError = try container.decodeIfPresent(String.self, forKey: .processingError)
        attachments = try container.decodeIfPresent([String].self, forKey: .attachments)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }

    // Scheduling fields
    public let proposedDate: String?  // ISO8601 format
    public let scheduledDate: String? // ISO8601 format
    public let schedulingStatus: String? // DRAFT, PROPOSED, ACCEPTED, SCHEDULED, IN_PROGRESS, COMPLETED
    public let proposedBy: String? // trainerId or clientId
    public let proposedAt: String? // ISO8601 format
    public let acceptedAt: String? // ISO8601 format
    public let completedAt: String?

    // Content fields
    public let title: String?
    public let notesRaw: String? // Original free-form notes
    public let notesStructured: WorkoutStructure? // Parsed sections

    // Processing fields
    public let processingStatus: String? // PENDING, PROCESSING, COMPLETED, FAILED
    public let processingError: String? // If OpenAI processing fails

    // Attachments
    public let attachments: [String]? // S3 keys

    // Legacy compatibility fields
    public let date: String? // ISO8601 format - can be derived from scheduledDate
    public let status: String? // Can be derived from schedulingStatus

    // Audit fields
    public let createdAt: String? // ISO8601 format
    public let updatedAt: String? // ISO8601 format

    // MARK: - Initializer

    /// Full memberwise initializer
    /// - Parameter id: Workout ID (can be nil for drafts, will generate temp ID for Identifiable)
    public init(
        id: String?,
        programId: String? = nil,
        trainerId: String? = nil,
        clientId: String? = nil,
        isSaved: Bool? = nil,
        originalWorkoutId: String? = nil,
        timesUsed: Int? = nil,
        lastUsedAt: String? = nil,
        proposedDate: String? = nil,
        scheduledDate: String? = nil,
        schedulingStatus: String? = nil,
        proposedBy: String? = nil,
        proposedAt: String? = nil,
        acceptedAt: String? = nil,
        completedAt: String? = nil,
        title: String? = nil,
        notesRaw: String? = nil,
        notesStructured: WorkoutStructure? = nil,
        processingStatus: String? = nil,
        processingError: String? = nil,
        attachments: [String]? = nil,
        date: String? = nil,
        status: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self._id = id
        self._generatedId = "draft_\(UUID().uuidString)"
        self.programId = programId
        self.trainerId = trainerId
        self.clientId = clientId
        self.isSaved = isSaved
        self.originalWorkoutId = originalWorkoutId
        self.timesUsed = timesUsed
        self.lastUsedAt = lastUsedAt
        self.proposedDate = proposedDate
        self.scheduledDate = scheduledDate
        self.schedulingStatus = schedulingStatus
        self.proposedBy = proposedBy
        self.proposedAt = proposedAt
        self.acceptedAt = acceptedAt
        self.completedAt = completedAt
        self.title = title
        self.notesRaw = notesRaw
        self.notesStructured = notesStructured
        self.processingStatus = processingStatus
        self.processingError = processingError
        self.attachments = attachments
        self.date = date
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties for Date Conversion
    public var workoutDate: Date? {
        if let dateString = date {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var proposedWorkoutDate: Date? {
        if let dateString = proposedDate {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var scheduledWorkoutDate: Date? {
        if let dateString = scheduledDate {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var proposedAtDate: Date? {
        if let dateString = proposedAt {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var acceptedAtDate: Date? {
        if let dateString = acceptedAt {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var createdAtDate: Date? {
        if let dateString = createdAt {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    public var updatedAtDate: Date? {
        if let dateString = updatedAt {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }

    // MARK: - Convenience Properties
    public var isCompleted: Bool {
        return schedulingStatus == "COMPLETED" || status == "COMPLETED"
    }

    public var isSavedWorkout: Bool {
        return isSaved ?? false
    }

    public var usageCount: Int {
        return timesUsed ?? 0
    }

    public var lastUsedDate: Date? {
        guard let dateString = lastUsedAt else { return nil }
        return ISO8601DateFormatter().date(from: dateString)
    }

    public var isPending: Bool {
        return processingStatus == "PENDING"
    }

    public var isProcessing: Bool {
        return processingStatus == "PROCESSING"
    }

    public var hasProcessingError: Bool {
        return processingStatus == "FAILED" && processingError != nil
    }

    public var isProposed: Bool {
        return schedulingStatus == "PROPOSED"
    }

    public var isScheduled: Bool {
        return schedulingStatus == "SCHEDULED" || schedulingStatus == "ACCEPTED"
    }


    public var hasStructuredData: Bool {
        return notesStructured != nil
    }

    // MARK: - UI Helper Properties for Generative UI Cards

    /// Summary string for display in cards, e.g., "Legs • 45 mins • 6 Exercises"
    public var summaryString: String {
        var parts: [String] = []

        // Add session type or title as focus
        if let sessionType = notesStructured?.sessionType, !sessionType.isEmpty {
            parts.append(sessionType)
        } else if let title = title, !title.isEmpty {
            parts.append(title)
        }

        // Calculate total exercises count
        let exerciseCount = totalExerciseCount
        if exerciseCount > 0 {
            parts.append("\(exerciseCount) Exercise\(exerciseCount == 1 ? "" : "s")")
        }

        // Calculate estimated duration if available
        if let duration = estimatedDurationMinutes, duration > 0 {
            parts.append("\(duration) mins")
        }

        return parts.isEmpty ? "Workout" : parts.joined(separator: " • ")
    }

    /// Primary focus derived from exercise categories (e.g., "Strength", "Cardio", "Mobility")
    public var primaryFocus: String {
        guard let sections = notesStructured?.sections else {
            return "General"
        }

        // Collect all exercise categories
        var categoryCounts: [String: Int] = [:]
        for section in sections {
            guard let exercises = section.exercises else { continue }
            for exercise in exercises {
                if let category = exercise.category, !category.isEmpty {
                    let normalizedCategory = category.lowercased()
                    categoryCounts[normalizedCategory, default: 0] += 1
                }
            }
        }

        // Find most frequent category
        guard let topCategory = categoryCounts.max(by: { $0.value < $1.value })?.key else {
            // Fallback: derive from section names
            return deriveFocusFromSectionNames(sections)
        }

        return topCategory.capitalized
    }

    /// Total count of exercises across all sections
    public var totalExerciseCount: Int {
        guard let sections = notesStructured?.sections else { return 0 }
        return sections.reduce(0) { $0 + ($1.exercises?.count ?? 0) }
    }

    /// Estimated workout duration in minutes (can be nil if not calculable)
    public var estimatedDurationMinutes: Int? {
        guard let sections = notesStructured?.sections else { return nil }

        var totalSeconds = 0
        for section in sections {
            guard let exercises = section.exercises else { continue }
            for exercise in exercises {
                // Add duration from exercise if time-based
                if let duration = exercise.durationSeconds {
                    totalSeconds += duration
                }
                // Add rest time
                if let rest = exercise.restSeconds {
                    totalSeconds += rest
                }
                // Estimate time for rep-based exercises (approx 30 sec per set)
                if let sets = exercise.sets, !sets.isEmpty {
                    totalSeconds += sets.count * 30
                }
            }
        }

        let minutes = totalSeconds / 60
        return minutes > 0 ? minutes : nil
    }

    /// Derive focus from section names when categories aren't available
    private func deriveFocusFromSectionNames(_ sections: [WorkoutSection]) -> String {
        let sectionNames = sections.compactMap { $0.name.lowercased() }

        // Common workout focus keywords
        let focusKeywords: [(keywords: [String], focus: String)] = [
            (["strength", "power", "heavy"], "Strength"),
            (["cardio", "hiit", "conditioning", "endurance"], "Cardio"),
            (["mobility", "stretch", "flexibility", "warmup", "warm-up"], "Mobility"),
            (["upper", "chest", "back", "shoulders", "arms"], "Upper Body"),
            (["lower", "legs", "glutes", "quads", "hamstrings"], "Lower Body"),
            (["core", "abs", "abdominal"], "Core"),
            (["full body", "total body"], "Full Body")
        ]

        for (keywords, focus) in focusKeywords {
            for sectionName in sectionNames {
                if keywords.contains(where: { sectionName.contains($0) }) {
                    return focus
                }
            }
        }

        return "General"
    }

    // MARK: - Draft State & Issue Tracking

    /// Returns all exercises in the draft that are not persisted (missing from exercise library)
    /// These are exercises generated by AI that need to be linked or created
    public var missingExercises: [SectionExercise] {
        guard let sections = notesStructured?.sections else { return [] }

        var missing: [SectionExercise] = []
        for section in sections {
            guard let exercises = section.exercises else { continue }
            for exercise in exercises {
                if !exercise.isPersisted {
                    missing.append(exercise)
                }
            }
        }
        return missing
    }

    /// Returns exercises that need to be linked to the exercise library
    public var exercisesNeedingLinking: [SectionExercise] {
        guard let sections = notesStructured?.sections else { return [] }

        var needsLinking: [SectionExercise] = []
        for section in sections {
            guard let exercises = section.exercises else { continue }
            for exercise in exercises {
                if exercise.needsExerciseLinking {
                    needsLinking.append(exercise)
                }
            }
        }
        return needsLinking
    }

    /// Count of exercises that are not persisted
    public var missingExerciseCount: Int {
        return missingExercises.count
    }

    /// Check if draft has any issues that need attention
    public var hasIssues: Bool {
        return !missingExercises.isEmpty || hasProcessingError
    }

    /// Get a summary of issues in the draft
    public var issuesSummary: [WorkoutDraftIssue] {
        var issues: [WorkoutDraftIssue] = []

        // Check for missing/unlinked exercises
        let missing = missingExercises
        if !missing.isEmpty {
            issues.append(.missingExercises(count: missing.count, exercises: missing))
        }

        // Check for processing errors
        if hasProcessingError, let error = processingError {
            issues.append(.processingError(message: error))
        }

        // Check for missing title
        if title == nil || title?.isEmpty == true {
            issues.append(.missingTitle)
        }

        // Check for empty workout
        if totalExerciseCount == 0 {
            issues.append(.noExercises)
        }

        return issues
    }

    /// Check if the draft is ready to be saved
    public var isReadyToSave: Bool {
        // Must have a title
        guard let title = title, !title.isEmpty else { return false }
        // Must have at least one exercise
        guard totalExerciseCount > 0 else { return false }
        // Should not have processing errors
        guard !hasProcessingError else { return false }
        return true
    }
}

// MARK: - Workout Draft Issue Types

/// Represents issues that can occur in a workout draft
public enum WorkoutDraftIssue: Equatable {
    case missingExercises(count: Int, exercises: [SectionExercise])
    case processingError(message: String)
    case missingTitle
    case noExercises

    public var description: String {
        switch self {
        case .missingExercises(let count, _):
            return "\(count) exercise\(count == 1 ? "" : "s") not found in library"
        case .processingError(let message):
            return "Processing error: \(message)"
        case .missingTitle:
            return "Workout needs a title"
        case .noExercises:
            return "No exercises in workout"
        }
    }

    public var severity: IssueSeverity {
        switch self {
        case .missingExercises:
            return .warning  // Can still save, exercises will be created
        case .processingError:
            return .error
        case .missingTitle:
            return .warning
        case .noExercises:
            return .error
        }
    }

    public static func == (lhs: WorkoutDraftIssue, rhs: WorkoutDraftIssue) -> Bool {
        switch (lhs, rhs) {
        case (.missingExercises(let c1, _), .missingExercises(let c2, _)):
            return c1 == c2
        case (.processingError(let m1), .processingError(let m2)):
            return m1 == m2
        case (.missingTitle, .missingTitle):
            return true
        case (.noExercises, .noExercises):
            return true
        default:
            return false
        }
    }
}

public enum IssueSeverity {
    case warning
    case error

    public var color: String {
        switch self {
        case .warning: return "orange"
        case .error: return "red"
        }
    }
}

// MARK: - Workout Structure Models
public struct WorkoutStructure: Codable {
    public let sessionType: String? // e.g., "Upper Body Day"
    public let clientName: String?
    public let sections: [WorkoutSection]?
    public let notes: String?

    /// Memberwise initializer for programmatic creation
    public init(
        sessionType: String? = nil,
        clientName: String? = nil,
        sections: [WorkoutSection]? = nil,
        notes: String? = nil
    ) {
        self.sessionType = sessionType
        self.clientName = clientName
        self.sections = sections
        self.notes = notes
    }
}

public struct WorkoutSection: Codable, Identifiable {
    public let id: String?
    public let name: String
    public let description: String?
    public var exercises: [SectionExercise]?
    public let notes: String?
    public let orderIndex: Int?

    public var isEmpty: Bool {
        return exercises?.isEmpty ?? true
    }

    public var exerciseCount: Int {
        return exercises?.count ?? 0
    }

    // Default initializer
    public init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        exercises: [SectionExercise]? = nil,
        notes: String? = nil,
        orderIndex: Int? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.description = description
        self.exercises = exercises
        self.notes = notes
        self.orderIndex = orderIndex
    }

    // MARK: - DTO Conversion

    /// Convert to API-compatible WorkoutSectionDto
    public func toApiDto() -> WorkoutSectionDto {
        return WorkoutSectionDto(
            name: name,
            description: description,
            exercises: exercises?.map { $0.toDto() },
            notes: notes
        )
    }

    /// Convert to wizard-compatible WizardSectionDto
    public func toWizardDto() -> WizardSectionDto {
        return WizardSectionDto(
            id: id ?? UUID().uuidString,
            name: name,
            description: description,
            exercises: exercises?.map { WizardExerciseDto.from($0) },
            notes: notes
        )
    }
}

// MARK: - Section Exercise Model (matches backend ExerciseDto)

public struct SectionExercise: Codable, Identifiable {
    public let id: String?
    public let exerciseId: String?
    public let name: String
    public let category: String?
    public var sets: [ExerciseSet]?
    public let instructions: String?
    public let equipment: String?
    public let tags: [String]?
    public var notes: String?
    public let orderIndex: Int?
    public let reps: Int?
    public let durationSeconds: Int?
    public let weight: Double?
    public let weightUnit: String?
    public let restSeconds: Int?
    public let videoS3Key: String?

    // Computed property for set count
    public var setCount: Int {
        return sets?.count ?? 0
    }

    // MARK: - Transient Exercise Support

    /// Returns true if this exercise has been persisted to the database
    /// Exercises are considered persisted if they have a valid exerciseId linking to the exercise library
    public var isPersisted: Bool {
        // Check if we have a valid exerciseId (link to exercise library)
        if let exerciseId = exerciseId, !exerciseId.isEmpty {
            return !isTemporaryId(exerciseId)
        }
        // No exerciseId means this is a transient exercise (e.g., from AI generation)
        return false
    }

    /// Check if the exercise name matches a known exercise in the database
    /// Used to identify exercises that need to be linked or created
    public var needsExerciseLinking: Bool {
        return exerciseId == nil || exerciseId?.isEmpty == true
    }

    /// Check if an ID looks like a temporary/transient ID
    private func isTemporaryId(_ id: String) -> Bool {
        return id.lowercased().hasPrefix("draft_") ||
               id.lowercased().hasPrefix("ai_") ||
               id.lowercased().hasPrefix("new_") ||
               id.lowercased().hasPrefix("temp_")
    }

    // Convenience initializer
    public init(
        id: String? = nil,
        exerciseId: String? = nil,
        name: String,
        category: String? = nil,
        sets: [ExerciseSet]? = nil,
        instructions: String? = nil,
        equipment: String? = nil,
        tags: [String]? = nil,
        notes: String? = nil,
        orderIndex: Int? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil,
        weight: Double? = nil,
        weightUnit: String? = nil,
        restSeconds: Int? = nil,
        videoS3Key: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.sets = sets
        self.instructions = instructions
        self.equipment = equipment
        self.tags = tags
        self.notes = notes
        self.orderIndex = orderIndex
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.weight = weight
        self.weightUnit = weightUnit
        self.restSeconds = restSeconds
        self.videoS3Key = videoS3Key
    }
}

extension SectionExercise {
    public func toDto() -> SectionExerciseDto {
        SectionExerciseDto(
            id: id,
            exerciseId: exerciseId,
            name: name,
            sets: sets?.map { $0.toDto() },
            reps: reps,
            durationSeconds: durationSeconds,
            weight: weight,
            weightUnit: weightUnit,
            restSeconds: restSeconds,
            instructions: instructions,
            equipment: equipment,
            tags: tags,
            videoS3Key: videoS3Key
        )
    }
}

// MARK: - ExerciseSet Model
public struct ExerciseSet: Codable, Identifiable, Equatable {
    public let id: String?
    public var reps: Int?
    public var weight: String?     // Store as String to match backend
    public var rpe: String?        // Store as String to match backend
    public var tempo: String?
    public var duration: Int?
    public var rest: String?       // Store as String to match backend
    public var notes: String?

    // Computed properties for numeric access
    public var weightValue: Double? {
        guard let weight = weight else { return nil }
        return Double(weight)
    }

    public var rpeValue: Int? {
        guard let rpe = rpe else { return nil }
        return Int(rpe)
    }

    public var restValue: Int? {
        guard let rest = rest else { return nil }
        return Int(rest)
    }

    // Initialize with either strings or numbers for convenience
    public init(
        id: String? = nil,
        reps: Int? = nil,
        weight: Double? = nil,  // Accept Double for convenience
        rpe: Int? = nil,        // Accept Int for convenience
        tempo: String? = nil,
        rest: Int? = nil,        // Accept Int for convenience
        notes: String? = nil,
        duration: Int? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.reps = reps
        self.weight = weight != nil ? "\(weight!)" : nil  // Convert to String
        self.rpe = rpe != nil ? "\(rpe!)" : nil           // Convert to String
        self.tempo = tempo
        self.rest = rest != nil ? "\(rest!)" : nil        // Convert to String
        self.notes = notes
        self.duration = duration
    }

    public var isTimeBased: Bool {
        duration != nil
    }

    public var isRepBased: Bool {
        reps != nil
    }
}

// Fix the toDto extension
extension ExerciseSet {
    public func toDto() -> ExerciseSetDto {
        ExerciseSetDto(
            reps: reps,
            weight: weight,     // Already a String?
            rpe: rpe,          // Already a String?
            tempo: tempo,
            rest: rest,        // Already a String?
            notes: notes
        )
    }
}

public struct WorkoutExercise: Codable, Identifiable, Hashable {
    public let id: String?
    public let name: String
    public var sets: Int = 3
    public var reps: Int? = 12
    public var weight: Double?
    public var weightUnit: String = "lbs"
    public var durationSeconds: Int?
    public var restSeconds: Int = 60
    public var notes: String?
    public var videoS3Key: String? // Keep this for backward compatibility

    // Implement Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id
    }

    public var isTimeBased: Bool {
        return durationSeconds != nil && durationSeconds! > 0
    }

    // Custom initializer that supports all parameters (including videoS3Key for backward compatibility)
    public init(id: String = UUID().uuidString,
         name: String,
         sets: Int = 3,
         reps: Int? = nil,
         weight: Double? = nil,
         weightUnit: String = "lbs",
         durationSeconds: Int? = nil,
         restSeconds: Int = 60,
         notes: String? = nil,
         videoS3Key: String? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.notes = notes
        self.videoS3Key = videoS3Key
    }

    public func toSectionExercise() -> SectionExercise {
        let simpleReps = isTimeBased ? nil : reps
        let simpleDuration = isTimeBased ? durationSeconds : nil

        var exerciseSets: [ExerciseSet] = []
        for _ in 0..<sets {
            exerciseSets.append(
                ExerciseSet(
                    reps: isTimeBased ? nil : reps,
                    weight: weight,          // Pass as Double, init converts to String
                    rpe: nil,
                    tempo: nil,
                    rest: restSeconds,       // Pass as Int, init converts to String
                    notes: nil
                )
            )
        }

        return SectionExercise(
            id: id,
            exerciseId: nil,
            name: name,
            category: nil,
            sets: exerciseSets.isEmpty ? nil : exerciseSets,
            instructions: nil,
            equipment: nil,
            tags: nil,
            notes: notes,
            orderIndex: nil,
            reps: simpleReps,
            durationSeconds: simpleDuration,
            weight: weight,
            weightUnit: weight != nil ? weightUnit : nil,
            restSeconds: restSeconds,
            videoS3Key: videoS3Key
        )
    }

    // Fix the from method in WorkoutExercise
    public static func from(_ sectionExercise: SectionExercise) -> WorkoutExercise? {
        let firstSet = sectionExercise.sets?.first

        // Use weightValue computed property to convert String to Double
        let weightValue: Double? = sectionExercise.weight ?? firstSet?.weightValue
        let unit: String = sectionExercise.weightUnit ?? "lbs"
        let restValue: Int = sectionExercise.restSeconds ?? firstSet?.restValue ?? 60

        if let duration = sectionExercise.durationSeconds {
            return WorkoutExercise(
                id: sectionExercise.id ?? UUID().uuidString,
                name: sectionExercise.name,
                sets: sectionExercise.setCount > 0 ? sectionExercise.setCount : 1,
                reps: nil,
                weight: weightValue,
                weightUnit: unit,
                durationSeconds: duration,
                restSeconds: restValue,
                notes: sectionExercise.notes,
                videoS3Key: sectionExercise.videoS3Key
            )
        }

        return WorkoutExercise(
            id: sectionExercise.id ?? UUID().uuidString,
            name: sectionExercise.name,
            sets: sectionExercise.setCount > 0 ? sectionExercise.setCount : 1,
            reps: sectionExercise.reps ?? firstSet?.reps,
            weight: weightValue,
            weightUnit: unit,
            durationSeconds: nil,
            restSeconds: restValue,
            notes: sectionExercise.notes,
            videoS3Key: sectionExercise.videoS3Key
        )
    }
}

// MARK: - Status Enums for Type Safety
public enum WorkoutSchedulingStatus: String, CaseIterable {
    case draft = "DRAFT"
    case proposed = "PROPOSED"
    case accepted = "ACCEPTED"
    case scheduled = "SCHEDULED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"

    public var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .proposed: return "Proposed"
        case .accepted: return "Accepted"
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    public var color: String {
        switch self {
        case .draft: return "gray"
        case .proposed: return "orange"
        case .accepted: return "blue"
        case .scheduled: return "green"
        case .inProgress: return "purple"
        case .completed:         return "green"
        }
    }
}

// MARK: - Workout Statistics Model
public struct WorkoutStats: Codable {
    public let totalWorkouts: Int
    public let completedWorkouts: Int
    public let upcomingWorkouts: Int
    public let overdueWorkouts: Int
    public let completionRate: Double
    public let currentStreak: Int?
    public let longestStreak: Int?
    public let consistencyScore: Double?
    public let lastCompletedDate: String? // ISO8601 format

    // Computed properties
    public var completionPercentage: Double {
        guard totalWorkouts > 0 else { return 0.0 }
        return (Double(completedWorkouts) / Double(totalWorkouts)) * 100.0
    }

    public var lastCompletedDateFormatted: Date? {
        guard let dateString = lastCompletedDate else { return nil }
        return ISO8601DateFormatter().date(from: dateString)
    }

    public var consistencyPercentage: Double {
        return (consistencyScore ?? 0.0) * 100.0
    }

    // Convenience initializer
    public init(totalWorkouts: Int = 0,
         completedWorkouts: Int = 0,
         upcomingWorkouts: Int = 0,
         overdueWorkouts: Int = 0,
         completionRate: Double = 0.0,
         currentStreak: Int? = nil,
         longestStreak: Int? = nil,
         consistencyScore: Double? = nil,
         lastCompletedDate: String? = nil) {
        self.totalWorkouts = totalWorkouts
        self.completedWorkouts = completedWorkouts
        self.upcomingWorkouts = upcomingWorkouts
        self.overdueWorkouts = overdueWorkouts
        self.completionRate = completionRate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.consistencyScore = consistencyScore
        self.lastCompletedDate = lastCompletedDate
    }

    // Create empty stats
    public static var empty: WorkoutStats {
        return WorkoutStats()
    }
}

// MARK: - Progress Summary Model (Extended Analytics)
public struct ProgressSummary: Codable {
    public let totalWorkouts: Int
    public let completedWorkouts: Int
    public let completionRate: Double
    public let totalExercises: Int
    public let personalRecords: Int
    public let totalVolumeLifted: Double
    public let totalMinutes: Int
    public let workoutsByType: [String: Int]?
    public let topExercises: [WorkoutExerciseAnalytics]?
    public let trends: TrendData?

    public var averageWorkoutDuration: Double {
        guard totalWorkouts > 0 else { return 0.0 }
        return Double(totalMinutes) / Double(totalWorkouts)
    }

    public init(
        totalWorkouts: Int,
        completedWorkouts: Int,
        completionRate: Double,
        totalExercises: Int,
        personalRecords: Int,
        totalVolumeLifted: Double,
        totalMinutes: Int,
        workoutsByType: [String: Int]? = nil,
        topExercises: [WorkoutExerciseAnalytics]? = nil,
        trends: TrendData? = nil
    ) {
        self.totalWorkouts = totalWorkouts
        self.completedWorkouts = completedWorkouts
        self.completionRate = completionRate
        self.totalExercises = totalExercises
        self.personalRecords = personalRecords
        self.totalVolumeLifted = totalVolumeLifted
        self.totalMinutes = totalMinutes
        self.workoutsByType = workoutsByType
        self.topExercises = topExercises
        self.trends = trends
    }
}

// MARK: - Supporting Analytics Models
public struct WorkoutExerciseAnalytics: Codable {
    public let exerciseName: String
    public let totalSets: Int
    public let totalReps: Int
    public let maxWeight: Double?
    public let totalVolume: Double?
    public let improvementPercentage: Double?

    public init(
        exerciseName: String,
        totalSets: Int,
        totalReps: Int,
        maxWeight: Double? = nil,
        totalVolume: Double? = nil,
        improvementPercentage: Double? = nil
    ) {
        self.exerciseName = exerciseName
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.maxWeight = maxWeight
        self.totalVolume = totalVolume
        self.improvementPercentage = improvementPercentage
    }
}

public struct TrendData: Codable {
    public let weeklyWorkoutTrend: [Double]?
    public let volumeTrend: [Double]?
    public let strengthTrend: [Double]?
    public let consistencyTrend: [Double]?

    public init(
        weeklyWorkoutTrend: [Double]? = nil,
        volumeTrend: [Double]? = nil,
        strengthTrend: [Double]? = nil,
        consistencyTrend: [Double]? = nil
    ) {
        self.weeklyWorkoutTrend = weeklyWorkoutTrend
        self.volumeTrend = volumeTrend
        self.strengthTrend = strengthTrend
        self.consistencyTrend = consistencyTrend
    }
}

// MARK: - Workout Streak Model
public struct WorkoutStreak: Codable {
    public let currentStreak: Int
    public let longestStreak: Int
    public let streakStartDate: String? // ISO8601 format
    public let lastWorkoutDate: String? // ISO8601 format
    public let totalWorkouts: Int
    public let averageWorkoutsPerWeek: Double
    public let weeklyActivity: [Int]? // Last 12 weeks

    public var streakStartDateFormatted: Date? {
        guard let dateString = streakStartDate else { return nil }
        return ISO8601DateFormatter().date(from: dateString)
    }

    public var lastWorkoutDateFormatted: Date? {
        guard let dateString = lastWorkoutDate else { return nil }
        return ISO8601DateFormatter().date(from: dateString)
    }

    public init(
        currentStreak: Int,
        longestStreak: Int,
        streakStartDate: String? = nil,
        lastWorkoutDate: String? = nil,
        totalWorkouts: Int,
        averageWorkoutsPerWeek: Double,
        weeklyActivity: [Int]? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.streakStartDate = streakStartDate
        self.lastWorkoutDate = lastWorkoutDate
        self.totalWorkouts = totalWorkouts
        self.averageWorkoutsPerWeek = averageWorkoutsPerWeek
        self.weeklyActivity = weeklyActivity
    }
}

// MARK: - DTO Models for API Communication
public struct SectionExerciseDto: Codable {
    public let id: String?
    public let exerciseId: String?
    public let name: String
    public let sets: [ExerciseSetDto]?
    public let reps: Int?
    public let durationSeconds: Int?
    public let weight: Double?
    public let weightUnit: String?
    public let restSeconds: Int?
    public let instructions: String?
    public let equipment: String?
    public let tags: [String]?
    public let videoS3Key: String?
    public let notes: String?

    // Simplified initializer for common use cases
    public init(name: String, sets: [ExerciseSetDto]? = nil, notes: String? = nil) {
        self.id = nil
        self.exerciseId = nil
        self.name = name
        self.sets = sets
        self.reps = nil
        self.durationSeconds = nil
        self.weight = nil
        self.weightUnit = nil
        self.restSeconds = nil
        self.instructions = nil
        self.equipment = nil
        self.tags = nil
        self.videoS3Key = nil
        self.notes = notes
    }

    // Full initializer
    public init(
        id: String? = nil,
        exerciseId: String? = nil,
        name: String,
        sets: [ExerciseSetDto]? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil,
        weight: Double? = nil,
        weightUnit: String? = nil,
        restSeconds: Int? = nil,
        instructions: String? = nil,
        equipment: String? = nil,
        tags: [String]? = nil,
        videoS3Key: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.weight = weight
        self.weightUnit = weightUnit
        self.restSeconds = restSeconds
        self.instructions = instructions
        self.equipment = equipment
        self.tags = tags
        self.videoS3Key = videoS3Key
        self.notes = nil
    }
}

public struct ExerciseSetDto: Codable {
    public let reps: Int?
    public let weight: String?
    public let rpe: String?
    public let tempo: String?
    public let rest: String?
    public let notes: String?

    public init(
        reps: Int? = nil,
        weight: String? = nil,
        rpe: String? = nil,
        tempo: String? = nil,
        rest: String? = nil,
        notes: String? = nil
    ) {
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.tempo = tempo
        self.rest = rest
        self.notes = notes
    }
}

public struct WorkoutSectionDto: Codable {
    public let name: String
    public let description: String?
    public let exercises: [SectionExerciseDto]?
    public let notes: String?

    public init(
        name: String,
        description: String? = nil,
        exercises: [SectionExerciseDto]? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.description = description
        self.exercises = exercises
        self.notes = notes
    }
}

// MARK: - Wizard Section DTO for Draft
/// Section model for the workout wizard, uses WizardExerciseDto
public struct WizardSectionDto: Codable, Identifiable {
    public var id: String
    public var name: String
    public var description: String?
    public var exercises: [WizardExerciseDto]?
    public var notes: String?

    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        exercises: [WizardExerciseDto]? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.notes = notes
    }

    public var isEmpty: Bool {
        exercises?.isEmpty ?? true
    }

    public var exerciseCount: Int {
        exercises?.count ?? 0
    }
}

// MARK: - Exercise DTO for Wizard Draft
/// Lightweight exercise representation for the workout wizard
/// Named WizardExerciseDto to avoid conflict with ExerciseDto in ProgramModels
public struct WizardExerciseDto: Codable, Identifiable {
    public var id: String
    public var exerciseId: String?  // Link to exercise library
    public var name: String
    public var category: String?
    public var sets: [ExerciseSetDto]?
    public var reps: Int?
    public var durationSeconds: Int?
    public var weight: Double?
    public var weightUnit: String?
    public var restSeconds: Int?
    public var instructions: String?
    public var equipment: String?
    public var tags: [String]?
    public var videoS3Key: String?
    public var notes: String?
    public var orderIndex: Int?

    /// Source of this exercise data (for smart defaults)
    public var source: ExerciseSource?

    public enum ExerciseSource: String, Codable {
        case ai = "AI"           // Generated by AI
        case library = "LIBRARY" // From exercise library
        case manual = "MANUAL"   // Manually entered
        case history = "HISTORY" // From workout history/PR
    }

    public init(
        id: String = UUID().uuidString,
        exerciseId: String? = nil,
        name: String,
        category: String? = nil,
        sets: [ExerciseSetDto]? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil,
        weight: Double? = nil,
        weightUnit: String? = nil,
        restSeconds: Int? = nil,
        instructions: String? = nil,
        equipment: String? = nil,
        tags: [String]? = nil,
        videoS3Key: String? = nil,
        notes: String? = nil,
        orderIndex: Int? = nil,
        source: ExerciseSource? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.weight = weight
        self.weightUnit = weightUnit
        self.restSeconds = restSeconds
        self.instructions = instructions
        self.equipment = equipment
        self.tags = tags
        self.videoS3Key = videoS3Key
        self.notes = notes
        self.orderIndex = orderIndex
        self.source = source
    }

    /// Check if this exercise has a video attached
    public var hasVideo: Bool {
        videoS3Key != nil && !videoS3Key!.isEmpty
    }

    /// Check if this exercise is linked to the library
    public var isLinkedToLibrary: Bool {
        exerciseId != nil && !exerciseId!.isEmpty
    }

    /// Check if this is a time-based exercise
    public var isTimeBased: Bool {
        durationSeconds != nil && durationSeconds! > 0
    }

    /// Get set count
    public var setCount: Int {
        sets?.count ?? 0
    }

    /// Create from library Exercise
    public static func from(_ exercise: Exercise) -> WizardExerciseDto {
        WizardExerciseDto(
            exerciseId: exercise.id,
            name: exercise.name,
            category: exercise.category,
            durationSeconds: exercise.isTimeBasedExercise ? 30 : nil,
            equipment: exercise.equipment,
            tags: exercise.tags,
            videoS3Key: exercise.videoS3Key,
            source: .library
        )
    }

    /// Create from SectionExercise
    public static func from(_ sectionExercise: SectionExercise) -> WizardExerciseDto {
        WizardExerciseDto(
            id: sectionExercise.id ?? UUID().uuidString,
            exerciseId: sectionExercise.exerciseId,
            name: sectionExercise.name,
            category: sectionExercise.category,
            sets: sectionExercise.sets?.map { $0.toDto() },
            reps: sectionExercise.reps,
            durationSeconds: sectionExercise.durationSeconds,
            weight: sectionExercise.weight,
            weightUnit: sectionExercise.weightUnit,
            restSeconds: sectionExercise.restSeconds,
            instructions: sectionExercise.instructions,
            equipment: sectionExercise.equipment,
            tags: sectionExercise.tags,
            videoS3Key: sectionExercise.videoS3Key,
            notes: sectionExercise.notes,
            orderIndex: sectionExercise.orderIndex,
            source: sectionExercise.isPersisted ? .library : .ai
        )
    }
}

// MARK: - Workout DTO for Wizard Draft
/// Main workout draft model for the section-based wizard
public struct WorkoutDraftDto: Codable, Identifiable {
    public var id: String
    public var title: String?
    public var clientId: String?
    public var trainerId: String?
    public var programId: String?
    public var scheduledDate: String?
    public var sections: [WizardSectionDto]
    public var notes: String?
    public var sessionType: String?

    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        clientId: String? = nil,
        trainerId: String? = nil,
        programId: String? = nil,
        scheduledDate: String? = nil,
        sections: [WizardSectionDto] = [],
        notes: String? = nil,
        sessionType: String? = nil
    ) {
        self.id = id
        self.title = title
        self.clientId = clientId
        self.trainerId = trainerId
        self.programId = programId
        self.scheduledDate = scheduledDate
        self.sections = sections
        self.notes = notes
        self.sessionType = sessionType
    }

    // MARK: - Computed Properties

    /// Total exercise count across all sections
    public var totalExerciseCount: Int {
        sections.reduce(0) { $0 + $1.exerciseCount }
    }

    /// Check if the draft is empty
    public var isEmpty: Bool {
        sections.isEmpty || sections.allSatisfy { $0.isEmpty }
    }

    /// Check if ready to save
    public var isReadyToSave: Bool {
        guard let title = title, !title.isEmpty else { return false }
        guard totalExerciseCount > 0 else { return false }
        return true
    }

    // MARK: - Migration from Legacy Flat Structure

    /// Create a WorkoutDraftDto from a Workout with flat exercises (legacy migration)
    /// Wraps exercises in a default "Main Workout" section
    public static func from(_ workout: Workout) -> WorkoutDraftDto {
        var sections: [WizardSectionDto] = []

        if let structuredSections = workout.notesStructured?.sections {
            // Already has sections - convert them
            sections = structuredSections.map { section in
                WizardSectionDto(
                    id: section.id ?? UUID().uuidString,
                    name: section.name,
                    description: section.description,
                    exercises: section.exercises?.map { WizardExerciseDto.from($0) },
                    notes: section.notes
                )
            }
        }

        // If no sections exist, create a default "Main Workout" section
        if sections.isEmpty {
            sections = [WizardSectionDto(name: "Main Workout")]
        }

        return WorkoutDraftDto(
            id: workout.id,
            title: workout.title,
            clientId: workout.clientId,
            trainerId: workout.trainerId,
            programId: workout.programId,
            scheduledDate: workout.scheduledDate,
            sections: sections,
            notes: workout.notesRaw,
            sessionType: workout.notesStructured?.sessionType
        )
    }

    /// Create a new empty draft with a default section
    public static func emptyDraft(
        clientId: String? = nil,
        trainerId: String? = nil
    ) -> WorkoutDraftDto {
        WorkoutDraftDto(
            clientId: clientId,
            trainerId: trainerId,
            sections: [WizardSectionDto(name: "Main Workout")]
        )
    }

    // MARK: - Section Helpers

    /// Add a new section
    public mutating func addSection(name: String, description: String? = nil) {
        let section = WizardSectionDto(
            name: name,
            description: description
        )
        sections.append(section)
    }

    /// Remove a section by ID
    public mutating func removeSection(id: String) {
        sections.removeAll { $0.id == id }
    }

    /// Move a section from one index to another
    public mutating func moveSection(from source: IndexSet, to destination: Int) {
        sections.move(fromOffsets: source, toOffset: destination)
    }

    /// Add exercise to a specific section
    public mutating func addExercise(_ exercise: WizardExerciseDto, to sectionId: String) {
        if let index = sections.firstIndex(where: { $0.id == sectionId }) {
            if sections[index].exercises == nil {
                sections[index].exercises = []
            }
            sections[index].exercises?.append(exercise)
        }
    }

    /// Add multiple exercises to a specific section (batch add)
    public mutating func addExercises(_ exercises: [WizardExerciseDto], to sectionId: String) {
        if let index = sections.firstIndex(where: { $0.id == sectionId }) {
            if sections[index].exercises == nil {
                sections[index].exercises = []
            }
            sections[index].exercises?.append(contentsOf: exercises)
        }
    }

    /// Remove exercise from a section
    public mutating func removeExercise(exerciseId: String, from sectionId: String) {
        if let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) {
            sections[sectionIndex].exercises?.removeAll { $0.id == exerciseId }
        }
    }

    /// Get all exercises that need video
    public var exercisesWithoutVideo: [WizardExerciseDto] {
        sections.flatMap { $0.exercises ?? [] }.filter { !$0.hasVideo }
    }

    /// Get all exercises with video
    public var exercisesWithVideo: [WizardExerciseDto] {
        sections.flatMap { $0.exercises ?? [] }.filter { $0.hasVideo }
    }
}

public enum WorkoutProcessingStatus: String, CaseIterable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"

    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Ready"
        case .failed: return "Failed"
        }
    }
}

extension Workout {

    // MARK: - Status Modification Helpers (Immutable Copy Pattern)

    /// Creates a new Workout with the specified schedulingStatus
    /// Used for enforcing auto-accept logic on trainer-created workouts
    public func withSchedulingStatus(_ newSchedulingStatus: String) -> Workout {
        return Workout(
            id: self.databaseId,
            programId: self.programId,
            trainerId: self.trainerId,
            clientId: self.clientId,
            isSaved: self.isSaved,
            originalWorkoutId: self.originalWorkoutId,
            timesUsed: self.timesUsed,
            lastUsedAt: self.lastUsedAt,
            proposedDate: self.proposedDate,
            scheduledDate: self.scheduledDate,
            schedulingStatus: newSchedulingStatus,  // Modified field
            proposedBy: self.proposedBy,
            proposedAt: self.proposedAt,
            acceptedAt: self.acceptedAt,
            completedAt: self.completedAt,
            title: self.title,
            notesRaw: self.notesRaw,
            notesStructured: self.notesStructured,
            processingStatus: self.processingStatus,
            processingError: self.processingError,
            attachments: self.attachments,
            date: self.date,
            status: self.status,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }

    /// Creates a new Workout with the specified status
    /// Used for syncing status with scheduledDate presence
    public func withStatus(_ newStatus: String) -> Workout {
        return Workout(
            id: self.databaseId,
            programId: self.programId,
            trainerId: self.trainerId,
            clientId: self.clientId,
            isSaved: self.isSaved,
            originalWorkoutId: self.originalWorkoutId,
            timesUsed: self.timesUsed,
            lastUsedAt: self.lastUsedAt,
            proposedDate: self.proposedDate,
            scheduledDate: self.scheduledDate,
            schedulingStatus: self.schedulingStatus,
            proposedBy: self.proposedBy,
            proposedAt: self.proposedAt,
            acceptedAt: self.acceptedAt,
            completedAt: self.completedAt,
            title: self.title,
            notesRaw: self.notesRaw,
            notesStructured: self.notesStructured,
            processingStatus: self.processingStatus,
            processingError: self.processingError,
            attachments: self.attachments,
            date: self.date,
            status: newStatus,  // Modified field
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }

    /// Creates a new Workout with trainerId set
    /// Used for ensuring trainer ownership is set
    public func withTrainerId(_ newTrainerId: String) -> Workout {
        return Workout(
            id: self.databaseId,
            programId: self.programId,
            trainerId: newTrainerId,  // Modified field
            clientId: self.clientId,
            isSaved: self.isSaved,
            originalWorkoutId: self.originalWorkoutId,
            timesUsed: self.timesUsed,
            lastUsedAt: self.lastUsedAt,
            proposedDate: self.proposedDate,
            scheduledDate: self.scheduledDate,
            schedulingStatus: self.schedulingStatus,
            proposedBy: self.proposedBy,
            proposedAt: self.proposedAt,
            acceptedAt: self.acceptedAt,
            completedAt: self.completedAt,
            title: self.title,
            notesRaw: self.notesRaw,
            notesStructured: self.notesStructured,
            processingStatus: self.processingStatus,
            processingError: self.processingError,
            attachments: self.attachments,
            date: self.date,
            status: self.status,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }

    /// Get scheduled date as Date object
    public var scheduledDateAsDate: Date? {
        guard let scheduledDate = scheduledDate else { return nil }
        return ISO8601DateFormatter().date(from: scheduledDate)
    }

    /// Check if workout is overdue
    public var isOverdue: Bool {
        guard let date = scheduledDateAsDate,
              !isCompleted else {
            return false
        }
        return date < Date()
    }

    // MARK: - Program Hierarchy Support

    /// Check if workout belongs to a program
    public var belongsToProgram: Bool {
        return programId != nil
    }

    /// Get workout's effective date (scheduled or proposed)
    public var effectiveDate: Date? {
        return scheduledWorkoutDate ?? proposedWorkoutDate
    }

    /// Display title with fallback
    public var displayTitle: String {
        return title ?? "Untitled Workout"
    }

    /// Display status for UI
    public var displayStatus: String {
        if let status = schedulingStatus {
            switch status {
            case "DRAFT": return "Draft"
            case "PROPOSED": return "Proposed"
            case "ACCEPTED": return "Accepted"
            case "SCHEDULED": return "Scheduled"
            case "IN_PROGRESS": return "In Progress"
            case "COMPLETED": return "Completed"
            default: return status.capitalized
            }
        }
        return status?.capitalized ?? "Draft"
    }

    /// Check if workout can be started
    public var canStart: Bool {
        guard let schedDate = scheduledDateAsDate else { return false }
        let now = Date()
        // Can start if scheduled for today or in the past, and not already completed
        return schedDate <= now && !isCompleted
    }
}
