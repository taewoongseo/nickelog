import XCTest
@testable import Nickelog

final class RiffleLayoutTests: XCTestCase {
    private let card: CGFloat = 182

    func testWithNothingOpenEveryTicketPeeksBy64() {
        let tops = RiffleLayout.tops(count: 4, selectedIndex: nil, cardHeight: card)

        XCTAssertEqual(tops, [0, 64, 128, 192])
    }

    func testTheTicketAfterTheOpenOneStarts12BelowItsBottom() {
        let tops = RiffleLayout.tops(count: 4, selectedIndex: 1, cardHeight: card)

        XCTAssertEqual(tops[0], 0)
        XCTAssertEqual(tops[1], 64)
        XCTAssertEqual(tops[2], 64 + card + 12)
        XCTAssertEqual(tops[3], 64 + card + 12 + 64)
    }

    func testOpeningTheLastTicketAddsNoGap() {
        let tops = RiffleLayout.tops(count: 3, selectedIndex: 2, cardHeight: card)

        XCTAssertEqual(tops, [0, 64, 128])
    }

    func testTheLastTicketIsAlwaysFullHeight() {
        XCTAssertEqual(RiffleLayout.totalHeight(count: 3, selectedIndex: nil, cardHeight: card), 128 + card)
        XCTAssertEqual(RiffleLayout.totalHeight(count: 1, selectedIndex: 0, cardHeight: card), card)
    }

    func testOpeningATicketMakesTheStackTaller() {
        let closed = RiffleLayout.totalHeight(count: 4, selectedIndex: nil, cardHeight: card)
        let open = RiffleLayout.totalHeight(count: 4, selectedIndex: 1, cardHeight: card)

        XCTAssertEqual(open - closed, card + 12 - 64)
    }

    func testEmptyStackHasNoHeight() {
        XCTAssertEqual(RiffleLayout.totalHeight(count: 0, selectedIndex: nil, cardHeight: card), 0)
        XCTAssertTrue(RiffleLayout.tops(count: 0, selectedIndex: nil, cardHeight: card).isEmpty)
    }
}
