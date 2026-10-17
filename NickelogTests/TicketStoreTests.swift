import XCTest
@testable import Nickelog

@MainActor
final class TicketStoreTests: XCTestCase {
    func testAddInsertsAtFront() {
        let store = TicketStore()
        let first = Ticket(tmdbMovieID: 1, title: "First", posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "")
        let second = Ticket(tmdbMovieID: 2, title: "Second", posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "")

        store.add(first)
        store.add(second)

        XCTAssertEqual(store.tickets.map(\.title), ["Second", "First"])
    }

    func testDeleteRemovesTicket() {
        let store = TicketStore()
        let ticket = Ticket(tmdbMovieID: 1, title: "First", posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "")
        store.add(ticket)

        store.delete(ticket)

        XCTAssertTrue(store.tickets.isEmpty)
    }
}
