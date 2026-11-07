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

    /// The max box's real setter (SetEditRowEnhanced calls exactly this). These tests used to
    /// re-implement it, which proves nothing about the code the box runs.
    private func enterMax(_ value: String, on set: inout ExerciseSet) { set.editMaxReps(value) }
    private func enterMin(_ value: String, on set: inout ExerciseSet) { set.editMinReps(value) }

    // MARK: - No stale `reps` under an edit (trainer feedback 2026-11-06)
    //
    // Every set in a real trainer's workout read `reps: 12` beneath the range they typed,
    // and the client app showed 12. Whatever order a reader resolves the three fields in,
    // they must now agree.

    /// The three resolution orders seen in the wild: this kit, the old client, the old seed.
    private func readings(_ s: ExerciseSet) -> [String] {
        let range = (s.minReps != nil && s.maxReps != nil && s.minReps != s.maxReps)
            ? "\(s.minReps!)-\(s.maxReps!)" : nil
        let clientOrder = range ?? (s.reps ?? s.minReps ?? s.maxReps).map(String.init) ?? ""
        let seedOrder = range ?? (s.reps ?? s.minReps ?? s.maxReps).map(String.init) ?? ""
        return [s.repRangeDisplay, clientOrder, seedOrder]
    }

    func testChangingADefaultSetToARangeLeavesNoStaleRepsUnderIt() {
        var set = ExerciseSet(reps: 12)
        enterMin("5", on: &set)
        enterMax("6", on: &set)

        XCTAssertEqual(set.repRangeDisplay, "5-6")
        XCTAssertEqual(set.reps, 5, "the old 12 is still stored and a reader preferring reps shows it")
        XCTAssertEqual(Set(readings(set)), ["5-6"])
    }

    func testChangingADefaultSetToASingleNumberViaTheMinBoxIsWhatEveryReaderSees() {
        // Seated Box Jump: the trainer typed 5 into the min box and the client still read 12.
        var set = ExerciseSet(reps: 12)
        enterMin("5", on: &set)

        XCTAssertEqual(set.reps, 5)
        XCTAssertEqual(Set(readings(set)), ["5"])
    }

    func testClearingTheMinBoxKeepsTheCountItFallsBackTo() {
        var set = ExerciseSet(reps: 12)
        enterMin("8", on: &set)
        enterMin("", on: &set)

        XCTAssertNil(set.minReps)
        XCTAssertEqual(set.reps, 8, "the box now shows reps; it must be the last count typed")
        XCTAssertEqual(minBoxShows(set), "8")
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
