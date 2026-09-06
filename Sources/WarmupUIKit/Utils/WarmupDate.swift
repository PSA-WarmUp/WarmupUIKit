import Foundation

/// One parser and one set of formatters, for both apps.
///
/// Dates were being parsed in roughly a hundred places across three repositories, each with its
/// own `ISO8601DateFormatter` and its own idea of what to do with a missing zone. The two apps'
/// `DateManager`s had already drifted apart — one grew three fallbacks the other never got — and
/// the encode side emitted fractional seconds while the decode side sometimes refused them.
/// Every one of those is a silent multi-hour bug waiting for the right input.
///
/// Two rules, and everything here follows from them:
///
/// 1. **A wire timestamp is an instant.** It carries a zone or it is not trustworthy.
///    `ISO8601DateFormatter` quietly assumes UTC for a zone-less string, which turns "we don't
///    know" into "we're sure" — and that assumption is how a 2pm Pacific workout came to be
///    announced as `2026-09-04T21:00`.
/// 2. **A displayed time belongs to the reader.** Always `TimeZone.current`, never a fixed offset,
///    never the sender's zone.
public enum WarmupDate {

    // MARK: - Parsing

    /// Parse an API instant. Requires a zone designator — returns nil without one.
    ///
    /// Use this for anything the server sent. The backend guarantees an offset on every datetime,
    /// so a zone-less string means the contract regressed and should read as absent rather than
    /// as a plausible wrong answer.
    public static func instant(_ string: String?) -> Date? {
        guard let raw = normalized(string) else { return nil }
        guard hasZoneDesignator(raw) else {
            assertionFailure("Zone-less datetime from the server: \(raw). Expected an offset or Z.")
            return nil
        }
        return parseISO(raw)
    }

    /// Parse anything date-shaped, accepting a missing zone as UTC.
    ///
    /// For legacy payloads and locally-persisted strings only — never for a fresh API instant,
    /// which should go through `instant(_:)` so a regression is loud instead of six hours off.
    public static func lenient(_ string: String?) -> Date? {
        guard let raw = normalized(string) else { return nil }
        if let date = parseISO(raw) { return date }

        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
                       "yyyy-MM-dd'T'HH:mm:ss.SSS",
                       "yyyy-MM-dd'T'HH:mm:ss",
                       "yyyy-MM-dd HH:mm:ss"] {
            if let date = utcFormatter(format).date(from: raw) { return date }
        }
        return dayFormatter.date(from: raw)
    }

    /// A calendar day (`yyyy-MM-dd`), read in the reader's own calendar rather than in UTC.
    public static func day(_ string: String?) -> Date? {
        guard let raw = normalized(string) else { return nil }
        return localDayFormatter.date(from: raw)
    }

    // MARK: - Encoding

    /// UTC ISO-8601 with a `Z` and no fractional seconds — what the backend parses.
    public static func iso8601(_ date: Date) -> String {
        isoWriter.string(from: date)
    }

    /// `yyyy-MM-dd`, taken from the reader's calendar.
    ///
    /// A calendar day is a local question: formatting "today" in UTC hands the server tomorrow
    /// for anyone east of Greenwich, and yesterday for anyone in the Americas after 4pm.
    public static func dayString(_ date: Date) -> String {
        localDayFormatter.string(from: date)
    }

    // MARK: - Display (always the reader's timezone)

    /// "2:00 PM"
    public static func time(_ date: Date) -> String { timeFormatter.string(from: date) }

    /// "Fri, Sep 4 at 2:00 PM"
    public static func dayAndTime(_ date: Date) -> String { dayTimeFormatter.string(from: date) }

    /// "Sep 4, 2026"
    public static func mediumDate(_ date: Date) -> String { mediumDateFormatter.string(from: date) }

    /// "September 2026" — for a month header.
    public static func monthAndYear(_ date: Date) -> String { monthYearFormatter.string(from: date) }

    /// "Aug – Sep 2026" when a range straddles a month boundary, otherwise "September 2026".
    ///
    /// A week is not owned by the month its first day falls in. Titling Aug 30 – Sep 5 as
    /// "August" while the user has Sep 4 selected states something the screen contradicts.
    public static func monthAndYear(from start: Date, to end: Date) -> String {
        let calendar = Calendar.current
        let sameMonth = calendar.isDate(start, equalTo: end, toGranularity: .month)
        if sameMonth { return monthYearFormatter.string(from: start) }

        let sameYear = calendar.isDate(start, equalTo: end, toGranularity: .year)
        let left = sameYear
            ? shortMonthFormatter.string(from: start)
            : shortMonthYearFormatter.string(from: start)
        return "\(left) – \(shortMonthYearFormatter.string(from: end))"
    }

    // MARK: - Convenience on ISO strings

    public static func localDateTime(fromIso iso: String?) -> String? {
        instant(iso).map(dayAndTime)
    }

    public static func localTime(fromIso iso: String?) -> String? {
        instant(iso).map(time)
    }

    // MARK: - Internals

    private static func normalized(_ string: String?) -> String? {
        guard let trimmed = string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else { return nil }
        return trimmed
    }

    /// True when the string ends in `Z` or carries a `±HH:MM` offset.
    ///
    /// Only the part after `T` is examined: the date half contains hyphens of its own, so
    /// scanning the whole string for a sign would call every plain date zone-qualified.
    private static func hasZoneDesignator(_ iso: String) -> Bool {
        if iso.hasSuffix("Z") || iso.hasSuffix("z") { return true }
        guard let timeStart = iso.range(of: "T")?.upperBound else { return false }
        let timePart = iso[timeStart...]
        return timePart.contains("+") || timePart.contains("-")
    }

    /// Fractional seconds are optional on the wire, and a formatter configured for one form
    /// returns nil for the other — so both are tried rather than assumed.
    private static func parseISO(_ raw: String) -> Date? {
        if let date = isoWithFraction.date(from: raw) { return date }
        return isoPlain.date(from: raw)
    }

    private static func utcFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }

    private static let isoWithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoPlain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let isoWriter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    /// Date-only, read as UTC. Used by `lenient` as a last resort.
    private static let dayFormatter = utcFormatter("yyyy-MM-dd")

    /// Date-only in the reader's calendar — the correct reading for a calendar day.
    private static let localDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // Display formatters deliberately leave `timeZone` unset. `DateFormatter` then resolves
    // `TimeZone.current` at format time, so a user who crosses a boundary mid-session sees the
    // new zone without anything having to invalidate a cache.
    private static let timeFormatter = displayFormatter("h:mm a")
    private static let dayTimeFormatter = displayFormatter("EEE, MMM d 'at' h:mm a")
    private static let mediumDateFormatter = displayFormatter("MMM d, yyyy")
    private static let monthYearFormatter = displayFormatter("MMMM yyyy")
    private static let shortMonthFormatter = displayFormatter("MMM")
    private static let shortMonthYearFormatter = displayFormatter("MMM yyyy")

    private static func displayFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate(format)
        f.dateFormat = format
        return f
    }
}
