import XCTest

final class NickelogUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Collection"].waitForExistence(timeout: 5))
    }
}
