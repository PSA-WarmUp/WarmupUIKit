//
//  Program.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 6/17/25.
//


// MARK: - Program.swift
import Foundation

public struct Program: Codable, Identifiable {
    public let id: String
    public let trainerId: String?
    public let clientId: String
    public let title: String
    public let descriptionRaw: String?
    public let descriptionStructured: ProgramStructure?
    public let startDate: String? // ISO8601 format
    public let endDate: String?   // ISO8601 format
    public let workoutIds: [String]?
    public let status: ProgramStatus?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: String,
        trainerId: String?,
        clientId: String,
        title: String,
        descriptionRaw: String?,
        descriptionStructured: ProgramStructure?,
        startDate: String?,
        endDate: String?,
        workoutIds: [String]?,
        status: ProgramStatus?,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.trainerId = trainerId
        self.clientId = clientId
        self.title = title
        self.descriptionRaw = descriptionRaw
        self.descriptionStructured = descriptionStructured
        self.startDate = startDate
        self.endDate = endDate
        self.workoutIds = workoutIds
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed properties for Date conversion
    public var programStartDate: Date? {
        if let dateString = startDate {
            // Try simple date format first (yyyy-MM-dd) which is what the API returns
            let parsedDate = dateString.toSimpleDate() ?? ISO8601DateFormatter().date(from: dateString)
            print("📅 Parsing start date '\(dateString)' -> \(parsedDate?.description ?? "nil")")
            return parsedDate
        }
        return nil
    }

    public var programEndDate: Date? {
        if let dateString = endDate {
            // Try simple date format first (yyyy-MM-dd) which is what the API returns
            let parsedDate = dateString.toSimpleDate() ?? ISO8601DateFormatter().date(from: dateString)
            print("📅 Parsing end date '\(dateString)' -> \(parsedDate?.description ?? "nil")")
            return parsedDate
        }
        return nil
    }

    // MARK: - Program Validation & Business Logic

    /// Check if the program is currently active
    public var isActive: Bool {
        guard let start = programStartDate, let end = programEndDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }

    /// Check if a date is within the program duration
    public func isDateWithinProgram(_ date: Date) -> Bool {
        guard let start = programStartDate, let end = programEndDate else {
            print("❌ Program dates parsing failed - start: \(startDate ?? "nil"), end: \(endDate ?? "nil")")
            return false
        }

        // Compare dates using start of day to avoid time/timezone issues
        let calendar = Calendar.current
        let inputDateStart = calendar.startOfDay(for: date)
        let programStartDate = calendar.startOfDay(for: start)
        let programEndDate = calendar.startOfDay(for: end)

        let isWithin = inputDateStart >= programStartDate && inputDateStart <= programEndDate
        print("📅 Date validation - Date: \(inputDateStart), Start: \(programStartDate), End: \(programEndDate), IsWithin: \(isWithin)")

        return isWithin
    }

    /// Check if a workout can be scheduled for a given date
    public func canScheduleWorkout(for date: Date) -> Bool {
        // Can't schedule in the past (compare start of day)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let inputDate = calendar.startOfDay(for: date)
        guard inputDate >= today else { return false }

        // Must be within program dates
        return isDateWithinProgram(date)
    }

    /// Get program duration in days
    public var durationInDays: Int? {
        guard let start = programStartDate, let end = programEndDate else { return nil }
        return Calendar.current.dateComponents([.day], from: start, to: end).day
    }

    /// Get program duration in weeks
    public var durationInWeeks: Int? {
        guard let days = durationInDays else { return nil }
        return days / 7
    }

    /// Get progress percentage (0.0 to 1.0)
    public var progressPercentage: Double? {
        guard let start = programStartDate, let end = programEndDate else { return nil }
        let now = Date()

        // Before start
        if now < start { return 0.0 }

        // After end
        if now > end { return 1.0 }

        // During program
        let totalDuration = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        return elapsed / totalDuration
    }

    /// Display name for UI
    public var displayName: String {
        return title
    }

    /// Display status for UI
    public var displayStatus: String {
        if let status = status {
            return status.rawValue.capitalized
        }

        // Fallback to computed status
        guard let start = programStartDate, let end = programEndDate else {
            return "Draft"
        }

        let now = Date()
        if now < start {
            return "Upcoming"
        } else if now > end {
            return "Completed"
        } else {
            return "Active"
        }
    }
}

// MARK: - Program Status
public enum ProgramStatus: String, Codable, CaseIterable {
    case draft = "DRAFT"
    case active = "ACTIVE"
    case paused = "PAUSED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    public var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    public var color: String {
        switch self {
        case .draft: return "gray"
        case .active: return "green"
        case .paused: return "orange"
        case .completed: return "blue"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Program Structure
public struct ProgramStructure: Codable {
    public let phases: [ProgramPhase]?
    public let workoutsPerWeek: Int?
    public let totalWorkouts: Int?
    public let goals: [String]?
    public let notes: String?

    public init(
        phases: [ProgramPhase]?,
        workoutsPerWeek: Int?,
        totalWorkouts: Int?,
        goals: [String]?,
        notes: String?
    ) {
        self.phases = phases
        self.workoutsPerWeek = workoutsPerWeek
        self.totalWorkouts = totalWorkouts
        self.goals = goals
        self.notes = notes
    }
}

public struct ProgramPhase: Codable, Identifiable {
    public let id: String?
    public let name: String
    public let duration: Int // weeks
    public let focus: String
    public let description: String?
    public let goals: [String]?

    public init(
        id: String?,
        name: String,
        duration: Int,
        focus: String,
        description: String?,
        goals: [String]?
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.focus = focus
        self.description = description
        self.goals = goals
    }

    // Computed properties
    public var durationInDays: Int {
        return duration * 7
    }
}

// MARK: - Program Metrics
public struct ProgramMetrics: Codable {
    public let programId: String
    public let totalWorkouts: Int
    public let completedWorkouts: Int
    public let averageRating: Double?
    public let totalVolume: Double? // Total weight lifted
    public let averageWorkoutDuration: Int? // Minutes
    public let adherenceRate: Double // Percentage of scheduled workouts completed

    public init(
        programId: String,
        totalWorkouts: Int,
        completedWorkouts: Int,
        averageRating: Double?,
        totalVolume: Double?,
        averageWorkoutDuration: Int?,
        adherenceRate: Double
    ) {
        self.programId = programId
        self.totalWorkouts = totalWorkouts
        self.completedWorkouts = completedWorkouts
        self.averageRating = averageRating
        self.totalVolume = totalVolume
        self.averageWorkoutDuration = averageWorkoutDuration
        self.adherenceRate = adherenceRate
    }

    public var completionPercentage: Double {
        guard totalWorkouts > 0 else { return 0.0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }
}

// MARK: - Program Request Models
public struct CreateProgramRequest: Codable {
    public let title: String
    public let clientId: String
    public let descriptionRaw: String?
    public let startDate: String // ISO8601
    public let endDate: String   // ISO8601
    public let structure: ProgramStructure?

    public init(
        title: String,
        clientId: String,
        descriptionRaw: String?,
        startDate: String,
        endDate: String,
        structure: ProgramStructure?
    ) {
        self.title = title
        self.clientId = clientId
        self.descriptionRaw = descriptionRaw
        self.startDate = startDate
        self.endDate = endDate
        self.structure = structure
    }
}

public struct UpdateProgramRequest: Codable {
    public let title: String?
    public let descriptionRaw: String?
    public let startDate: String?
    public let endDate: String?
    public let status: ProgramStatus?
    public let structure: ProgramStructure?

    public init(
        title: String?,
        descriptionRaw: String?,
        startDate: String?,
        endDate: String?,
        status: ProgramStatus?,
        structure: ProgramStructure?
    ) {
        self.title = title
        self.descriptionRaw = descriptionRaw
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.structure = structure
    }
}
