import XCTest
@testable import WarmupUIKit

final class WarmupUIKitTests: XCTestCase {
    func testVersionExists() throws {
        XCTAssertFalse(WarmupUIKitVersion.isEmpty)
    }
}
