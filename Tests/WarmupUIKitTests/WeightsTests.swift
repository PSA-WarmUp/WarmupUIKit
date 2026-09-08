import XCTest
@testable import WarmupUIKit

/// Pounds and kilos, decided once for both apps. Nothing is converted on the way in — a weight is
/// stored in the unit it was entered in, forever — so every conversion here is a display decision.
final class WeightsTests: XCTestCase {

    // MARK: - isMetric

    /// The stored unit is free-ish text from several vintages of the API. Reading "KG" or "kgs" as
    /// pounds would double a client's numbers on screen.
    func testAnyReasonableSpellingOfKilogramsIsRecognised() {
        XCTAssertTrue(Weights.isMetric("kg"))
        XCTAssertTrue(Weights.isMetric("KG"))
        XCTAssertTrue(Weights.isMetric("kgs"))
        XCTAssertTrue(Weights.isMetric("  kg  "))
    }

    func testAnythingThatIsNotKilogramsIsPounds() {
        XCTAssertFalse(Weights.isMetric("lbs"))
        XCTAssertFalse(Weights.isMetric("lb"))
        XCTAssertFalse(Weights.isMetric(""))
        XCTAssertFalse(Weights.isMetric(nil))
    }

    // MARK: - convert

    /// A coach reading in kilos sees the client's 225 lb as 102 — landing on whole kilos, because
    /// no gym has a 102.058 kg and three decimals is how a converted number announces itself.
    func testAPoundLiftReadsAsWholeKilosForAMetricCoach() {
        XCTAssertEqual(Weights.convert(225, storedUnit: "lbs", to: .metric), 102)
        XCTAssertEqual(Weights.convert(45, storedUnit: "lbs", to: .metric), 20)
    }

    /// Back the other way, weights land on the 2.5 lb increment plates come in.
    func testAKiloLiftReadsAsPlateSizedPoundsForAnImperialReader() {
        XCTAssertEqual(Weights.convert(102, storedUnit: "kg", to: .imperial), 225)
        XCTAssertEqual(Weights.convert(20, storedUnit: "kg", to: .imperial), 45)
    }

    /// A weight already in the reader's unit must come back untouched — round-tripping it through
    /// the conversion is how a 225 becomes a 224.9 nobody lifted.
    func testAWeightAlreadyInTheRightUnitIsNotDisturbed() {
        XCTAssertEqual(Weights.convert(225, storedUnit: "lbs", to: .imperial), 225)
        XCTAssertEqual(Weights.convert(102, storedUnit: "kg", to: .metric), 102)
    }

    /// No preference stored yet means "show me what was recorded", not "convert to pounds".
    func testWithNoUnitPreferenceTheStoredNumberIsLeftAlone() {
        XCTAssertEqual(Weights.convert(102.5, storedUnit: "kg", to: nil), 102.5)
        XCTAssertEqual(Weights.convert(225, storedUnit: nil, to: nil), 225)
        XCTAssertNil(Weights.convert(nil, storedUnit: "lbs", to: .metric))
    }

    /// The unit a number was recorded in is a fact about that number, but a *missing* unit has to
    /// be read as something — pounds, matching the rest of the app.
    func testAWeightWithNoRecordedUnitIsTreatedAsPounds() {
        XCTAssertEqual(Weights.convert(225, storedUnit: nil, to: .metric), 102)
    }

    // MARK: - round

    func testDisplayedWeightsLandOnIncrementsPlatesActuallyComeIn() {
        XCTAssertEqual(Weights.round(224.9, .imperial), 225)
        XCTAssertEqual(Weights.round(101.2, .imperial), 100)
        XCTAssertEqual(Weights.round(102.058, .metric), 102)
        XCTAssertEqual(Weights.round(101.6, .metric), 102)
    }

    // MARK: - convertBodyweight

    /// Nobody weighs themselves to the nearest 2.5 lb. A bodyweight rounded onto plate increments
    /// reads as a scale that cannot count.
    func testABodyweightIsWholeUnitsInBothDirections() {
        XCTAssertEqual(Weights.convertBodyweight(180, storedUnit: "lbs", to: .metric), 82)
        XCTAssertEqual(Weights.convertBodyweight(82, storedUnit: "kg", to: .imperial), 181)
        XCTAssertEqual(Weights.convertBodyweight(180.4, storedUnit: "lbs", to: .imperial), 180)
        XCTAssertEqual(Weights.convertBodyweight(180, storedUnit: "lbs", to: nil), 180)
        XCTAssertNil(Weights.convertBodyweight(nil, storedUnit: "lbs", to: .metric))
    }

    // MARK: - display

    func testADisplayedWeightCarriesTheUnitItIsBeingShownIn() {
        XCTAssertEqual(Weights.display(225, storedUnit: "lbs", to: .imperial), "225 lbs")
        XCTAssertEqual(Weights.display(225, storedUnit: "lbs", to: .metric), "102 kg")
        XCTAssertEqual(Weights.display(102, storedUnit: "kg", to: .imperial), "225 lbs")
    }

    /// With no preference the recorded unit is the honest label — relabelling kilos as "lbs" is
    /// the worst possible failure here.
    func testWithNoPreferenceTheWeightKeepsItsRecordedLabel() {
        XCTAssertEqual(Weights.display(102.5, storedUnit: "kg", to: nil), "102.5 kg")
        XCTAssertEqual(Weights.display(225, storedUnit: nil, to: nil), "225 lbs")
    }

    /// An unlogged or zero weight is not a weight; the caller shows nothing rather than "0 lbs".
    func testNothingLoggedShowsNothingRatherThanZero() {
        XCTAssertNil(Weights.display(nil, storedUnit: "lbs", to: .imperial))
        XCTAssertNil(Weights.display(0, storedUnit: "lbs", to: .imperial))
    }

    // MARK: - WeightUnit

    func testAUnitKnowsItsOwnLabels() {
        XCTAssertEqual(WeightUnit.imperial.suffix, "lbs")
        XCTAssertEqual(WeightUnit.metric.suffix, "kg")
        XCTAssertEqual(WeightUnit.imperial.title, "Pounds")
        XCTAssertEqual(WeightUnit.metric.title, "Kilograms")
        XCTAssertEqual(WeightUnit.imperial.subtitle, "lb")
        XCTAssertEqual(WeightUnit.metric.subtitle, "kg")
    }

    /// The raw values are the server's; renaming one silently drops everyone's stored preference
    /// back to the device default.
    func testTheStoredUnitPreferenceKeepsItsWireSpelling() {
        XCTAssertEqual(WeightUnit.imperial.rawValue, "IMPERIAL")
        XCTAssertEqual(WeightUnit.metric.rawValue, "METRIC")
        XCTAssertEqual(WeightUnit(rawValue: "METRIC"), .metric)
        XCTAssertNil(WeightUnit(rawValue: "kg"))
    }
}
