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

    func testSerialNumbersIncreaseFromOne() {
        let store = TicketStore()
        let first = store.addAssigningSerial(Ticket(tmdbMovieID: 1, title: "First", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))
        let second = store.addAssigningSerial(Ticket(tmdbMovieID: 2, title: "Second", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))

        XCTAssertEqual(first.serialNumber, 1)
        XCTAssertEqual(second.serialNumber, 2)
    }

    func testSerialNumberIsNotReusedAfterDelete() {
        let store = TicketStore()
        let first = store.addAssigningSerial(Ticket(tmdbMovieID: 1, title: "First", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))
        store.delete(first)
        let second = store.addAssigningSerial(Ticket(tmdbMovieID: 1, title: "First again", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))

        XCTAssertEqual(second.serialNumber, 2)
    }

    func testRewatchGetsItsOwnSerial() {
        let store = TicketStore()
        let first = store.addAssigningSerial(Ticket(tmdbMovieID: 7, title: "Jaws", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))
        let rewatch = store.addAssigningSerial(Ticket(tmdbMovieID: 7, title: "Jaws", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: ""))

        XCTAssertNotEqual(first.serialNumber, rewatch.serialNumber)
    }

    func testFormattedSerialIsZeroPaddedToSixDigits() {
        let ticket = Ticket(tmdbMovieID: 1, title: "A", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "", serialNumber: 47)
        XCTAssertEqual(ticket.formattedSerial, "000047")
    }

    func testDeleteRemovesTicket() {
        let store = TicketStore()
        let ticket = Ticket(tmdbMovieID: 1, title: "First", posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "")
        store.add(ticket)

        store.delete(ticket)

        XCTAssertTrue(store.tickets.isEmpty)
    }
}
