import XCTest
@testable import WarmupUIKit

/// What the rep boxes save versus what they show.
///
/// This trap has now been sprung twice, on opposite sides of the same row. First the max box
/// fell back to `set.reps`, so an unset max rendered a solid "12" that looked entered and the
/// workout showed "8". That was fixed by removing the fallback. The min box kept its fallback —
/// correctly, because for a plain 12-rep set the 12 genuinely is the low end — but a displayed
/// value that is never written is the same bug wearing the other shoe: a trainer who typed only
/// a max got `minReps: nil, maxReps: 14`, and "12 - 14" on screen saved as a bare "14".
///
/// The invariant worth holding is not about either box. It is that what the row displays and
/// what `repRangeDisplay` renders never disagree.
final class RepRangeEditingTests: XCTestCase {

    /// Mirrors the max box's setter in SetEditRowEnhanced.repRangeInputs.
    private func enterMax(_ value: String, on set: inout ExerciseSet) {
        set.maxReps = Int(value)
        if set.maxReps != nil, set.minReps == nil {
            set.minReps = set.reps
        }
    }

    /// Mirrors the min box's getter — what the trainer actually sees in the left box.
    private func minBoxShows(_ set: ExerciseSet) -> String {
        (set.minReps ?? set.reps).map(String.init) ?? ""
    }

    func testTypingOnlyAMaxOnAPlainSetKeepsTheRange() {
        // The exact reported case: a set defaulted to 12 reps, trainer types 14 into max.
        var set = ExerciseSet(reps: 12)
        XCTAssertEqual(minBoxShows(set), "12", "the min box shows 12 before anything is typed")

        enterMax("14", on: &set)

        XCTAssertEqual(set.minReps, 12, "the 12 the trainer could see was never saved")
        XCTAssertEqual(set.repRangeDisplay, "12-14",
                       "the range the trainer entered collapsed to a single number")
    }

    func testAnExplicitMinIsNotOverwritten() {
        // Sets 2 and 3 in the report, where both boxes were typed. Must stay untouched.
        var set = ExerciseSet(reps: 12, minReps: 8)
        enterMax("12", on: &set)

        XCTAssertEqual(set.minReps, 8)
        XCTAssertEqual(set.repRangeDisplay, "8-12")
    }

    func testClearingTheMaxDoesNotInventAMin() {
        // Emptying the box means "no range". Adopting a min there would fabricate one.
        var set = ExerciseSet(reps: 12)
        enterMax("", on: &set)

        XCTAssertNil(set.maxReps)
        XCTAssertNil(set.minReps)
        XCTAssertEqual(set.repRangeDisplay, "12", "a plain set should still read as its rep count")
    }

    func testWhatTheBoxesShowIsWhatTheWorkoutRenders() {
        // The invariant behind both bugs, stated directly.
        var set = ExerciseSet(reps: 12)
        enterMax("14", on: &set)

        let shown = "\(minBoxShows(set))-\(set.maxReps.map(String.init) ?? "")"
        XCTAssertEqual(shown, set.repRangeDisplay,
                       "the editor and the workout disagree about this set")
    }

    func testASetWithNoRepsAtAllStillTakesAMax() {
        // A duration-only set that later gains a rep target must not crash or invent a min.
        var set = ExerciseSet()
        enterMax("10", on: &set)

        XCTAssertEqual(set.maxReps, 10)
        XCTAssertNil(set.minReps, "there was no rep count to adopt")
        XCTAssertEqual(set.repRangeDisplay, "10")
    }
}
