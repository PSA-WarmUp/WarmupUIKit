import XCTest
import SwiftUI
@testable import WarmupUIKit

/// Light mode has to be as readable as dark mode.
///
/// Reported as "the feed card in light mode doesn't look as good as dark — contrast is better
/// in dark". That turned out to be measurable rather than a matter of taste: on the card
/// surface each theme actually uses, tertiary text was 2.21:1 in light against 2.53:1 in dark,
/// where 3:1 is the floor for text anyone is expected to read. Most of what fills a feed card
/// is secondary and tertiary type, so light looked flatter for a concrete reason.
///
/// These assert the ratios rather than the hex values, so the palette can be retuned freely and
/// only an actual regression in readability fails.
final class ThemeContrastTests: XCTestCase {

    // The surfaces these colours are actually drawn on.
    private let lightPage = "#F5F5F7", lightCard = "#FFFFFF"
    private let darkPage  = "#0B0B0D", darkCard  = "#1A1A1E"

    private func luminance(_ hex: String) -> Double {
        let h = hex.replacingOccurrences(of: "#", with: "")
        let channels = stride(from: 0, to: 6, by: 2).map { i -> Double in
            let start = h.index(h.startIndex, offsetBy: i)
            let end = h.index(start, offsetBy: 2)
            return Double(UInt8(h[start..<end], radix: 16) ?? 0) / 255.0
        }
        let linear = channels.map { $0 <= 0.03928 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
        return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
    }

    private func contrast(_ a: String, _ b: String) -> Double {
        let (x, y) = (luminance(a), luminance(b))
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }

    /// The palette as declared in DesignSystem. Kept as literals on purpose: resolving a
    /// dynamic SwiftUI colour per-appearance in a unit test is unreliable, and the point is to
    /// notice when somebody edits these values.
    private let lightText = "#1C1C1E", lightTextSec = "#6B6B70", lightTextTer = "#87878C"
    private let darkText  = "#F5F5F7", darkTextSec  = "#8E8E93", darkTextTer  = "#74747A"

    func testBodyTextMeetsAAOnItsOwnCard() {
        XCTAssertGreaterThanOrEqual(contrast(lightText, lightCard), 4.5)
        XCTAssertGreaterThanOrEqual(contrast(darkText, darkCard), 4.5)
    }

    func testSecondaryTextMeetsAAOnItsOwnCard() {
        // This is the workhorse of a feed card — it appears more than any other colour.
        XCTAssertGreaterThanOrEqual(contrast(lightTextSec, lightCard), 4.5)
        XCTAssertGreaterThanOrEqual(contrast(darkTextSec, darkCard), 4.5)
    }

    func testTertiaryTextIsAboveTheReadabilityFloor() {
        // Eyebrows, counts, "23 YOURS · 23 AVAILABLE". Not body text, but still meant to be read.
        XCTAssertGreaterThanOrEqual(contrast(lightTextTer, lightCard), 3.0,
            "light tertiary text is below the 3:1 floor — this is what made the feed card look flat")
        XCTAssertGreaterThanOrEqual(contrast(darkTextTer, darkCard), 3.0)
    }

    func testNeitherThemeIsMeaningfullyWorseThanTheOther() {
        // The actual complaint. Any one level being much weaker in one theme is the defect,
        // regardless of whether it clears an absolute threshold.
        let pairs = [("body", lightText, lightCard, darkText, darkCard),
                     ("secondary", lightTextSec, lightCard, darkTextSec, darkCard),
                     ("tertiary", lightTextTer, lightCard, darkTextTer, darkCard)]
        for (name, lf, lb, df, db) in pairs {
            let light = contrast(lf, lb), dark = contrast(df, db)
            XCTAssertLessThan(abs(light - dark), 1.5,
                "\(name): light \(String(format: "%.2f", light)):1 vs dark \(String(format: "%.2f", dark)):1 — one theme is materially harder to read")
        }
    }

    func testTheTextHierarchyStillReads() {
        // Fixing contrast by flattening everything to the same darkness would trade one
        // problem for another: the card needs primary, secondary and tertiary to look distinct.
        XCTAssertGreaterThan(contrast(lightText, lightCard), contrast(lightTextSec, lightCard))
        XCTAssertGreaterThan(contrast(lightTextSec, lightCard), contrast(lightTextTer, lightCard))
        XCTAssertGreaterThan(contrast(darkText, darkCard), contrast(darkTextSec, darkCard))
        XCTAssertGreaterThan(contrast(darkTextSec, darkCard), contrast(darkTextTer, darkCard))
    }

    func testAWhiteCardIsNotInvisibleOnTheLightPage() {
        // A white card on #F5F5F7 is 1.09:1, so the hairline is the only thing drawing the
        // edge. This records why light mode needs one where dark mode does not.
        XCTAssertLessThan(contrast(lightCard, lightPage), 1.2,
            "if the card ever separates on its own, the hairline requirement can be revisited")
        XCTAssertLessThan(contrast(darkCard, darkPage), 1.2)
    }
}
