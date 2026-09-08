import XCTest
@testable import WarmupUIKit

/// The set / entry / section shapes the plan sheet and the logging screen both render from.
final class WorkoutModelTests: XCTestCase {

    // MARK: - ExerciseSet: how a set reads

    /// A prescribed range must survive to the screen. Collapsing "8-12" to one number changes the
    /// prescription; printing "" leaves the row blank.
    func testARepPrescriptionReadsBackTheWayItWasWritten() {
        XCTAssertEqual(ExerciseSet(reps: nil, minReps: 8, maxReps: 12).repRangeDisplay, "8-12")
        XCTAssertEqual(ExerciseSet(reps: nil, minReps: 10, maxReps: 10).repRangeDisplay, "10")
        XCTAssertEqual(ExerciseSet(reps: 10).repRangeDisplay, "10")
        XCTAssertEqual(ExerciseSet().repRangeDisplay, "")

        XCTAssertTrue(ExerciseSet(reps: nil, minReps: 8, maxReps: 12).hasRepRange)
        XCTAssertFalse(ExerciseSet(reps: nil, minReps: 10, maxReps: 10).hasRepRange)
        XCTAssertFalse(ExerciseSet(reps: 10).hasRepRange)
    }

    /// The logging screen swaps a rep stepper for a timer on this answer. A plank that prescribes
    /// neither reps nor load has nothing else it could mean.
    func testASetMeasuredByTheClockIsRecognisedEvenWithNoDurationYet() {
        XCTAssertTrue(ExerciseSet(duration: 60).isTimeBasedPrescription, "an explicit hold")
        XCTAssertTrue(ExerciseSet().isTimeBasedPrescription, "no reps, no load — nothing else it can be")

        XCTAssertFalse(ExerciseSet(reps: 10).isTimeBasedPrescription)
        XCTAssertFalse(ExerciseSet(reps: nil, minReps: 8, maxReps: 12).isTimeBasedPrescription)
        XCTAssertFalse(ExerciseSet(weight: 135).isTimeBasedPrescription)
    }

    /// A set with a marker resolves through it; an un-migrated set still resolves off its text.
    func testASetKnowsHowItIsLoadedFromEitherTheMarkerOrTheLegacyText() {
        var marked = ExerciseSet(reps: 10)
        marked.loadType = "BODYWEIGHT"
        XCTAssertEqual(marked.load, .bodyweight)

        var legacy = ExerciseSet(reps: 10)
        legacy.weight = "bodyweight"
        XCTAssertEqual(legacy.load, .bodyweight)

        XCTAssertEqual(ExerciseSet(reps: 10, weight: 135).load, .external)
    }

    /// The weight column with no RPE or RIR prescribed. Routing through the load type is what
    /// stops a push-up echoing the raw token "bodyweight lbs".
    func testTheEffortColumnDescribesTheLoadWhenNoEffortIsPrescribed() {
        var bodyweight = ExerciseSet(reps: 15)
        bodyweight.loadType = "BODYWEIGHT"
        XCTAssertEqual(bodyweight.effortDisplay, "bodyweight")

        var kilos = ExerciseSet(reps: 5, weight: 100)
        kilos.weightUnit = "kg"
        XCTAssertEqual(kilos.effortDisplay, "100 kg", "the unit prescribed, not a hardcoded lbs")

        var unloaded = ExerciseSet(reps: 10)
        unloaded.loadType = "UNLOADED"
        XCTAssertEqual(unloaded.effortDisplay, "", "a stretch has no load to report")
    }

    func testTheEffortColumnNamesTheScaleWhenOneIsPrescribed() {
        XCTAssertEqual(ExerciseSet(reps: 8, targetRpe: 7.5, effortType: "RPE").effortDisplay, "RPE 7.5")
        XCTAssertEqual(ExerciseSet(reps: 8, targetRpe: 8, effortType: "RPE").effortDisplay, "RPE 8")
        XCTAssertEqual(ExerciseSet(reps: 8, rir: 3, effortType: "RIR").effortDisplay, "3 RIR")
        XCTAssertEqual(ExerciseSet(reps: 8, effortType: "RPE").effortDisplay, "RPE",
                       "the label alone when the trainer has not filled in a number yet")
    }

    /// An unrecognised effort type must fall back to describing the load rather than crashing or
    /// printing the raw token.
    func testAnUnknownEffortTypeFallsBackToTheLoad() {
        var set = ExerciseSet(reps: 8, weight: 135, effortType: "SOMETHING_NEW")
        set.weightUnit = "lbs"
        XCTAssertEqual(set.effortTypeEnum, .none)
        XCTAssertEqual(set.effortDisplay, "135 lbs")
    }

    func testATargetRpeIsPrintedForPeopleNotMachines() {
        XCTAssertEqual(ExerciseSet.formatRpe(8), "8")
        XCTAssertEqual(ExerciseSet.formatRpe(7.5), "7.5")
        XCTAssertEqual(ExerciseSet.formatRpe(10), "10")
    }

    /// Numbers travel to the backend as strings. If these readers stop agreeing with the writer,
    /// a set logs without its weight or rest.
    func testTheStringBackedNumbersOnASetReadBackAsNumbers() {
        let set = ExerciseSet(reps: 8, weight: 102.5, rir: 3, rest: 90)
        XCTAssertEqual(set.weightValue, 102.5)
        XCTAssertEqual(set.rirValue, 3)
        XCTAssertEqual(set.restValue, 90)

        let empty = ExerciseSet()
        XCTAssertNil(empty.weightValue)
        XCTAssertNil(empty.rirValue)
        XCTAssertNil(empty.restValue)
    }

    /// The unit, the marker and the hold all have to reach the server. Dropping any of the three
    /// sent a set that said nothing, which the server rightly rejected.
    func testASetSentToTheServerCarriesItsUnitItsMarkerAndItsHold() {
        var set = ExerciseSet(reps: nil, weight: 25, rest: 60, duration: 45)
        set.weightUnit = "kg"
        set.loadType = "BODYWEIGHT_PLUS"

        let dto = set.toDto()
        XCTAssertEqual(dto.durationSeconds, 45)
        XCTAssertEqual(dto.weightUnit, "kg")
        XCTAssertEqual(dto.loadType, "BODYWEIGHT_PLUS")
        XCTAssertEqual(dto.weight, "25.0")
        XCTAssertEqual(dto.rest, "60")
    }

    // MARK: - Superset letters

    /// Superset letters are derived at render time, never stored. A workout with more than 26
    /// supersets is absurd but must not produce a garbled label or trap.
    func testSupersetsAreLetteredAToZAndThenAaOnwards() {
        XCTAssertEqual(Superset.letter(forRank: 0), "A")
        XCTAssertEqual(Superset.letter(forRank: 1), "B")
        XCTAssertEqual(Superset.letter(forRank: 25), "Z")
        XCTAssertEqual(Superset.letter(forRank: 26), "AA")
        XCTAssertEqual(Superset.letter(forRank: 27), "AB")
        XCTAssertEqual(Superset.letter(forRank: 51), "AZ")
        XCTAssertEqual(Superset.letter(forRank: 52), "BA")
        XCTAssertEqual(Superset.letter(forRank: -1), "?", "no letter rather than an unprintable one")
    }

    /// The letter follows the superset's position in the section, not the order it happened to be
    /// decoded in — otherwise B appears above A on screen.
    func testASupersetsLetterFollowsItsPositionInTheSectionNotTheArrayOrder() {
        let second = Superset(id: "s2", order: 3, memberEntryIds: ["e3", "e4"])
        let first = Superset(id: "s1", order: 0, memberEntryIds: ["e1", "e2"])
        let section = WorkoutSection(name: "Main", order: 0, entries: [], supersets: [second, first])

        XCTAssertEqual(section.supersetLetter(for: first), "A")
        XCTAssertEqual(section.supersetLetter(for: second), "B")
    }

    /// A superset that isn't in this section at all still has to render something.
    func testAnUnknownSupersetFallsBackToTheFirstLetter() {
        let section = WorkoutSection(name: "Main", order: 0)
        XCTAssertEqual(section.supersetLetter(for: Superset(id: "ghost", order: 0)), "A")
    }

    // MARK: - Section display order

    /// A superset occupies the slot of its first member, and standalone entries keep their own —
    /// so the rendered order is the order the client will actually train in.
    func testASectionRendersSupersetsAndStandaloneEntriesInTrainingOrder() {
        let warmup = ExerciseEntry(id: "e0", name: "Row", order: 0)
        let a1 = ExerciseEntry(id: "e1", name: "Bench Press", order: 1)
        let a2 = ExerciseEntry(id: "e2", name: "Bent Over Row", order: 2)
        let finisher = ExerciseEntry(id: "e3", name: "Plank", order: 3)

        let section = WorkoutSection(
            name: "Main", order: 0,
            entries: [finisher, a2, warmup, a1],
            supersets: [Superset(id: "s1", order: 1, memberEntryIds: ["e1", "e2"])]
        )

        let items = section.orderedDisplayItems()
        XCTAssertEqual(items.count, 3, "two standalone entries and one superset occupying one slot")

        guard case .entry(let firstEntry) = items[0] else { return XCTFail("expected the warm-up first") }
        XCTAssertEqual(firstEntry.name, "Row")

        guard case .superset(_, let letter, let members) = items[1] else {
            return XCTFail("expected the superset in its first member's slot")
        }
        XCTAssertEqual(letter, "A")
        XCTAssertEqual(members.map(\.name), ["Bench Press", "Bent Over Row"],
                       "members in membership order, which is execution order")

        guard case .entry(let lastEntry) = items[2] else { return XCTFail("expected the finisher last") }
        XCTAssertEqual(lastEntry.name, "Plank")
    }

    /// A superset naming an entry that isn't in the section must not fabricate one or drop the
    /// whole group.
    func testASupersetPointingAtAMissingEntryStillRendersItsRealMembers() {
        let a1 = ExerciseEntry(id: "e1", name: "Bench Press", order: 0)
        let section = WorkoutSection(
            name: "Main", order: 0, entries: [a1],
            supersets: [Superset(id: "s1", order: 0, memberEntryIds: ["e1", "missing"])]
        )

        let items = section.orderedDisplayItems()
        XCTAssertEqual(items.count, 1)
        guard case .superset(_, _, let members) = items[0] else { return XCTFail("expected a superset") }
        XCTAssertEqual(members.map(\.name), ["Bench Press"])
    }

    // MARK: - Section naming

    /// Contract §8: a section with no name is still a section the trainer has to be able to point
    /// at, and "Section 1" is 0-based order plus one.
    func testAnUnnamedSectionIsStillNamedForTheTrainer() {
        XCTAssertEqual(WorkoutSection(name: "Main Lift", order: 0).displayName, "Main Lift")
        XCTAssertEqual(WorkoutSection(name: nil, order: 0).displayName, "Section 1")
        XCTAssertEqual(WorkoutSection(name: "   ", order: 2).displayName, "Section 3")
        XCTAssertEqual(WorkoutSection(name: nil, order: nil).displayName, "Section")
    }

    func testAnEmptySectionKnowsItIsEmpty() {
        XCTAssertTrue(WorkoutSection(name: "Main", order: 0).isEmpty)
        XCTAssertEqual(WorkoutSection(name: "Main", order: 0).exerciseCount, 0)

        let filled = WorkoutSection(name: "Main", order: 0,
                                    entries: [ExerciseEntry(name: "Bench Press")])
        XCTAssertFalse(filled.isEmpty)
        XCTAssertEqual(filled.exerciseCount, 1)
    }

    // MARK: - ExerciseEntry

    func testAnEntryReportsHowManySetsItActuallyHas() {
        XCTAssertEqual(ExerciseEntry(name: "Bench Press").setCount, 0)
        XCTAssertEqual(ExerciseEntry(name: "Bench Press", sets: [ExerciseSet(reps: 8),
                                                                ExerciseSet(reps: 8)]).setCount, 2)
    }

    /// An AI-drafted exercise has a placeholder id, not a library one. Treating it as persisted
    /// means saving a workout that points at a row the library does not have.
    func testAnAiDraftedExerciseIsNotMistakenForALibraryExercise() {
        XCTAssertTrue(ExerciseEntry(exerciseId: "9f2a-real", name: "Bench Press").isPersisted)

        for placeholder in ["draft_1", "ai_1", "new_1", "temp_1", "AI_1"] {
            XCTAssertFalse(ExerciseEntry(exerciseId: placeholder, name: "Bench Press").isPersisted,
                           "\(placeholder) is a placeholder, not a library id")
        }

        XCTAssertFalse(ExerciseEntry(exerciseId: nil, name: "Bench Press").isPersisted)
        XCTAssertFalse(ExerciseEntry(exerciseId: "", name: "Bench Press").isPersisted)
    }

    func testAnExerciseWithNoLibraryLinkIsFlaggedForLinking() {
        XCTAssertTrue(ExerciseEntry(exerciseId: nil, name: "Bench Press").needsExerciseLinking)
        XCTAssertTrue(ExerciseEntry(exerciseId: "", name: "Bench Press").needsExerciseLinking)
        XCTAssertFalse(ExerciseEntry(exerciseId: "9f2a-real", name: "Bench Press").needsExerciseLinking)
    }

    // MARK: - Decoding tolerance

    /// The backend emits `entries: null` and `supersets: null` rather than omitting them. Decoding
    /// those as a failure loses the whole workout.
    func testASectionDecodesWhenTheBackendSendsNullsInsteadOfLists() throws {
        let json = Data(#"{"id":"s1","name":"Main","order":0,"entries":null,"supersets":null}"#.utf8)
        let section = try JSONDecoder().decode(WorkoutSection.self, from: json)

        XCTAssertEqual(section.entries.count, 0)
        XCTAssertEqual(section.supersets.count, 0)
        XCTAssertEqual(section.displayName, "Main")
    }

    func testASupersetDecodesWithNoMembersRatherThanFailing() throws {
        let json = Data(#"{"id":"s1","order":0}"#.utf8)
        let superset = try JSONDecoder().decode(Superset.self, from: json)
        XCTAssertEqual(superset.memberEntryIds, [])
    }
}
