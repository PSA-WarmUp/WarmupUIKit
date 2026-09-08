import XCTest
@testable import WarmupUIKit

/// How a set describes its own load. This wording reaches the plan sheet, the logging screen and
/// the share card, so a wrong answer here is wrong in three places for the same set.
final class LoadTypeTests: XCTestCase {

    // MARK: - resolve

    func testTheServersMarkerDecidesTheLoadTypeWhenItIsSent() {
        XCTAssertEqual(LoadType.resolve(marker: "EXTERNAL", prescribedWeight: nil), .external)
        XCTAssertEqual(LoadType.resolve(marker: "BODYWEIGHT", prescribedWeight: nil), .bodyweight)
        XCTAssertEqual(LoadType.resolve(marker: "BODYWEIGHT_PLUS", prescribedWeight: nil), .bodyweightPlus)
        XCTAssertEqual(LoadType.resolve(marker: "UNLOADED", prescribedWeight: nil), .unloaded)
    }

    /// The marker arrives as text on the wire; casing and stray whitespace must not decide whether
    /// a pull-up asks the client for a number.
    func testAMarkerIsReadRegardlessOfCasingOrPadding() {
        XCTAssertEqual(LoadType.resolve(marker: "bodyweight", prescribedWeight: nil), .bodyweight)
        XCTAssertEqual(LoadType.resolve(marker: "  Bodyweight_Plus  ", prescribedWeight: nil), .bodyweightPlus)
    }

    /// Nothing was migrated server-side: old rows carry no marker and spell "bodyweight" into the
    /// weight field instead. Lose this fallback and every historic push-up asks for a plate number.
    func testALegacySetThatSpellsBodyweightIntoTheWeightFieldIsStillUnderstood() {
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "bodyweight"), .bodyweight)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "Bodyweight"), .bodyweight)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "bw"), .bodyweight)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: " bw "), .bodyweight)
    }

    /// "bodyweight + 25" is a weighted pull-up written by hand. It has to keep its weight field,
    /// which is the only place the client's belt plate can go.
    func testAHandWrittenAddedLoadResolvesToBodyweightPlus() {
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "bodyweight + 25"), .bodyweightPlus)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "BODYWEIGHT+45"), .bodyweightPlus)
    }

    func testAnythingElseIsTreatedAsRackedLoad() {
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "135"), .external)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: "75% of max"), .external)
        XCTAssertEqual(LoadType.resolve(marker: nil, prescribedWeight: nil), .external)
        XCTAssertEqual(LoadType.resolve(marker: "NOT_A_REAL_MARKER", prescribedWeight: nil), .external)
    }

    /// An unknown marker must not shadow the legacy text — the fallback is the only thing standing
    /// between an un-migrated push-up and a weight keypad.
    func testAnUnknownMarkerFallsBackToReadingTheWeightText() {
        XCTAssertEqual(LoadType.resolve(marker: "SOMETHING_NEW", prescribedWeight: "bodyweight"), .bodyweight)
    }

    // MARK: - hidesWeightInput

    /// The logging screen asked for a number the client cannot supply, placeheld with the
    /// truncated word "bo…". A push-up and a stretch have no number; a weighted dip does.
    func testOnlySetsWithNoNumberToGiveHideTheWeightKeypad() {
        XCTAssertTrue(LoadType.bodyweight.hidesWeightInput)
        XCTAssertTrue(LoadType.unloaded.hidesWeightInput)
        XCTAssertFalse(LoadType.bodyweightPlus.hidesWeightInput, "the belt plate is still the client's own number")
        XCTAssertFalse(LoadType.external.hidesWeightInput)
    }

    // MARK: - describeLoad

    /// The plan sheet read "15 reps · bodyweight lbs" because a unit was appended unconditionally.
    func testBodyweightNeverGetsAUnitAppendedToTheWord() {
        XCTAssertEqual(LoadType.bodyweight.describeLoad(weight: nil, unit: "lbs"), "bodyweight")
        XCTAssertEqual(LoadType.bodyweight.describeLoad(weight: 100, unit: "kg"), "bodyweight")
    }

    /// Nil rather than "" so the caller can drop the separator instead of printing "12 reps · ".
    func testAStretchContributesNoLoadSegmentAtAll() {
        XCTAssertNil(LoadType.unloaded.describeLoad(weight: nil, unit: "lbs"))
        XCTAssertNil(LoadType.unloaded.describeLoad(weight: 100, unit: "lbs"))
        XCTAssertNil(LoadType.external.describeLoad(weight: nil, unit: "lbs"))
    }

    func testARackedWeightIsLabelledWithTheUnitItWasPrescribedIn() {
        XCTAssertEqual(LoadType.external.describeLoad(weight: 100, unit: "lbs"), "100 lbs")
        XCTAssertEqual(LoadType.external.describeLoad(weight: 102.5, unit: "kg"), "102.5 kg")
    }

    /// A missing unit must not turn someone's kilos into pounds on screen — but it has to say
    /// something, and pounds is the app's default.
    func testAMissingUnitFallsBackToPoundsRatherThanPrintingNothing() {
        XCTAssertEqual(LoadType.external.describeLoad(weight: 100, unit: nil), "100 lbs")
        XCTAssertEqual(LoadType.external.describeLoad(weight: 100, unit: ""), "100 lbs")
    }

    /// The belt plate is the *added* load, so it reads as an addition. With no plate on the belt
    /// the honest description is just "bodyweight" — not "bodyweight + 0 lbs".
    func testAWeightedPullUpReadsAsBodyweightPlusItsAddedPlate() {
        XCTAssertEqual(LoadType.bodyweightPlus.describeLoad(weight: 25, unit: "lbs"), "bodyweight + 25 lbs")
        XCTAssertEqual(LoadType.bodyweightPlus.describeLoad(weight: 2.5, unit: "kg"), "bodyweight + 2.5 kg")
        XCTAssertEqual(LoadType.bodyweightPlus.describeLoad(weight: nil, unit: "lbs"), "bodyweight")
        XCTAssertEqual(LoadType.bodyweightPlus.describeLoad(weight: 0, unit: "lbs"), "bodyweight")
    }

    // MARK: - describeSet

    func testASetPrescribingBothRepsAndLoadNamesBoth() {
        XCTAssertEqual(LoadType.external.describeSet(reps: "12", weight: 100, unit: "lbs"), "12 reps · 100 lbs")
        XCTAssertEqual(LoadType.bodyweightPlus.describeSet(reps: "8", weight: 25, unit: "lbs"),
                       "8 reps · bodyweight + 25 lbs")
    }

    /// Reps travel as text precisely so a prescribed range survives into the summary.
    func testARepRangeIsPrintedAsPrescribedRatherThanCollapsedToANumber() {
        XCTAssertEqual(LoadType.external.describeSet(reps: "8-12", weight: 100, unit: "lbs"), "8-12 reps · 100 lbs")
    }

    /// Half a prescription still has to read as a sentence — no leading or dangling separator.
    func testASetWithOnlyOneHalfOfThePrescriptionOmitsTheSeparator() {
        XCTAssertEqual(LoadType.external.describeSet(reps: nil, weight: 100, unit: "lbs"), "100 lbs")
        XCTAssertEqual(LoadType.external.describeSet(reps: "", weight: 100, unit: "lbs"), "100 lbs")
        XCTAssertEqual(LoadType.bodyweight.describeSet(reps: "15", weight: nil, unit: "lbs"), "15 reps · bodyweight")
        XCTAssertEqual(LoadType.external.describeSet(reps: "12", weight: nil, unit: "lbs"), "12 reps")
        XCTAssertEqual(LoadType.unloaded.describeSet(reps: "10", weight: nil, unit: "lbs"), "10 reps")
    }

    /// A set with neither reps nor load renders as a blank line today. That is only acceptable
    /// while nothing else could have been said about it — see the skipped hold test below, where
    /// there *is* something to say.
    func testASetWithNothingPrescribedRendersAsNothing() {
        XCTAssertEqual(LoadType.unloaded.describeSet(reps: nil, weight: nil, unit: nil), "")
    }

    /// A plank, a farmer's carry and a dead hang prescribe a hold, not reps and not load.
    /// `describeSet` used to take only `(reps:weight:unit:)`, so every one of them summarised
    /// as the empty string — a blank line in both apps and on the share card, where the
    /// exercise appears to ask for nothing at all.
    func testAHoldSaysHowLongItIsRatherThanRenderingABlankLine() {
        // Exactly the shape a hold arrives in: no reps, no load, a duration.
        XCTAssertEqual(
            LoadType.bodyweight.describeSet(reps: nil, weight: nil, unit: nil, durationSeconds: 45),
            "45s · bodyweight")
        XCTAssertEqual(
            LoadType.unloaded.describeSet(reps: nil, weight: nil, unit: nil, durationSeconds: 60),
            "60s",
            "an unloaded hold has no load half, so the time is the whole summary")
        XCTAssertFalse(
            LoadType.unloaded.describeSet(reps: nil, weight: nil, unit: nil, durationSeconds: 30).isEmpty,
            "a prescribed hold must never summarise as nothing")
    }

    /// Holds are said in seconds up to two minutes because that is how a coach counts them —
    /// a plank is "sixty seconds", not "one minute". The rule matches the server's so the same
    /// set cannot read two ways depending on which side rendered it.
    func testAHoldIsPhrasedTheWayACoachWouldSayIt() {
        let cases: [(Int, String)] = [
            (45, "45s"), (60, "60s"), (90, "90s"),
            (119, "119s"), (120, "2m"), (150, "2m 30s"), (600, "10m"),
        ]
        for (seconds, expected) in cases {
            XCTAssertEqual(
                LoadType.unloaded.describeSet(reps: nil, weight: nil, unit: nil,
                                              durationSeconds: seconds),
                expected, "\(seconds) seconds should read as \(expected)")
        }
    }

    func testAHoldWithRepsAndLoadReadsInPrescriptionOrder() {
        // A weighted carry has all three. Reps, then the hold, then the load — the order a
        // coach writes them and a client reads them.
        XCTAssertEqual(
            LoadType.external.describeSet(reps: "3", weight: 40, unit: "kg", durationSeconds: 30),
            "3 reps · 30s · 40 kg")
    }

    func testAZeroOrMissingDurationAddsNothing() {
        // Guards the separator: a set that is not time-based must not gain a stray " · ".
        XCTAssertEqual(
            LoadType.external.describeSet(reps: "8", weight: 100, unit: "lbs", durationSeconds: 0),
            "8 reps · 100 lbs")
        XCTAssertEqual(
            LoadType.external.describeSet(reps: "8", weight: 100, unit: "lbs"),
            "8 reps · 100 lbs")
    }

    // MARK: - String.prescribedWeightValue

    func testAPlainPrescribedNumberIsReadWithOrWithoutItsUnit() {
        XCTAssertEqual("135".prescribedWeightValue, 135)
        XCTAssertEqual("135 lbs".prescribedWeightValue, 135)
        XCTAssertEqual("135lb".prescribedWeightValue, 135)
        XCTAssertEqual("100 kg".prescribedWeightValue, 100)
        XCTAssertEqual("  102.5 lbs  ".prescribedWeightValue, 102.5)
    }

    /// The field legitimately holds coaching language. Inventing 75 lbs out of "75% of max" is
    /// worse than printing no load at all — it is a number the client would actually load.
    func testCoachingLanguageContributesNoWeightRatherThanAnInventedOne() {
        XCTAssertNil("75% of max".prescribedWeightValue)
        XCTAssertNil("moderate".prescribedWeightValue)
        XCTAssertNil("heavy".prescribedWeightValue)
        XCTAssertNil("bodyweight".prescribedWeightValue)
        XCTAssertNil("".prescribedWeightValue)
    }

    /// In "bodyweight + 25" the added half is the number the client puts on the belt.
    func testTheAddedHalfOfABodyweightPlusPrescriptionIsTheNumber() {
        XCTAssertEqual("bodyweight + 25".prescribedWeightValue, 25)
        XCTAssertEqual("bodyweight+25".prescribedWeightValue, 25)
        XCTAssertEqual("BW + 10.5".prescribedWeightValue, 10.5)
    }
}
