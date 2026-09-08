import XCTest
@testable import WarmupUIKit

/// Small shared helpers that sit on top of a lot of screens: phone formatting, field validation,
/// and the date shims that both apps' timestamps flow through.
final class ExtensionsTests: XCTestCase {

    // MARK: - Phone display

    /// The number a client typed at sign-up, shown back to them. Anything unexpected is echoed
    /// untouched rather than mangled into a shape that isn't their number.
    func testAUsPhoneNumberIsShownInTheShapePeopleRecognise() {
        XCTAssertEqual("5551234567".formatPhoneForDisplay(), "(555) 123-4567")
        XCTAssertEqual("555-123-4567".formatPhoneForDisplay(), "(555) 123-4567")
        XCTAssertEqual("(555) 123 4567".formatPhoneForDisplay(), "(555) 123-4567")
        XCTAssertEqual("15551234567".formatPhoneForDisplay(), "+1 (555) 123-4567")
        XCTAssertEqual("+1 555 123 4567".formatPhoneForDisplay(), "+1 (555) 123-4567")
    }

    func testAnInternationalOrPartialNumberIsLeftExactlyAsGiven() {
        XCTAssertEqual("+44 20 7946 0958".formatPhoneForDisplay(), "+44 20 7946 0958")
        XCTAssertEqual("12345".formatPhoneForDisplay(), "12345")
        XCTAssertEqual("".formatPhoneForDisplay(), "")
    }

    // MARK: - Field validation

    /// The gate on the sign-up field. Too strict and a real client cannot create an account.
    func testARealEmailAddressPassesTheSignUpField() {
        XCTAssertTrue("finley@example.com".isValidEmail)
        XCTAssertTrue("FINLEY@EXAMPLE.COM".isValidEmail)
        XCTAssertTrue("finley.coach+warmup@example.co.uk".isValidEmail)
    }

    func testTextThatIsNotAnEmailAddressIsRejected() {
        XCTAssertFalse("finley".isValidEmail)
        XCTAssertFalse("finley@".isValidEmail)
        XCTAssertFalse("finley@example".isValidEmail)
        XCTAssertFalse("@example.com".isValidEmail)
        XCTAssertFalse("".isValidEmail)
    }

    func testThePasswordFloorIsEightCharacters() {
        XCTAssertTrue("12345678".isValidPassword)
        XCTAssertFalse("1234567".isValidPassword)
        XCTAssertFalse("".isValidPassword)
    }

    func testTrimmedRemovesNewlinesAsWellAsSpaces() {
        XCTAssertEqual("  Finley \n ".trimmed, "Finley")
        XCTAssertEqual("   ".trimmed, "")
    }

    // MARK: - Date shims

    /// Both shims delegate to `WarmupDate` so there is one parser rather than one per file. If
    /// they drift, the app is back to a hundred opinions about a missing zone.
    func testTheDateShimsAgreeWithTheOneSharedParser() {
        XCTAssertEqual(Date.fromISO8601String("2026-09-04T21:00:00Z"),
                       WarmupDate.instant("2026-09-04T21:00:00Z"))
        XCTAssertEqual(Date.fromISO8601String("2026-09-04T21:00:00.123Z"),
                       WarmupDate.lenient("2026-09-04T21:00:00.123Z"))
        XCTAssertNotNil(Date.fromISO8601String("2026-09-04T21:00:00"),
                        "the non-fractional form once returned nil and emptied Today's Schedule")

        let now = Date(timeIntervalSince1970: 1_788_000_000)
        XCTAssertEqual(now.iso8601String, WarmupDate.iso8601(now))
    }

    /// The writer emitted fractional seconds while some readers refused them — one value written
    /// in a shape its own reader rejected.
    func testAWrittenTimestampCanBeReadBackByTheSameApp() throws {
        let now = Date(timeIntervalSince1970: 1_788_000_000)
        let written = now.iso8601String

        XCTAssertFalse(written.contains("."))
        let readBack = try XCTUnwrap(Date.fromISO8601String(written))
        XCTAssertEqual(readBack.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 0.001)
    }

    func testAnIsoStringParsesWithOrWithoutFractionalSeconds() {
        XCTAssertNotNil("2026-09-04T21:00:00Z".toISO8601Date())
        XCTAssertNotNil("2026-09-04T21:00:00.123Z".toISO8601Date())
        XCTAssertNil("not a date".toISO8601Date())
    }

    func testASimpleDateStringParsesAndUnparseableTextDoesNot() {
        XCTAssertNotNil("2026-09-04".toSimpleDate())
        XCTAssertNil("2026-13-45".toSimpleDate())
        XCTAssertNil("".toSimpleDate())
    }

    /// The abbreviated stamp under a message bubble and a feed card.
    func testARecentTimestampReadsAsAShortRelativeStamp() {
        let now = Date()
        XCTAssertEqual(DateFormatter.timeAgo(from: now), "now")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-30)), "now",
                       "under a minute is still 'now', not '0m'")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-60)), "1m")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-300)), "5m")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-3600)), "1h")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-7200)), "2h")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-86400)), "1d")
        XCTAssertEqual(DateFormatter.timeAgo(from: now.addingTimeInterval(-259200)), "3d")
    }

    /// Rounding a picked time to the hour for a proposed session slot.
    func testAProposedTimeRoundsToTheNearestHour() throws {
        let calendar = Calendar.current
        let base = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 4,
                                                                    hour: 14, minute: 29)))
        let up = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 4,
                                                                  hour: 14, minute: 30)))

        XCTAssertEqual(calendar.component(.hour, from: base.rounded(to: .hour)), 14)
        XCTAssertEqual(calendar.component(.minute, from: base.rounded(to: .hour)), 0)
        XCTAssertEqual(calendar.component(.hour, from: up.rounded(to: .hour)), 15)
        XCTAssertEqual(calendar.component(.minute, from: up.rounded(to: .hour)), 0)
    }

    /// Only the hour is implemented; every other component must hand the date back unchanged
    /// rather than silently returning something adjacent.
    func testRoundingToAnUnsupportedComponentChangesNothing() throws {
        let date = try XCTUnwrap(WarmupDate.instant("2026-09-04T21:17:33Z"))
        XCTAssertEqual(date.rounded(to: .minute), date)
        XCTAssertEqual(date.rounded(to: .day), date)
    }
}
