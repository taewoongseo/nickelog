import XCTest

final class NickelogUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Collection"].waitForExistence(timeout: 5))
    }
}
