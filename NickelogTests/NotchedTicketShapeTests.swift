import XCTest
import SwiftUI
@testable import Nickelog

final class NotchedTicketShapeTests: XCTestCase {
    private let rect = CGRect(x: 0, y: 0, width: 1300, height: 640)
    private var path: Path { NotchedTicketShape().path(in: rect) }
    private var dx: CGFloat { TicketMetrics.dividerX }

    func testSolidInteriorIsInside() {
        XCTAssertTrue(path.contains(CGPoint(x: 650, y: 320)))
        XCTAssertTrue(path.contains(CGPoint(x: 100, y: 100)))
        XCTAssertTrue(path.contains(CGPoint(x: 1200, y: 540)))
    }

    func testCornerNotchesAreCutAway() {
        XCTAssertFalse(path.contains(CGPoint(x: 6, y: 6)))
        XCTAssertFalse(path.contains(CGPoint(x: 1294, y: 6)))
        XCTAssertFalse(path.contains(CGPoint(x: 6, y: 634)))
        XCTAssertFalse(path.contains(CGPoint(x: 1294, y: 634)))
    }

    func testPointsJustOutsideCornerNotchesAreInside() {
        XCTAssertTrue(path.contains(CGPoint(x: 60, y: 60)))
        XCTAssertTrue(path.contains(CGPoint(x: 1240, y: 60)))
        XCTAssertTrue(path.contains(CGPoint(x: 60, y: 580)))
        XCTAssertTrue(path.contains(CGPoint(x: 1240, y: 580)))
    }

    func testStubDividerNotchesAreCutAway() {
        XCTAssertFalse(path.contains(CGPoint(x: dx, y: 6)))
        XCTAssertFalse(path.contains(CGPoint(x: dx, y: 634)))
        XCTAssertTrue(path.contains(CGPoint(x: dx, y: 60)))
        XCTAssertTrue(path.contains(CGPoint(x: dx, y: 580)))
    }

    func testNotchRadiusScalesWithWidth() {
        let small = CGRect(x: 0, y: 0, width: 650, height: 320)
        let scaled = NotchedTicketShape().path(in: small)
        XCTAssertFalse(scaled.contains(CGPoint(x: 3, y: 3)))
        XCTAssertTrue(scaled.contains(CGPoint(x: 30, y: 30)))
        XCTAssertFalse(scaled.contains(CGPoint(x: dx / 2, y: 3)))
    }

    func testDividerSitsAtAboutTheDesignedPosition() {
        XCTAssertEqual(dx, 1006, accuracy: 0.5)
    }
}
