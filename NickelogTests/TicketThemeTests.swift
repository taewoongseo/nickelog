import XCTest
import UIKit
@testable import Nickelog

final class TicketThemeTests: XCTestCase {
    /// A wrong font name silently falls back to the system font, so check that
    /// every font each design asks for is really bundled and registered.
    func testEveryThemeFontLoads() {
        for design in TicketDesign.allCases {
            let theme = TicketTheme.theme(for: design)
            for name in theme.fontNames {
                XCTAssertNotNil(UIFont(name: name, size: 20), "\(name) did not load for \(design.displayName)")
            }
        }
    }

    func testEveryDesignHasATheme() {
        XCTAssertEqual(TicketDesign.allCases.count, 3)
    }

    func testUnknownTemplateIDFallsBackToDefaultDesign() {
        let ticket = Ticket(tmdbMovieID: 1, title: "A", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "", templateID: "nonsense")
        XCTAssertEqual(ticket.design, .default)
    }
}
