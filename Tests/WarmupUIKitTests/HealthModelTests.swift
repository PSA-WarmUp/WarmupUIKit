import XCTest
@testable import WarmupUIKit

/// The health cards' pure logic: "your normal", who the copy is about, and which bucket an
/// exercise falls in.
final class HealthModelTests: XCTestCase {

    // MARK: - MetricBaseline

    /// Fewer readings than this and the band describes noise as a habit — so no band is drawn and
    /// no metric gets told it is unusual.
    func testABandIsNotDrawnFromTooFewReadings() {
        XCTAssertNil(MetricBaseline.from([]))
        XCTAssertNil(MetricBaseline.from(Array(repeating: 60, count: MetricBaseline.minimumSamples - 1)))
        XCTAssertNotNil(MetricBaseline.from(Array(repeating: 60, count: MetricBaseline.minimumSamples)))
    }

    /// The 10th and 90th percentiles of 1…10, interpolated. These are the edges every reading is
    /// judged against, so a shift here re-labels every metric on the screen.
    func testTheBandSitsAtTheTenthAndNinetiethPercentiles() throws {
        let baseline = try XCTUnwrap(MetricBaseline.from(Array(1...10).map(Double.init)))

        XCTAssertEqual(baseline.low, 1.9, accuracy: 0.0001)
        XCTAssertEqual(baseline.high, 9.1, accuracy: 0.0001)
        XCTAssertEqual(baseline.median, 5.5, accuracy: 0.0001)
        XCTAssertEqual(baseline.sampleCount, 10)
    }

    /// Percentiles rather than min/max on purpose: one bad night must not widen "normal" so far
    /// that nothing ever reads as unusual again.
    func testOneOutlierNightDoesNotWidenNormalToMeaninglessness() throws {
        var readings = Array(repeating: 60.0, count: 20)
        readings.append(1000)

        let baseline = try XCTUnwrap(MetricBaseline.from(readings))
        XCTAssertEqual(baseline.high, 60, accuracy: 0.0001, "the outlier sits outside the band, not on its edge")
        XCTAssertEqual(baseline.standing(of: 1000), .above)
    }

    /// Readings arrive in whatever order the health store hands them over.
    func testReadingsDoNotHaveToArriveInOrder() throws {
        let shuffled = try XCTUnwrap(MetricBaseline.from([7, 3, 10, 1, 8, 2, 9, 5, 6, 4]))
        let ordered = try XCTUnwrap(MetricBaseline.from(Array(1...10).map(Double.init)))

        XCTAssertEqual(shuffled.low, ordered.low, accuracy: 0.0001)
        XCTAssertEqual(shuffled.high, ordered.high, accuracy: 0.0001)
        XCTAssertEqual(shuffled.median, ordered.median, accuracy: 0.0001)
    }

    /// The marker is drawn on a fixed track. An unclamped position puts it outside its own card.
    func testTheMarkerNeverLeavesItsTrack() {
        let baseline = MetricBaseline(low: 50, high: 70, median: 60, sampleCount: 20)

        XCTAssertEqual(baseline.position(of: 50), 0, accuracy: 0.0001)
        XCTAssertEqual(baseline.position(of: 60), 0.5, accuracy: 0.0001)
        XCTAssertEqual(baseline.position(of: 70), 1, accuracy: 0.0001)
        XCTAssertEqual(baseline.position(of: 10), 0, accuracy: 0.0001, "far below still lands on the track")
        XCTAssertEqual(baseline.position(of: 200), 1, accuracy: 0.0001, "far above still lands on the track")
    }

    /// A person whose readings never vary has a zero-width band; dividing by it would be a NaN
    /// position and an unrenderable marker.
    func testAFlatBandPutsTheMarkerInTheMiddleRatherThanNowhere() {
        let flat = MetricBaseline(low: 60, high: 60, median: 60, sampleCount: 20)
        XCTAssertEqual(flat.position(of: 60), 0.5, accuracy: 0.0001)
        XCTAssertEqual(flat.position(of: 99), 0.5, accuracy: 0.0001)
    }

    func testAReadingIsJudgedAgainstTheEdgesOfTheBandNotItsMiddle() {
        let baseline = MetricBaseline(low: 50, high: 70, median: 60, sampleCount: 20)

        XCTAssertEqual(baseline.standing(of: 49.9), .below)
        XCTAssertEqual(baseline.standing(of: 50), .normal, "on the edge is still normal")
        XCTAssertEqual(baseline.standing(of: 60), .normal)
        XCTAssertEqual(baseline.standing(of: 70), .normal, "on the edge is still normal")
        XCTAssertEqual(baseline.standing(of: 70.1), .above)
    }

    // MARK: - MetricDirection

    /// "▲ 4" does not say whether that is good, so the card says it in words.
    func testAReadingIsDescribedInWordsAgainstThePersonsOwnNormal() {
        XCTAssertEqual(MetricDirection.higherIsBetter.phrase(for: .normal), "typical for you")
        XCTAssertEqual(MetricDirection.higherIsBetter.phrase(for: .above), "above your normal")
        XCTAssertEqual(MetricDirection.lowerIsBetter.phrase(for: .below), "below your normal")
        XCTAssertEqual(MetricDirection.neutral.phrase(for: .normal), "typical for you")
    }

    // MARK: - HealthSubject

    /// The cards were written second-person for a client reading their own data. "your body is
    /// keeping pace" is plainly wrong when the body is Finley's.
    func testACardTalksAboutTheRightPerson() {
        XCTAssertEqual(HealthSubject.you.nominative, "you")
        XCTAssertEqual(HealthSubject.you.possessive, "your")
        XCTAssertTrue(HealthSubject.you.isSelf)

        XCTAssertEqual(HealthSubject.person("Finley").nominative, "Finley")
        XCTAssertEqual(HealthSubject.person("Finley").possessive, "Finley's")
        XCTAssertFalse(HealthSubject.person("Finley").isSelf,
                       "a coach must not be prompted to connect the client's health sources")
    }

    // MARK: - MovementPattern

    /// Category wins outright — a conditioning circuit is cardio whatever its exercises are named.
    func testAConditioningSessionIsCardioWhateverItsExercisesAreCalled() {
        XCTAssertEqual(MovementPattern.classify(muscleGroups: ["Chest"], category: "CARDIO", name: "Bench Press"),
                       .cardio)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: "Conditioning", name: "Circuit"),
                       .cardio)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: "Endurance", name: "Circuit"),
                       .cardio)
    }

    /// Tagged muscles are the better signal, so they are read before the name.
    func testTaggedMusclesDecideBeforeTheExerciseName() {
        XCTAssertEqual(MovementPattern.classify(muscleGroups: ["Lats", "Biceps"], category: nil, name: "Machine"),
                       .pull)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: ["Quads"], category: nil, name: "Machine"),
                       .legs)
    }

    /// The catalogue's muscle data is incomplete. "Bench Press" is recognisable even when nothing
    /// was tagged, and losing this fallback dumps half the library into Unclassified.
    func testAnUntaggedExerciseIsStillClassifiedFromItsName() {
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Bench Press"), .push)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Overhead Press"), .push)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Barbell Row"), .pull)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Goblet Squat"), .legs)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Walking Lunge"), .legs)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Plank"), .core)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Assault Bike"), .cardio)
    }

    /// Push/pull is our rule, not a fact, and a trainer is allowed to disagree with it. Anything
    /// unrecognised is shown as unclassified rather than quietly folded into the nearest bucket.
    func testAnUnrecognisedExerciseIsShownAsUnclassifiedRatherThanGuessedAt() {
        XCTAssertEqual(MovementPattern.classify(muscleGroups: nil, category: nil, name: "Foam Rolling"), .unknown)
        XCTAssertEqual(MovementPattern.classify(muscleGroups: [], category: nil, name: "Meditation"), .unknown)
        XCTAssertEqual(MovementPattern.unknown.label, "Unclassified")
    }

    /// An empty or unhelpful muscle tag must not stop the name from being read.
    func testAnUnhelpfulMuscleTagDoesNotBlockTheNameFallback() {
        XCTAssertEqual(MovementPattern.classify(muscleGroups: ["Full Body"], category: nil, name: "Bench Press"),
                       .push)
    }

    func testEveryPatternHasAReadableLabel() {
        for pattern in MovementPattern.allCases {
            XCTAssertFalse(pattern.label.isEmpty, "\(pattern) needs a label a coach can read")
        }
    }
}
