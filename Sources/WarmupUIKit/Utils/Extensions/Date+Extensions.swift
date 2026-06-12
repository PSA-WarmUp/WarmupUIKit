//
//  Date+Extensions.swift
//  WarmupCore
//
//  Date conversion utilities for API communication and formatting
//

import Foundation

// MARK: - Date Extensions

public extension Date {
    /// Convert Date to ISO8601 string for API
    func toISO8601String() -> String {
        return ISO8601DateFormatter().string(from: self)
    }

    /// Convert Date to simple date string (yyyy-MM-dd)
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

    /// ISO8601 string with fractional seconds
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }

    /// Parse an ISO8601 / RFC3339 timestamp from the backend, tolerant of every
    /// variation the API emits. `ISO8601DateFormatter` with `.withFractionalSeconds`
    /// REQUIRES a fraction, so the old single-formatter version returned nil for the
    /// non-fractional form (e.g. "2026-06-12T22:30:00Z") and silently dropped those
    /// workouts (empty "Today's Schedule"). This is the exact strategy the trainer
    /// app uses, where it has worked reliably.
    static func fromISO8601String(_ string: String) -> Date? {
        // Try with fractional seconds first (most common from backend)
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: string) {
            return date
        }

        // Try without fractional seconds (with timezone)
        let formatterStandard = ISO8601DateFormatter()
        formatterStandard.formatOptions = [.withInternetDateTime]
        if let date = formatterStandard.date(from: string) {
            return date
        }

        // Try without timezone (e.g., "2025-12-31T21:50:00")
        // Backend sends UTC time without the Z suffix, so treat as UTC
        let formatterNoTimezone = DateFormatter()
        formatterNoTimezone.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatterNoTimezone.locale = Locale(identifier: "en_US_POSIX")
        formatterNoTimezone.timeZone = TimeZone(identifier: "UTC") // Treat as UTC
        if let date = formatterNoTimezone.date(from: string) {
            return date
        }

        // Try with fractional seconds but no timezone (e.g., "2025-12-31T21:50:00.123")
        formatterNoTimezone.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let date = formatterNoTimezone.date(from: string) {
            return date
        }

        // Try date-only format (YYYY-MM-DD)
        let formatterDateOnly = ISO8601DateFormatter()
        formatterDateOnly.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        if let date = formatterDateOnly.date(from: string) {
            return date
        }

        return nil
    }

    /// Round date to the nearest time component
    func rounded(to component: Calendar.Component) -> Date {
        let calendar = Calendar.current

        switch component {
        case .hour:
            let minutes = calendar.component(.minute, from: self)
            _ = calendar.component(.second, from: self)
            _ = calendar.component(.nanosecond, from: self)

            // Round to nearest hour
            if minutes >= 30 {
                // Round up to next hour
                return calendar.date(byAdding: .hour, value: 1, to: calendar.dateInterval(of: .hour, for: self)?.start ?? self) ?? self
            } else {
                // Round down to current hour
                return calendar.dateInterval(of: .hour, for: self)?.start ?? self
            }
        default:
            return self
        }
    }
}

// MARK: - String to Date Extensions
// Note: String.toSimpleDate() and String.toISO8601Date() are defined in String+Extensions.swift

// MARK: - ISO8601DateFormatter Extensions

public extension ISO8601DateFormatter {
    /// Shared ISO8601 formatter for reuse
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

// MARK: - DateFormatter Extensions

public extension DateFormatter {
    /// Full date and time format: "MMM d, yyyy 'at' h:mm a"
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()

    /// Message time format: short time style only
    static let messageTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    /// Relative time formatter with abbreviated units
    static let relativeTime: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Workout date format: "MMM d, yyyy"
    static let workoutDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    /// Workout time format: "h:mm a"
    static let workoutTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    /// Workout date and time format: "MMM d, yyyy 'at' h:mm a"
    static let workoutDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()

    /// Short date format: "MMM d"
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    /// Day of week format: "EEEE"
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    /// Calculate time ago from a date in abbreviated format
    /// - Parameter date: The date to compare against current time
    /// - Returns: Abbreviated time string (e.g., "5m", "2h", "3d", or "now")
    static func timeAgo(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "1d" : "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1h" : "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1m" : "\(minutes)m"
        } else {
            return "now"
        }
    }
}
