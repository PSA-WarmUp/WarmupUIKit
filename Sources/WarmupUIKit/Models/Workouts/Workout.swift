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
            for exercise in section.entries {
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
        return sections.reduce(0) { $0 + $1.entries.count }
    }

    /// Estimated workout duration in minutes (can be nil if not calculable)
    public var estimatedDurationMinutes: Int? {
        guard let sections = notesStructured?.sections else { return nil }

        var totalSeconds = 0
        for section in sections {
            for exercise in section.entries {
                guard let sets = exercise.sets, !sets.isEmpty else { continue }
                for set in sets {
                    // Add per-set duration if time-based
                    if let duration = set.duration {
                        totalSeconds += duration
                    }
                    // Add per-set rest time
                    if let rest = set.restValue {
                        totalSeconds += rest
                    }
                    // Estimate ~30 sec of work for a rep-based set
                    if set.isRepBased {
                        totalSeconds += 30
                    }
                }
            }
        }

        let minutes = totalSeconds / 60
        return minutes > 0 ? minutes : nil
    }

    /// Derive focus from section names when categories aren't available
    private func deriveFocusFromSectionNames(_ sections: [WorkoutSection]) -> String {
        let sectionNames = sections.compactMap { $0.name?.lowercased() }

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
    public var missingExercises: [ExerciseEntry] {
        guard let sections = notesStructured?.sections else { return [] }

        var missing: [ExerciseEntry] = []
        for section in sections {
            for exercise in section.entries {
                if !exercise.isPersisted {
                    missing.append(exercise)
                }
            }
        }
        return missing
    }

    /// Returns exercises that need to be linked to the exercise library
    public var exercisesNeedingLinking: [ExerciseEntry] {
        guard let sections = notesStructured?.sections else { return [] }

        var needsLinking: [ExerciseEntry] = []
        for section in sections {
            for exercise in section.entries {
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
    case missingExercises(count: Int, exercises: [ExerciseEntry])
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
    /// Stable UUID string, generated on creation (JSON key: `id`)
    public let id: String?
    /// Nullable; null/blank => display fallback "Section N" (JSON key: `name`)
    public let name: String?
    /// 0-based, contiguous within the workout (JSON key: `order`)
    public let order: Int?
    public let description: String?
    /// Ordered flat list of exercise entries within this section (JSON key: `entries`)
    public var entries: [ExerciseEntry]
    /// Reference groups within this section (JSON key: `supersets`)
    public var supersets: [Superset]
    public let notes: String?

    public var isEmpty: Bool {
        return entries.isEmpty
    }

    public var exerciseCount: Int {
        return entries.count
    }

    enum CodingKeys: String, CodingKey {
        case id, name, order, description, entries, supersets, notes
    }

    // Default initializer
    public init(
        id: String? = nil,
        name: String? = nil,
        order: Int? = nil,
        description: String? = nil,
        entries: [ExerciseEntry] = [],
        supersets: [Superset] = [],
        notes: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.order = order
        self.description = description
        self.entries = entries
        self.supersets = supersets
        self.notes = notes
    }

    // Custom decoder: `entries`/`supersets` keys are present but values may be
    // null on the wire (backend emits nulls); default missing/null to [].
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.order = try container.decodeIfPresent(Int.self, forKey: .order)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.entries = try container.decodeIfPresent([ExerciseEntry].self, forKey: .entries) ?? []
        self.supersets = try container.decodeIfPresent([Superset].self, forKey: .supersets) ?? []
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }

    // MARK: - Display Helpers

    /// Section display name with fallback "Section {order+1}" (contract §8).
    public var displayName: String {
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        if let order = order {
            return "Section \(order + 1)"
        }
        return "Section"
    }

    /// The superset display letter (A/B/C…) for a given superset, derived at
    /// render time from the superset's rank among this section's supersets
    /// (ordered by `order`). Not stored.
    public func supersetLetter(for superset: Superset) -> String {
        let ordered = supersets.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        guard let rank = ordered.firstIndex(where: { $0.id == superset.id }) else {
            return Superset.letter(forRank: 0)
        }
        return Superset.letter(forRank: rank)
    }

    /// Renders this section's items in flat display order, merging standalone
    /// entries and supersets. A superset occupies the slot of its `order`
    /// (== the order of its first member entry). Members are gathered in
    /// `memberEntryIds` order and tagged with their display letter.
    public func orderedDisplayItems() -> [SectionDisplayItem] {
        let entriesById = Dictionary(entries.map { ($0.id ?? "", $0) }, uniquingKeysWith: { first, _ in first })
        let memberIds = Set(supersets.flatMap { $0.memberEntryIds })

        var slots: [(order: Int, item: SectionDisplayItem)] = []

        // Standalone entries (not a member of any superset)
        for entry in entries where !memberIds.contains(entry.id ?? "") {
            slots.append((entry.order ?? 0, .entry(entry)))
        }

        // Supersets, expanded into their member entries (in membership order)
        for superset in supersets {
            let members = superset.memberEntryIds.compactMap { entriesById[$0] }
            let slotOrder = superset.order ?? members.first?.order ?? 0
            slots.append((slotOrder, .superset(superset, letter: supersetLetter(for: superset), members: members)))
        }

        return slots.sorted { $0.order < $1.order }.map { $0.item }
    }

    // MARK: - DTO Conversion

    /// Convert to API-compatible WorkoutSectionDto
    public func toApiDto() -> WorkoutSectionDto {
        return WorkoutSectionDto(
            id: id,
            name: name,
            order: order,
            description: description,
            entries: entries.map { $0.toDto() },
            supersets: supersets.map { $0.toDto() },
            notes: notes
        )
    }

    /// Convert to wizard-compatible WizardSectionDto
    public func toWizardDto() -> WizardSectionDto {
        return WizardSectionDto(
            id: id ?? UUID().uuidString,
            name: displayName,
            order: order,
            description: description,
            entries: entries.map { WizardExerciseDto.from($0) },
            supersets: supersets,
            notes: notes
        )
    }
}

// MARK: - Section Display Item (flat render order)

/// A single item in a section's flat display order: either a standalone
/// exercise entry, or a superset expanded with its members and display letter.
public enum SectionDisplayItem {
    case entry(ExerciseEntry)
    case superset(Superset, letter: String, members: [ExerciseEntry])
}

// MARK: - Superset Model (matches backend SupersetDto)

public struct Superset: Codable, Identifiable, Equatable, Sendable {
    /// Stable UUID string (JSON key: `id`)
    public let id: String?
    /// 0-based within section; == order of its FIRST member entry (JSON key: `order`)
    public let order: Int?
    /// Ordered = execution order; size >= 2 (else auto-dissolved) (JSON key: `memberEntryIds`)
    public var memberEntryIds: [String]

    enum CodingKeys: String, CodingKey {
        case id, order, memberEntryIds
    }

    public init(
        id: String? = nil,
        order: Int? = nil,
        memberEntryIds: [String] = []
    ) {
        self.id = id ?? UUID().uuidString
        self.order = order
        self.memberEntryIds = memberEntryIds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.order = try container.decodeIfPresent(Int.self, forKey: .order)
        self.memberEntryIds = try container.decodeIfPresent([String].self, forKey: .memberEntryIds) ?? []
    }

    /// Converts a 0-based rank to a display letter: 0->A, 1->B … 25->Z, 26->AA.
    public static func letter(forRank rank: Int) -> String {
        guard rank >= 0 else { return "?" }
        var n = rank
        var result = ""
        repeat {
            let remainder = n % 26
            result = String(UnicodeScalar(65 + remainder)!) + result
            n = n / 26 - 1
        } while n >= 0
        return result
    }

    public func toDto() -> SupersetDto {
        SupersetDto(id: id, order: order, memberEntryIds: memberEntryIds)
    }
}

// MARK: - Exercise Entry Model (matches backend ExerciseEntryDto)

/// A single exercise slot within a section. `id` is the stable entry id
/// (distinct from `exerciseId`, the library FK). Renamed from `SectionExercise`.
public struct ExerciseEntry: Codable, Identifiable {
    /// Stable UUID string — the entry id, DISTINCT from exerciseId (JSON key: `id`)
    public let id: String?
    /// Library FK, nullable (JSON key: `exerciseId`)
    public let exerciseId: String?
    public let name: String
    public let category: String?
    /// 0-based flat position within its section (JSON key: `order`)
    public let order: Int?
    public var sets: [ExerciseSet]?
    public let instructions: String?
    public var notes: String?
    /// Read-time only: signed demo-clip URL resolved server-side (JSON key: `videoUrl`)
    public let videoUrl: String?
    /// Read-time only: signed demo-clip thumbnail (JSON key: `thumbnailUrl`)
    public let thumbnailUrl: String?
    /// Read-time only: AI-suggested alternates (CO_PILOT trainers) (JSON key: `alternates`)
    public let alternates: [AlternateExercise]?

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

    enum CodingKeys: String, CodingKey {
        case id, exerciseId, name, category, order, sets, instructions, notes
        case videoUrl, thumbnailUrl, alternates
    }

    // Convenience initializer
    public init(
        id: String? = nil,
        exerciseId: String? = nil,
        name: String,
        category: String? = nil,
        order: Int? = nil,
        sets: [ExerciseSet]? = nil,
        instructions: String? = nil,
        notes: String? = nil,
        videoUrl: String? = nil,
        thumbnailUrl: String? = nil,
        alternates: [AlternateExercise]? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.order = order
        self.sets = sets
        self.instructions = instructions
        self.notes = notes
        self.videoUrl = videoUrl
        self.thumbnailUrl = thumbnailUrl
        self.alternates = alternates
    }
}

extension ExerciseEntry {
    public func toDto() -> ExerciseEntryDto {
        ExerciseEntryDto(
            id: id,
            exerciseId: exerciseId,
            name: name,
            category: category,
            order: order,
            sets: sets?.map { $0.toDto() },
            instructions: instructions,
            notes: notes,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            alternates: alternates?.map { $0.toDto() }
        )
    }
}

// MARK: - Alternate Exercise Model (matches backend AlternateExerciseDto)

/// An AI-suggested alternate for an exercise slot.
public struct AlternateExercise: Codable, Identifiable, Equatable, Sendable {
    /// Library FK of the alternate (JSON key: `exerciseId`)
    public let exerciseId: String?
    public let name: String
    /// One-line explanation of why this is a reasonable substitute (JSON key: `reason`)
    public let reason: String?

    /// Identifiable via exerciseId (falls back to name).
    public var id: String { exerciseId ?? name }

    enum CodingKeys: String, CodingKey {
        case exerciseId, name, reason
    }

    public init(exerciseId: String? = nil, name: String, reason: String? = nil) {
        self.exerciseId = exerciseId
        self.name = name
        self.reason = reason
    }

    public func toDto() -> AlternateExerciseDto {
        AlternateExerciseDto(exerciseId: exerciseId, name: name, reason: reason)
    }
}

// MARK: - EffortType Enum
/// Represents the type of effort/intensity tracking for a set
public enum EffortType: String, CaseIterable, Codable, Sendable {
    case none = "NONE"       // Weight-based (traditional)
    case rpe = "RPE"         // Rate of Perceived Exertion (1-10 scale)
    case rir = "RIR"         // Reps In Reserve (0-5 scale)

    public var displayName: String {
        switch self {
        case .none: return "Weight"
        case .rpe: return "RPE"
        case .rir: return "RIR"
        }
    }

    public var description: String {
        switch self {
        case .none: return "Target weight in lbs/kg"
        case .rpe: return "Rate of Perceived Exertion (1-10)"
        case .rir: return "Reps In Reserve (how many left in tank)"
        }
    }
}

// MARK: - ExerciseSet Model
public struct ExerciseSet: Codable, Identifiable, Equatable, Sendable {
    public let id: String?
    public var reps: Int?
    public var minReps: Int?       // For rep ranges (e.g., 8 in "8-12")
    public var maxReps: Int?       // For rep ranges (e.g., 12 in "8-12")
    public var weight: String?     // Store as String to match backend
    public var targetRpe: Double?  // Trainer-prescribed TARGET RPE (1.0-10.0, 0.5 steps). Distinct from client ACTUAL RPE (SetLog.rpe). Contract §9/D3.
    public var rir: String?        // Store as String to match backend (Reps In Reserve 0-5)
    public var effortType: String? // "RPE" | "RIR" | "WEIGHT" | nil
    public var tempo: String?
    public var duration: Int?
    public var rest: String?       // Store as String to match backend
    public var notes: String?
    /// "lbs" or "kg" — the unit this was prescribed in. Null on rows predating the field.
    public var weightUnit: String?
    /// EXTERNAL / BODYWEIGHT / BODYWEIGHT_PLUS / UNLOADED. Nil means "resolve it" — see `load`.
    public var loadType: String?
    /// Server-built, read-only: "8 reps · bodyweight + 25 lbs". Prefer this over re-deriving.
    public var displaySummary: String?

    /// How this set is loaded, resolving the legacy free-text weight when no marker was sent.
    public var load: LoadType { LoadType.resolve(marker: loadType, prescribedWeight: weight) }

    /// True when this set is measured by the clock — a hold already recorded, or a set that
    /// prescribes neither reps nor load and therefore has nothing else it could mean.
    public var isTimeBasedPrescription: Bool {
        if duration != nil { return true }
        let hasReps = reps != nil || minReps != nil || maxReps != nil
        let hasLoad = !(weight ?? "").isEmpty
        return !hasReps && !hasLoad
    }

    // Computed properties for numeric access
    public var weightValue: Double? {
        guard let weight = weight else { return nil }
        return Double(weight)
    }

    /// Numeric target RPE (alias of `targetRpe`). Nil when no target is prescribed.
    public var rpeValue: Double? {
        return targetRpe
    }

    public var rirValue: Int? {
        guard let rir = rir else { return nil }
        return Int(rir)
    }

    public var restValue: Int? {
        guard let rest = rest else { return nil }
        return Int(rest)
    }

    /// Returns the rep range as a display string (e.g., "8-12" or "10")
    public var repRangeDisplay: String {
        if let min = minReps, let max = maxReps, min != max {
            return "\(min)-\(max)"
        } else if let min = minReps {
            return "\(min)"
        } else if let max = maxReps {
            return "\(max)"
        } else if let reps = reps {
            return "\(reps)"
        }
        return ""
    }

    /// Returns true if this set uses a rep range
    public var hasRepRange: Bool {
        minReps != nil && maxReps != nil && minReps != maxReps
    }

    /// Returns the parsed effort type enum
    public var effortTypeEnum: EffortType {
        guard let effortType = effortType else { return .none }
        return EffortType(rawValue: effortType) ?? .none
    }

    /// Returns the effort display string based on effort type
    public var effortDisplay: String {
        switch effortTypeEnum {
        case .rpe:
            if let rpeVal = targetRpe {
                return "RPE \(ExerciseSet.formatRpe(rpeVal))"
            }
            return "RPE"
        case .rir:
            if let rirVal = rirValue {
                return "\(rirVal) RIR"
            }
            return "RIR"
        case .none:
            // Route through the load type so a bodyweight set reads "bodyweight" instead of
            // echoing the raw token, and so the unit is the one actually prescribed rather than
            // a hardcoded "lbs" restating someone's kilos.
            return load.describeLoad(weight: weightValue, unit: weightUnit) ?? ""
        }
    }

    /// Formats a target RPE for display: whole numbers as "8", half steps as "7.5".
    public static func formatRpe(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }

    // Initialize with either strings or numbers for convenience
    public init(
        id: String? = nil,
        reps: Int? = nil,
        minReps: Int? = nil,
        maxReps: Int? = nil,
        weight: Double? = nil,  // Accept Double for convenience
        targetRpe: Double? = nil, // Trainer-prescribed target RPE (0.5 steps)
        rir: Int? = nil,        // Accept Int for convenience
        effortType: String? = nil,
        tempo: String? = nil,
        rest: Int? = nil,        // Accept Int for convenience
        notes: String? = nil,
        duration: Int? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.reps = reps
        self.minReps = minReps
        self.maxReps = maxReps
        self.weight = weight != nil ? "\(weight!)" : nil  // Convert to String
        self.targetRpe = targetRpe
        self.rir = rir != nil ? "\(rir!)" : nil           // Convert to String
        self.effortType = effortType
        self.tempo = tempo
        self.rest = rest != nil ? "\(rest!)" : nil        // Convert to String
        self.notes = notes
        self.duration = duration
    }

    public var isTimeBased: Bool {
        duration != nil
    }

    public var isRepBased: Bool {
        reps != nil || minReps != nil || maxReps != nil
    }
}

// Fix the toDto extension
extension ExerciseSet {
    public func toDto() -> ExerciseSetDto {
        ExerciseSetDto(
            reps: reps,
            minReps: minReps,
            maxReps: maxReps,
            weight: weight,     // Already a String?
            targetRpe: targetRpe, // Numeric target RPE (Double)
            rir: rir,          // Already a String?
            effortType: effortType,
            tempo: tempo,
            rest: rest,        // Already a String?
            notes: notes,
            // The unit travels with the number, the marker travels with the set, and a hold is a
            // prescription too. Dropping any of the three here meant the server received a set
            // that said nothing — which it then rightly rejected.
            weightUnit: weightUnit,
            loadType: loadType,
            durationSeconds: duration
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

    public func toExerciseEntry() -> ExerciseEntry {
        var exerciseSets: [ExerciseSet] = []
        for _ in 0..<sets {
            exerciseSets.append(
                ExerciseSet(
                    reps: isTimeBased ? nil : reps,
                    weight: weight,          // Pass as Double, init converts to String
                    targetRpe: nil,
                    tempo: nil,
                    rest: restSeconds,       // Pass as Int, init converts to String
                    notes: nil,
                    duration: isTimeBased ? durationSeconds : nil
                )
            )
        }

        return ExerciseEntry(
            id: id,
            exerciseId: nil,
            name: name,
            category: nil,
            order: nil,
            sets: exerciseSets.isEmpty ? nil : exerciseSets,
            instructions: nil,
            notes: notes
        )
    }

    // Fix the from method in WorkoutExercise
    public static func from(_ entry: ExerciseEntry) -> WorkoutExercise? {
        let firstSet = entry.sets?.first

        // Legacy scalar fields now live on the set; derive from the first set.
        let weightValue: Double? = firstSet?.weightValue
        let restValue: Int = firstSet?.restValue ?? 60

        if let duration = firstSet?.duration {
            return WorkoutExercise(
                id: entry.id ?? UUID().uuidString,
                name: entry.name,
                sets: entry.setCount > 0 ? entry.setCount : 1,
                reps: nil,
                weight: weightValue,
                weightUnit: "lbs",
                durationSeconds: duration,
                restSeconds: restValue,
                notes: entry.notes,
                videoS3Key: nil
            )
        }

        return WorkoutExercise(
            id: entry.id ?? UUID().uuidString,
            name: entry.name,
            sets: entry.setCount > 0 ? entry.setCount : 1,
            reps: firstSet?.reps,
            weight: weightValue,
            weightUnit: "lbs",
            durationSeconds: nil,
            restSeconds: restValue,
            notes: entry.notes,
            videoS3Key: nil
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

/// Wire DTO for an exercise entry. Mirrors backend `WorkoutDto.ExerciseEntryDto`.
/// Renamed from `SectionExerciseDto`.
public struct ExerciseEntryDto: Codable {
    public let id: String?
    public let exerciseId: String?
    public let name: String
    public let category: String?
    public let order: Int?
    public let sets: [ExerciseSetDto]?
    public let instructions: String?
    public let notes: String?
    public let videoUrl: String?       // Read-time only
    public let thumbnailUrl: String?   // Read-time only
    public let alternates: [AlternateExerciseDto]?  // Read-time only

    // Simplified initializer for common use cases
    public init(name: String, sets: [ExerciseSetDto]? = nil, notes: String? = nil) {
        self.id = nil
        self.exerciseId = nil
        self.name = name
        self.category = nil
        self.order = nil
        self.sets = sets
        self.instructions = nil
        self.notes = notes
        self.videoUrl = nil
        self.thumbnailUrl = nil
        self.alternates = nil
    }

    // Full initializer
    public init(
        id: String? = nil,
        exerciseId: String? = nil,
        name: String,
        category: String? = nil,
        order: Int? = nil,
        sets: [ExerciseSetDto]? = nil,
        instructions: String? = nil,
        notes: String? = nil,
        videoUrl: String? = nil,
        thumbnailUrl: String? = nil,
        alternates: [AlternateExerciseDto]? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.order = order
        self.sets = sets
        self.instructions = instructions
        self.notes = notes
        self.videoUrl = videoUrl
        self.thumbnailUrl = thumbnailUrl
        self.alternates = alternates
    }
}

/// Wire DTO for a superset. Mirrors backend `WorkoutDto.SupersetDto`.
public struct SupersetDto: Codable {
    public let id: String?
    public let order: Int?
    public let memberEntryIds: [String]?

    public init(id: String? = nil, order: Int? = nil, memberEntryIds: [String]? = nil) {
        self.id = id
        self.order = order
        self.memberEntryIds = memberEntryIds
    }
}

/// Wire DTO for an AI-suggested alternate. Mirrors backend `WorkoutDto.AlternateExerciseDto`.
public struct AlternateExerciseDto: Codable {
    public let exerciseId: String?
    public let name: String
    public let reason: String?

    public init(exerciseId: String? = nil, name: String, reason: String? = nil) {
        self.exerciseId = exerciseId
        self.name = name
        self.reason = reason
    }
}

public struct ExerciseSetDto: Codable, Sendable {
    public let reps: Int?
    public let minReps: Int?       // For rep ranges (e.g., 8 in "8-12")
    public let maxReps: Int?       // For rep ranges (e.g., 12 in "8-12")
    public let weight: String?
    public let targetRpe: Double?  // Trainer-prescribed target RPE (1.0-10.0, 0.5 steps). Contract §9/D3.
    public let rir: String?        // Reps In Reserve (0-5)
    public let effortType: String? // "RPE" | "RIR" | "WEIGHT" | nil
    public let tempo: String?
    public let rest: String?
    public let notes: String?
    /// "lbs" or "kg" — the unit this was prescribed in.
    public let weightUnit: String?
    /// EXTERNAL / BODYWEIGHT / BODYWEIGHT_PLUS / UNLOADED. Omit and the server resolves it.
    public let loadType: String?
    /// Hold time for time-based sets (plank, carry, dead hang).
    public let durationSeconds: Int?
    /// Server-built summary, read-only — never sent.
    public let displaySummary: String?

    public init(
        reps: Int? = nil,
        minReps: Int? = nil,
        maxReps: Int? = nil,
        weight: String? = nil,
        targetRpe: Double? = nil,
        rir: String? = nil,
        effortType: String? = nil,
        tempo: String? = nil,
        rest: String? = nil,
        notes: String? = nil,
        weightUnit: String? = nil,
        loadType: String? = nil,
        durationSeconds: Int? = nil,
        displaySummary: String? = nil
    ) {
        self.reps = reps
        self.minReps = minReps
        self.maxReps = maxReps
        self.weight = weight
        self.targetRpe = targetRpe
        self.rir = rir
        self.effortType = effortType
        self.tempo = tempo
        self.rest = rest
        self.notes = notes
        self.weightUnit = weightUnit
        self.loadType = loadType
        self.durationSeconds = durationSeconds
        self.displaySummary = displaySummary
    }
}

public struct WorkoutSectionDto: Codable {
    public let id: String?
    public let name: String?
    public let order: Int?
    public let description: String?
    public let entries: [ExerciseEntryDto]?
    public let supersets: [SupersetDto]?
    public let notes: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        order: Int? = nil,
        description: String? = nil,
        entries: [ExerciseEntryDto]? = nil,
        supersets: [SupersetDto]? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.description = description
        self.entries = entries
        self.supersets = supersets
        self.notes = notes
    }
}

// MARK: - Wizard Section DTO for Draft
/// Section model for the workout wizard, uses WizardExerciseDto
public struct WizardSectionDto: Codable, Identifiable {
    public var id: String
    public var name: String
    public var order: Int?
    public var description: String?
    public var entries: [WizardExerciseDto]?
    public var supersets: [Superset]?
    public var notes: String?

    public init(
        id: String = UUID().uuidString,
        name: String,
        order: Int? = nil,
        description: String? = nil,
        entries: [WizardExerciseDto]? = nil,
        supersets: [Superset]? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.description = description
        self.entries = entries
        self.supersets = supersets
        self.notes = notes
    }

    public var isEmpty: Bool {
        entries?.isEmpty ?? true
    }

    public var exerciseCount: Int {
        entries?.count ?? 0
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
    public var order: Int?

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
        order: Int? = nil,
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
        self.order = order
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

    /// Create from ExerciseEntry
    public static func from(_ entry: ExerciseEntry) -> WizardExerciseDto {
        let firstSet = entry.sets?.first
        return WizardExerciseDto(
            id: entry.id ?? UUID().uuidString,
            exerciseId: entry.exerciseId,
            name: entry.name,
            category: entry.category,
            sets: entry.sets?.map { $0.toDto() },
            reps: firstSet?.reps,
            durationSeconds: firstSet?.duration,
            weight: firstSet?.weightValue,
            weightUnit: nil,
            restSeconds: firstSet?.restValue,
            instructions: entry.instructions,
            equipment: nil,
            tags: nil,
            videoS3Key: nil,
            notes: entry.notes,
            order: entry.order,
            source: entry.isPersisted ? .library : .ai
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
                    name: section.displayName,
                    order: section.order,
                    description: section.description,
                    entries: section.entries.map { WizardExerciseDto.from($0) },
                    supersets: section.supersets,
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
            if sections[index].entries == nil {
                sections[index].entries = []
            }
            sections[index].entries?.append(exercise)
        }
    }

    /// Add multiple exercises to a specific section (batch add)
    public mutating func addExercises(_ exercises: [WizardExerciseDto], to sectionId: String) {
        if let index = sections.firstIndex(where: { $0.id == sectionId }) {
            if sections[index].entries == nil {
                sections[index].entries = []
            }
            sections[index].entries?.append(contentsOf: exercises)
        }
    }

    /// Remove exercise from a section
    public mutating func removeExercise(exerciseId: String, from sectionId: String) {
        if let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) {
            sections[sectionIndex].entries?.removeAll { $0.id == exerciseId }
        }
    }

    /// Get all exercises that need video
    public var exercisesWithoutVideo: [WizardExerciseDto] {
        sections.flatMap { $0.entries ?? [] }.filter { !$0.hasVideo }
    }

    /// Get all exercises with video
    public var exercisesWithVideo: [WizardExerciseDto] {
        sections.flatMap { $0.entries ?? [] }.filter { $0.hasVideo }
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
