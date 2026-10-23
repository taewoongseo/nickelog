import XCTest
@testable import Nickelog

final class TicketBookTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)) ?? Date()
    }

    private func ticket(
        _ title: String,
        watched: Date,
        place: String? = nil,
        review: String = "",
        releaseYear: Int? = nil
    ) -> Ticket {
        Ticket(tmdbMovieID: title.hashValue, title: title, releaseYear: releaseYear, posterURL: nil, dateWatched: watched, location: place, oneLineReview: review)
    }

    // MARK: Month header text

    func testHeaderShowsPositionForTheMonthWithTheOpenTicket() {
        let tickets = [ticket("A", watched: date(2026, 10, 5)), ticket("B", watched: date(2026, 10, 3)), ticket("C", watched: date(2026, 10, 1))]
        let month = TicketGrouping.months(from: tickets, calendar: calendar)[0]
        XCTAssertEqual(TicketBookView.headerText(for: month, selectedIndex: 1), "2 of 3")
    }

    func testHeaderShowsCountForOtherMonths() {
        let two = TicketGrouping.months(from: [ticket("A", watched: date(2026, 9, 5)), ticket("B", watched: date(2026, 9, 3))], calendar: calendar)[0]
        let one = TicketGrouping.months(from: [ticket("C", watched: date(2026, 8, 5))], calendar: calendar)[0]
        XCTAssertEqual(TicketBookView.headerText(for: two, selectedIndex: nil), "2 tickets")
        XCTAssertEqual(TicketBookView.headerText(for: one, selectedIndex: nil), "1 ticket")
    }

    // MARK: Grouping and order

    func testTicketsAreOrderedByDateWatchedNewestFirst() {
        let old = ticket("Old", watched: date(2026, 8, 1))
        let new = ticket("New", watched: date(2026, 10, 5))
        let mid = ticket("Mid", watched: date(2026, 9, 12))

        let ordered = TicketGrouping.ordered([old, new, mid], calendar: calendar)

        XCTAssertEqual(ordered.map(\.title), ["New", "Mid", "Old"])
    }

    func testLoggingOrderBreaksTiesOnTheSameDay() {
        // The store lists tickets most-recently-logged first, so earlier in the array wins a tie.
        let loggedLast = ticket("Logged last", watched: date(2026, 10, 5, hour: 9))
        let loggedFirst = ticket("Logged first", watched: date(2026, 10, 5, hour: 21))

        let ordered = TicketGrouping.ordered([loggedLast, loggedFirst], calendar: calendar)

        XCTAssertEqual(ordered.map(\.title), ["Logged last", "Logged first"])
    }

    func testBackdatedTicketLandsInItsOwnMonth() {
        let thisMonth = ticket("Recent", watched: date(2026, 10, 5))
        let backdated = ticket("Backdated", watched: date(2026, 8, 20))

        let months = TicketGrouping.months(from: [thisMonth, backdated], calendar: calendar)

        XCTAssertEqual(months.map(\.id), ["2026-10", "2026-08"])
        XCTAssertEqual(months.last?.tickets.map(\.title), ["Backdated"])
    }

    func testMonthsGroupAndKeepNewestFirstInsideEachMonth() {
        let tickets = [
            ticket("A", watched: date(2026, 10, 2)),
            ticket("B", watched: date(2026, 9, 30)),
            ticket("C", watched: date(2026, 10, 9)),
            ticket("D", watched: date(2026, 9, 1)),
        ]

        let months = TicketGrouping.months(from: tickets, calendar: calendar)

        XCTAssertEqual(months.map(\.id), ["2026-10", "2026-09"])
        XCTAssertEqual(months[0].tickets.map(\.title), ["C", "A"])
        XCTAssertEqual(months[1].tickets.map(\.title), ["B", "D"])
    }

    func testNoTicketsMeansNoMonths() {
        XCTAssertTrue(TicketGrouping.months(from: [], calendar: calendar).isEmpty)
    }

    // MARK: Search

    func testSearchMatchesTitlePlaceAndReview() {
        let jaws = ticket("Jaws", watched: date(2026, 10, 1), place: "Metrograph", review: "Bigger boat, please.")

        XCTAssertTrue(TicketSearch.matches(jaws, query: "jaw"))
        XCTAssertTrue(TicketSearch.matches(jaws, query: "metro"))
        XCTAssertTrue(TicketSearch.matches(jaws, query: "boat"))
        XCTAssertFalse(TicketSearch.matches(jaws, query: "popcorn"))
    }

    func testSearchIgnoresCaseAndAccents() {
        let amelie = ticket("Amélie", watched: date(2026, 10, 1))

        XCTAssertTrue(TicketSearch.matches(amelie, query: "AMELIE"))
        XCTAssertTrue(TicketSearch.matches(amelie, query: "amélie"))
    }

    func testTitleContainingTheYearMatchesButReleaseYearAloneDoesNot() {
        let odyssey = ticket("2001: A Space Odyssey", watched: date(2026, 10, 1), releaseYear: 1968)
        let memento = ticket("Memento", watched: date(2026, 10, 1), releaseYear: 2001)

        XCTAssertTrue(TicketSearch.matches(odyssey, query: "2001"))
        XCTAssertFalse(TicketSearch.matches(memento, query: "2001"))
    }

    func testSearchDoesNotMatchTheDateWatched() {
        let jaws = ticket("Jaws", watched: date(2026, 10, 1))

        XCTAssertFalse(TicketSearch.matches(jaws, query: "2026"))
        XCTAssertFalse(TicketSearch.matches(jaws, query: "Oct"))
    }

    func testEmptyOrBlankQueryMatchesEverything() {
        let tickets = [ticket("A", watched: date(2026, 10, 1)), ticket("B", watched: date(2026, 10, 2))]

        XCTAssertEqual(TicketSearch.results(in: tickets, query: "").count, 2)
        XCTAssertEqual(TicketSearch.results(in: tickets, query: "   ").count, 2)
    }

    func testBlankLocationIsSimplySkipped() {
        let noPlace = ticket("Jaws", watched: date(2026, 10, 1), place: nil)

        XCTAssertFalse(TicketSearch.matches(noPlace, query: "metrograph"))
    }
}
