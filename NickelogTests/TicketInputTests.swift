import XCTest
@testable import Nickelog

final class TicketInputTests: XCTestCase {
    func testClampedLocationCutsAtLimit() {
        let long = String(repeating: "a", count: 40)
        XCTAssertEqual(TicketInput.clampedLocation(long).count, 25)
    }

    func testClampedLocationTurnsNewlinesIntoSpaces() {
        XCTAssertEqual(TicketInput.clampedLocation("AMC\nLincoln"), "AMC Lincoln")
    }

    func testSavedLocationTrimsWhitespace() {
        XCTAssertEqual(TicketInput.savedLocation("  Metrograph  "), "Metrograph")
    }

    func testSavedLocationIsNilWhenBlank() {
        XCTAssertNil(TicketInput.savedLocation(""))
        XCTAssertNil(TicketInput.savedLocation("   \n  "))
    }

    func testReleaseYearParsesFromDate() {
        let movie = Movie(id: 1, title: "Jaws", posterPath: nil, releaseDate: "1975-06-20")
        XCTAssertEqual(movie.releaseYear, 1975)
    }

    func testReleaseYearIsNilWhenDateMissingOrEmpty() {
        XCTAssertNil(Movie(id: 1, title: "A", posterPath: nil, releaseDate: nil).releaseYear)
        XCTAssertNil(Movie(id: 2, title: "B", posterPath: nil, releaseDate: "").releaseYear)
    }
}
