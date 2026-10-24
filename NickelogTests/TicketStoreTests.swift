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

    // MARK: Update

    private func stored(_ store: TicketStore, _ title: String) -> Ticket {
        store.addAssigningSerial(Ticket(tmdbMovieID: title.count, title: title, releaseYear: 2000, posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "Before"))
    }

    func testUpdateChangesEditableFieldsAndSetsUpdatedAt() {
        let store = TicketStore()
        let original = stored(store, "Jaws")
        var edited = original
        edited.oneLineReview = "After"
        edited.location = nil
        edited.templateID = TicketDesign.allCases[1].rawValue

        let saved = store.update(edited)

        XCTAssertEqual(saved?.oneLineReview, "After")
        XCTAssertNil(saved?.location)
        XCTAssertEqual(saved?.templateID, TicketDesign.allCases[1].rawValue)
        XCTAssertNotNil(saved?.updatedAt)
        XCTAssertEqual(store.tickets.first?.oneLineReview, "After")
    }

    func testUpdateKeepsPositionSerialMovieAndCreationDate() {
        let store = TicketStore()
        let older = stored(store, "Older")
        let newer = stored(store, "Newer")
        var edited = older
        edited.oneLineReview = "After"
        edited.title = "Tampered"
        edited.serialNumber = 99

        store.update(edited)

        XCTAssertEqual(store.tickets.map(\.id), [newer.id, older.id])
        let result = store.tickets[1]
        XCTAssertEqual(result.title, "Older")
        XCTAssertEqual(result.serialNumber, older.serialNumber)
        XCTAssertEqual(result.createdAt, older.createdAt)
    }

    func testUpdateWithNoChangesLeavesUpdatedAtEmpty() {
        let store = TicketStore()
        let original = stored(store, "Jaws")

        store.update(original)

        XCTAssertNil(store.tickets.first?.updatedAt)
    }

    func testUpdateOfMissingTicketReturnsNil() {
        let store = TicketStore()
        let ghost = Ticket(tmdbMovieID: 1, title: "Ghost", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "")

        XCTAssertNil(store.update(ghost))
        XCTAssertTrue(store.tickets.isEmpty)
    }

    // MARK: Planned tickets

    private func plannedFilm(_ title: String, scheduled: Date? = nil) -> Ticket {
        Ticket(tmdbMovieID: title.count, title: title, releaseYear: 2000, posterURL: nil, dateWatched: .now, location: "Home", oneLineReview: "", scheduledDate: scheduled)
    }

    func testPlannedTicketGetsNoSerialAndNoReview() {
        let store = TicketStore()
        var draft = plannedFilm("Jaws")
        draft.oneLineReview = "should be dropped"

        let planned = store.addPlanned(draft)

        XCTAssertTrue(planned.isPlanned)
        XCTAssertEqual(planned.serialNumber, 0)
        XCTAssertEqual(planned.oneLineReview, "")
        XCTAssertEqual(planned.formattedSerial, "")
        XCTAssertEqual(store.nextSerialNumber, 1)
    }

    func testPlannedTicketsDoNotCountAsLogged() {
        let store = TicketStore()
        store.addPlanned(plannedFilm("Jaws"))
        store.addAssigningSerial(Ticket(tmdbMovieID: 9, title: "Heat", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "Great"))

        XCTAssertEqual(store.loggedTickets.map(\.title), ["Heat"])
        XCTAssertEqual(store.plannedTickets.map(\.title), ["Jaws"])
    }

    func testLoggingAPlannedTicketGivesItTheNextSerial() {
        let store = TicketStore()
        store.addAssigningSerial(Ticket(tmdbMovieID: 9, title: "Heat", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "Great"))
        let planned = store.addPlanned(plannedFilm("Jaws"))
        var logged = planned
        logged.oneLineReview = "Bigger boat, please."

        let result = store.logPlanned(logged)

        XCTAssertEqual(result?.serialNumber, 2)
        XCTAssertEqual(result?.isPlanned, false)
        XCTAssertNil(result?.scheduledDate)
        XCTAssertEqual(result?.oneLineReview, "Bigger boat, please.")
        XCTAssertEqual(store.nextSerialNumber, 3)
        XCTAssertTrue(store.plannedTickets.isEmpty)
    }

    func testDeletingAPlannedTicketDoesNotUseUpASerial() {
        let store = TicketStore()
        let planned = store.addPlanned(plannedFilm("Jaws"))
        store.delete(planned)

        let first = store.addAssigningSerial(Ticket(tmdbMovieID: 9, title: "Heat", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "Great"))

        XCTAssertEqual(first.serialNumber, 1)
    }

    func testLoggingSomethingThatIsNotPlannedDoesNothing() {
        let store = TicketStore()
        let logged = store.addAssigningSerial(Ticket(tmdbMovieID: 9, title: "Heat", posterURL: nil, dateWatched: .now, location: nil, oneLineReview: "Great"))

        XCTAssertNil(store.logPlanned(logged))
        XCTAssertEqual(store.nextSerialNumber, 2)
    }

    func testEditingAPlannedTicketChangesDatePlaceAndDesignButNotReview() {
        let store = TicketStore()
        let planned = store.addPlanned(plannedFilm("Jaws"))
        var edited = planned
        edited.scheduledDate = Date(timeIntervalSince1970: 2_000_000_000)
        edited.location = "Metrograph"
        edited.oneLineReview = "sneaky"

        let saved = store.update(edited)

        XCTAssertEqual(saved?.scheduledDate, edited.scheduledDate)
        XCTAssertEqual(saved?.location, "Metrograph")
        XCTAssertEqual(saved?.oneLineReview, "")
        XCTAssertNotNil(saved?.updatedAt)
    }
}
