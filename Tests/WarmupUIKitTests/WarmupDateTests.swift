import XCTest
@testable import WarmupUIKit

/// One parser for both apps. Dates were being read in ~100 places with ~100 opinions about a
/// missing zone; the failures were all silent and all multi-hour.
final class WarmupDateTests: XCTestCase {

    // NOTE: `WarmupDate.instant` calls `assertionFailure` on a zone-less string, which traps in a
    // debug test build — so the zone-less-returns-nil branch cannot be exercised from here. It is
    // covered indirectly: `lenient` is the only entry point that accepts a missing zone.

    // MARK: - instant

    /// The backend emits fractional seconds on some endpoints and not others. A formatter
    /// configured for one form returns nil for the other, which is how a whole day's workouts
    /// once vanished from "Today's Schedule".
    func testAWireTimestampParsesWithOrWithoutFractionalSeconds() {
        XCTAssertNotNil(WarmupDate.instant("2026-09-04T21:00:00Z"))
        XCTAssertNotNil(WarmupDate.instant("2026-09-04T21:00:00.123Z"))
        XCTAssertEqual(WarmupDate.instant("2026-09-04T21:00:00Z"),
                       WarmupDate.instant("2026-09-04T21:00:00.000Z"))
    }

    /// An offset is an instant just as much as a `Z` is. A 2pm Pacific workout is the same moment
    /// as 21:00 UTC, and reading one of the two forms wrong shifts a session by hours.
    func testAnOffsetAndAZuluTimestampDescribeTheSameMoment() {
        XCTAssertEqual(WarmupDate.instant("2026-09-04T14:00:00-07:00"),
                       WarmupDate.instant("2026-09-04T21:00:00Z"))
    }

    func testAnAbsentOrEmptyTimestampIsSimplyAbsent() {
        XCTAssertNil(WarmupDate.instant(nil))
        XCTAssertNil(WarmupDate.instant(""))
        XCTAssertNil(WarmupDate.instant("   "))
    }

    // MARK: - lenient

    /// Legacy payloads and locally-persisted strings arrive without a zone. This is the one entry
    /// point allowed to assume UTC, so that a regression on a fresh API instant stays loud.
    func testLegacyAndLocallyStoredShapesAreStillReadable() {
        XCTAssertNotNil(WarmupDate.lenient("2026-09-04T21:00:00Z"))
        XCTAssertNotNil(WarmupDate.lenient("2026-09-04T21:00:00"), "no zone — assumed UTC")
        XCTAssertNotNil(WarmupDate.lenient("2026-09-04T21:00:00.123"))
        XCTAssertNotNil(WarmupDate.lenient("2026-09-04 21:00:00"), "space instead of T")
        XCTAssertNotNil(WarmupDate.lenient("2026-09-04"), "date only")
    }

    func testAZonelessLegacyTimestampIsReadAsUtc() {
        XCTAssertEqual(WarmupDate.lenient("2026-09-04T21:00:00"),
                       WarmupDate.instant("2026-09-04T21:00:00Z"))
    }

    func testUnparseableTextIsNotGuessedAt() {
        XCTAssertNil(WarmupDate.lenient(nil))
        XCTAssertNil(WarmupDate.lenient(""))
        XCTAssertNil(WarmupDate.lenient("next tuesday"))
    }

    // MARK: - Calendar days

    /// A calendar day is a local question. Reading "2026-09-04" in UTC hands the wrong day to
    /// anyone east of Greenwich, and the wrong day again to the Americas after 4pm.
    func testACalendarDayIsReadAndWrittenInTheReadersOwnCalendar() throws {
        let day = try XCTUnwrap(WarmupDate.day("2026-09-04"))
        XCTAssertEqual(WarmupDate.dayString(day), "2026-09-04")

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: day)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 9)
        XCTAssertEqual(components.day, 4)
        XCTAssertEqual(components.hour, 0, "local midnight, not a UTC midnight shifted into another day")
    }

    func testAnAbsentDayStringIsAbsent() {
        XCTAssertNil(WarmupDate.day(nil))
        XCTAssertNil(WarmupDate.day(""))
        XCTAssertNil(WarmupDate.day("not-a-day"))
    }

    // MARK: - Encoding

    /// The encode side emitted fractional seconds while some decode paths refused them — the same
    /// value written in a shape its own reader rejected.
    func testWhatWeWriteIsWhatWeCanReadBack() throws {
        let now = Date(timeIntervalSince1970: 1_788_000_000)
        let written = WarmupDate.iso8601(now)

        XCTAssertTrue(written.hasSuffix("Z"), "always UTC on the wire")
        XCTAssertFalse(written.contains("."), "no fractional seconds — the backend parses seconds")
        XCTAssertEqual(WarmupDate.instant(written)?.timeIntervalSince1970, now.timeIntervalSince1970)
    }

    // MARK: - Month headers

    /// A week is not owned by the month its first day falls in. Titling Aug 30 – Sep 5 as "August"
    /// while the reader has Sep 4 selected states something the screen itself contradicts.
    func testAWeekStraddlingTwoMonthsNamesBoth() throws {
        let aug30 = try XCTUnwrap(WarmupDate.day("2026-08-30"))
        let sep5 = try XCTUnwrap(WarmupDate.day("2026-09-05"))

        let title = WarmupDate.monthAndYear(from: aug30, to: sep5)
        XCTAssertTrue(title.contains("–"), "expected a range, got \(title)")
        XCTAssertNotEqual(title, WarmupDate.monthAndYear(aug30))
        XCTAssertNotEqual(title, WarmupDate.monthAndYear(sep5))
    }

    func testAWeekInsideOneMonthJustNamesThatMonth() throws {
        let sep1 = try XCTUnwrap(WarmupDate.day("2026-09-01"))
        let sep7 = try XCTUnwrap(WarmupDate.day("2026-09-07"))

        XCTAssertEqual(WarmupDate.monthAndYear(from: sep1, to: sep7), WarmupDate.monthAndYear(sep1))
    }

    /// A range across New Year has to carry both years, or the header reads as a single ambiguous
    /// span twelve months wide.
    func testARangeAcrossNewYearNamesBothYears() throws {
        let dec28 = try XCTUnwrap(WarmupDate.day("2026-12-28"))
        let jan3 = try XCTUnwrap(WarmupDate.day("2027-01-03"))

        let title = WarmupDate.monthAndYear(from: dec28, to: jan3)
        XCTAssertTrue(title.contains("2026"), "expected 2026 in \(title)")
        XCTAssertTrue(title.contains("2027"), "expected 2027 in \(title)")
    }

    // MARK: - Convenience on ISO strings

    func testAnIsoStringConvertsStraightToDisplayTextOrToNothing() {
        XCTAssertNotNil(WarmupDate.localDateTime(fromIso: "2026-09-04T21:00:00Z"))
        XCTAssertNotNil(WarmupDate.localTime(fromIso: "2026-09-04T21:00:00Z"))
        XCTAssertNil(WarmupDate.localDateTime(fromIso: nil))
        XCTAssertNil(WarmupDate.localTime(fromIso: ""))
    }

    /// Display always belongs to the reader, never to the sender's zone. Formatting the same
    /// instant twice must agree, and must agree with a locally-built formatter.
    func testDisplayedTimesAreRenderedInTheReadersOwnTimezone() throws {
        let instant = try XCTUnwrap(WarmupDate.instant("2026-09-04T21:00:00Z"))

        let local = DateFormatter()
        local.dateFormat = "h:mm a"
        local.timeZone = .current

        XCTAssertEqual(WarmupDate.time(instant), local.string(from: instant))
    }
}
