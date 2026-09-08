import XCTest
@testable import WarmupUIKit

/// The typed-number layer. Everything a person enters into a weight or RPE field, and everything
/// printed back at them, goes through here — so a mistake in this file is a mistake on every set
/// row in both apps at once.
final class NumericInputTests: XCTestCase {

    // MARK: - wholeOrDecimal: the crash

    /// A trainer's prescribed weight is free text. `Double("1e400")` is `+infinity`, and
    /// `Int(infinity)` traps — so one absurd weight took the whole app down on the exercise it
    /// appeared on. These inputs must come back as *some* string; the only failure mode that
    /// matters is not returning at all.
    func testAnAbsurdPrescribedWeightDoesNotTakeTheAppDown() {
        for value in [Double.infinity, -.infinity, .nan, .signalingNaN, 1e300, -1e300,
                      .greatestFiniteMagnitude, -.greatestFiniteMagnitude] {
            XCTAssertFalse(NumericInput.wholeOrDecimal(value).isEmpty,
                           "wholeOrDecimal must print something for \(value), not trap")
        }
    }

    /// "1e400" is the exact string that reached `Int(Double)` in production: it parses to
    /// infinity, and `infinity == infinity.rounded()` is true, so it walked straight into the
    /// trapping branch.
    func testTheFreeTextWeightThatCrashedTheAppNowRendersInstead() throws {
        let parsed = try XCTUnwrap("1e400".prescribedWeightValue)
        XCTAssertEqual(parsed, .infinity)
        XCTAssertFalse(LoadType.external.describeSet(reps: "5", weight: parsed, unit: "lbs").isEmpty,
                       "the set still has to render — a crash was the old behaviour")
    }

    /// A plate number reads as a plate number. "100.0 lbs" on a set chip looks like a bug to a
    /// trainer even though it is arithmetically fine.
    func testAWholeWeightPrintsWithoutATrailingPointZero() {
        XCTAssertEqual(NumericInput.wholeOrDecimal(100), "100")
        XCTAssertEqual(NumericInput.wholeOrDecimal(0), "0")
        XCTAssertEqual(NumericInput.wholeOrDecimal(-50), "-50")
    }

    /// Half-plates are real load. Rounding 102.5 to 102 silently changes what was prescribed.
    func testAHalfPlateSurvivesFormatting() {
        XCTAssertEqual(NumericInput.wholeOrDecimal(102.5), "102.5")
        XCTAssertEqual(NumericInput.wholeOrDecimal(2.5), "2.5")
        XCTAssertEqual(NumericInput.wholeOrDecimal(-7.5), "-7.5")
    }

    /// `formatRpe` and `formatWeight` are the two names call sites actually use; both must inherit
    /// the non-trapping behaviour rather than quietly reverting to `Int(...)`.
    func testTheRpeAndWeightFormattersInheritTheSafeConversion() {
        XCTAssertEqual(NumericInput.formatRpe(8), "8")
        XCTAssertEqual(NumericInput.formatRpe(7.5), "7.5")
        XCTAssertEqual(NumericInput.formatWeight(225), "225")
        XCTAssertEqual(NumericInput.formatWeight(102.5), "102.5")

        XCTAssertFalse(NumericInput.formatRpe(.nan).isEmpty)
        XCTAssertFalse(NumericInput.formatWeight(.infinity).isEmpty)
    }

    // MARK: - double: the vanishing entry

    /// A `.decimalPad` offers whichever separator the reader's locale uses. The bare `Double(...)`
    /// initialiser only understands a period, so a comma-locale user's half-plate arrived nil —
    /// the field looked accepted and the set logged without the number. Both separators must work
    /// whichever locale the test happens to run in.
    func testAHalfIsReadWhicheverSeparatorThePersonTyped() {
        XCTAssertEqual(NumericInput.double("7.5"), 7.5)
        XCTAssertEqual(NumericInput.double("7,5"), 7.5)
        XCTAssertEqual(NumericInput.double("102.5"), 102.5)
        XCTAssertEqual(NumericInput.double("102,5"), 102.5)
    }

    func testAPlainWholeNumberAndSurroundingWhitespaceAreAccepted() {
        XCTAssertEqual(NumericInput.double("225"), 225)
        XCTAssertEqual(NumericInput.double("  225  "), 225)
        XCTAssertEqual(NumericInput.double("-5"), -5)
    }

    /// An empty or non-numeric field must read as "nothing entered", not as zero — a set logged
    /// at 0 lbs is a different claim from a set logged without a weight.
    func testAnEmptyOrNonsenseFieldReadsAsNothingEntered() {
        XCTAssertNil(NumericInput.double(nil))
        XCTAssertNil(NumericInput.double(""))
        XCTAssertNil(NumericInput.double("   "))
        XCTAssertNil(NumericInput.double("heavy"))
        XCTAssertNil(NumericInput.double("abc"))
    }

    // MARK: - rpe

    /// RPE is a 1–10 scale in half steps. Anything else is refused at the field rather than
    /// persisted and puzzled over on a progress chart later.
    func testRpeAcceptsTheScaleAndItsHalfSteps() {
        XCTAssertEqual(NumericInput.rpe("1"), 1)
        XCTAssertEqual(NumericInput.rpe("10"), 10)
        XCTAssertEqual(NumericInput.rpe("7.5"), 7.5)
        XCTAssertEqual(NumericInput.rpe("7,5"), 7.5)
        XCTAssertEqual(NumericInput.rpe("8"), 8)
    }

    func testRpeRefusesValuesOffTheScaleOrOffTheHalfStepGrid() {
        XCTAssertNil(NumericInput.rpe("0.5"), "below the floor of the scale")
        XCTAssertNil(NumericInput.rpe("10.5"), "above the ceiling of the scale")
        XCTAssertNil(NumericInput.rpe("0"))
        XCTAssertNil(NumericInput.rpe("11"))
        XCTAssertNil(NumericInput.rpe("7.25"), "a quarter step is not a value the scale has")
        XCTAssertNil(NumericInput.rpe("hard"))
        XCTAssertNil(NumericInput.rpe(nil))
    }

    /// The state an RPE field marks in red. An untouched field is not an error — only text that
    /// is present and unusable is.
    func testAnUntouchedRpeFieldIsNotMarkedInvalid() {
        XCTAssertFalse(NumericInput.isInvalidRpe(nil))
        XCTAssertFalse(NumericInput.isInvalidRpe(""))
        XCTAssertFalse(NumericInput.isInvalidRpe("   "))
        XCTAssertFalse(NumericInput.isInvalidRpe("7.5"))
        XCTAssertFalse(NumericInput.isInvalidRpe("7,5"))

        XCTAssertTrue(NumericInput.isInvalidRpe("11"))
        XCTAssertTrue(NumericInput.isInvalidRpe("7.25"))
        XCTAssertTrue(NumericInput.isInvalidRpe("hard"))
    }
}
