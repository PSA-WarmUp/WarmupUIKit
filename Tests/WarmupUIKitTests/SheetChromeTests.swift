import XCTest
@testable import WarmupUIKit

/// The one dismiss rule every sheet in both apps follows: a sheet that commits shows Cancel
/// top-left plus its commit; a sheet that only shows or edits live shows Done top-right.
/// Never an xmark, never a leading Done.
final class SheetChromeTests: XCTestCase {

    func testASheetThatOnlyShowsThingsHasDoneTopRightAndNothingLeft() {
        var tapped = false
        let controls = DSSheetControls(role: .view(onDone: { tapped = true }))
        XCTAssertNil(controls.leadingLabel)
        XCTAssertEqual(controls.trailing?.label, "Done")
        controls.trailing?.action()
        XCTAssertTrue(tapped)
    }

    func testASheetThatCommitsFromTheHeaderHasCancelLeftAndItsCommitRight() {
        var cancelled = false, saved = false
        let controls = DSSheetControls(role: .commit("Save", isDisabled: true,
                                                     onCancel: { cancelled = true },
                                                     action: { saved = true }))
        XCTAssertEqual(controls.leadingLabel, "Cancel")
        XCTAssertEqual(controls.trailing?.label, "Save")
        XCTAssertEqual(controls.trailing?.isDisabled, true)
        if case .cancel(let cancel) = controls.leading { cancel() }
        controls.trailing?.action()
        XCTAssertTrue(cancelled)
        XCTAssertTrue(saved)
    }

    func testASheetThatCommitsFromABottomButtonHasOnlyCancel() {
        let controls = DSSheetControls(role: .commitBelow(onCancel: {}))
        XCTAssertEqual(controls.leadingLabel, "Cancel")
        XCTAssertNil(controls.trailing)
    }

    // MARK: - Deprecated API keeps building and lands on the rule

    @available(*, deprecated)
    func testTheOldCloseNeverDrawsAnXmark() {
        // Alone it becomes Done on the right…
        var closed = false
        let alone = DSSheetControls(leading: .close(action: { closed = true }), trailing: .none)
        XCTAssertNil(alone.leadingLabel)
        XCTAssertEqual(alone.trailing?.label, "Done")
        alone.trailing?.action()
        XCTAssertTrue(closed)

        // …and next to a commit it becomes Cancel.
        let withSave = DSSheetControls(leading: .close(action: {}),
                                       trailing: .custom(label: "Save", action: {}))
        XCTAssertEqual(withSave.leadingLabel, "Cancel")
        XCTAssertEqual(withSave.trailing?.label, "Save")
    }

    @available(*, deprecated)
    func testTheOldSlotsOtherwiseKeepTheirMeaning() {
        let done = DSSheetControls(leading: .none, trailing: .done(action: {}))
        XCTAssertNil(done.leadingLabel)
        XCTAssertEqual(done.trailing?.label, "Done")

        let cancel = DSSheetControls(leading: .cancel(action: {}), trailing: .none)
        XCTAssertEqual(cancel.leadingLabel, "Cancel")
        XCTAssertNil(cancel.trailing)
    }
}
