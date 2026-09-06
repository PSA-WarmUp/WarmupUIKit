import Foundation

/// Turning a server instant into a time a person recognises.
///
/// A scheduled workout is one moment, written down once, and read by two people who may be in
/// different places. The server stores that moment and sends it with an offset; only the device
/// knows which wall clock the reader is looking at, so only the device can name the hour.
///
/// This exists because the alternative kept happening. A notification body was built by
/// interpolating a zone-less `LocalDateTime`, so a session the trainer booked for 2pm Pacific
/// arrived reading *"…on 2026-09-04T21:00"* — the UTC wall time, unlabelled, mid-sentence. The
/// server no longer puts dates in prose; it sends `data.scheduledAtIso` and the client formats it.
public enum ScheduleDisplay {

    /// Parses ISO-8601 that carries a zone. Returns nil for anything that does not.
    ///
    /// Deliberately strict. `ISO8601DateFormatter` assumes UTC when a string has no offset, which
    /// silently turns "we don't know the zone" into "it's UTC" — and that assumption is exactly
    /// the bug this whole contract exists to close. A zone-less string now means the server
    /// regressed, so it should read as absent rather than as a plausible wrong answer.
    public static func instant(fromIso iso: String?) -> Date? {
        guard let iso = iso?.trimmingCharacters(in: .whitespacesAndNewlines), !iso.isEmpty else {
            return nil
        }

        guard hasZoneDesignator(iso) else {
            assertionFailure("Zone-less datetime from the server: \(iso). Expected an offset or Z.")
            return nil
        }

        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFraction.date(from: iso) { return date }

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: iso)
    }

    /// "Fri, Sep 4 at 2:00 PM", in the reader's own timezone. Nil when there is no usable instant.
    public static func localDateTime(fromIso iso: String?) -> String? {
        guard let date = instant(fromIso: iso) else { return nil }
        return dateTimeFormatter.string(from: date)
    }

    /// "2:00 PM", in the reader's own timezone.
    public static func localTime(fromIso iso: String?) -> String? {
        guard let date = instant(fromIso: iso) else { return nil }
        return timeFormatter.string(from: date)
    }

    // MARK: - Internals

    /// True when the string ends in `Z` or carries a `±HH:MM` / `±HHMM` offset.
    ///
    /// Checked on the tail only: a date part contains hyphens of its own, so scanning the whole
    /// string for a sign would call every plain date zone-qualified.
    private static func hasZoneDesignator(_ iso: String) -> Bool {
        if iso.hasSuffix("Z") || iso.hasSuffix("z") { return true }
        guard let timeStart = iso.range(of: "T")?.upperBound else { return false }
        let timePart = iso[timeStart...]
        return timePart.contains("+") || timePart.contains("-")
    }

    /// Rebuilt per call is wasteful; built once is wrong if the user changes timezone mid-session.
    /// `DateFormatter` reads `TimeZone.current` at format time when none is set explicitly, so a
    /// shared instance stays correct for a traveller — which is the case that breaks otherwise.
    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d 'at' h:mm a"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
}
