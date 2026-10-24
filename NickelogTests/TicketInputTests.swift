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

    // MARK: Review rules

    func testClampedReviewCutsAtEightyAndTurnsNewlinesIntoSpaces() {
        XCTAssertEqual(TicketInput.clampedReview(String(repeating: "a", count: 120)).count, 80)
        XCTAssertEqual(TicketInput.clampedReview("Great\nfilm"), "Great film")
    }

    func testTextThatAlreadyFitsIsReturnedUntouched() {
        let text = "Fits fine."
        XCTAssertEqual(TicketInput.clampedReview(text), text)
        XCTAssertEqual(TicketInput.clampedLocation("Metrograph"), "Metrograph")
    }

    func testReviewIsNotWrittenWhenEmptyOrOnlySpaces() {
        XCTAssertFalse(TicketInput.isReviewWritten(""))
        XCTAssertFalse(TicketInput.isReviewWritten("   "))
        XCTAssertFalse(TicketInput.isReviewWritten(" \n "))
        XCTAssertTrue(TicketInput.isReviewWritten("Loved it"))
        XCTAssertTrue(TicketInput.isReviewWritten("  좋았다  "))
    }

    func testSavedReviewTrimsSurroundingWhitespace() {
        XCTAssertEqual(TicketInput.savedReview("  Loved it \n"), "Loved it")
        XCTAssertEqual(TicketInput.savedReview("좋았다"), "좋았다")
    }

    // MARK: Counter warning

    func testLocationCounterWarnsFrom23() {
        XCTAssertFalse(TicketInput.isNearLimit(count: 22, warningCount: TicketInput.locationWarningCount))
        XCTAssertTrue(TicketInput.isNearLimit(count: 23, warningCount: TicketInput.locationWarningCount))
        XCTAssertTrue(TicketInput.isNearLimit(count: 25, warningCount: TicketInput.locationWarningCount))
    }

    func testReviewCounterWarnsFrom72() {
        XCTAssertFalse(TicketInput.isNearLimit(count: 71, warningCount: TicketInput.reviewWarningCount))
        XCTAssertTrue(TicketInput.isNearLimit(count: 72, warningCount: TicketInput.reviewWarningCount))
        XCTAssertTrue(TicketInput.isNearLimit(count: 80, warningCount: TicketInput.reviewWarningCount))
    }

    // MARK: Korean text

    func testKoreanReviewIsCountedAndCutByWholeCharacters() {
        let long = String(repeating: "좋", count: 100)
        let clamped = TicketInput.clampedReview(long)
        XCTAssertEqual(clamped.count, 80)
        XCTAssertEqual(clamped, String(repeating: "좋", count: 80))
    }

    func testKoreanLocationUnderTheLimitIsUntouched() {
        XCTAssertEqual(TicketInput.clampedLocation("서울 CGV 용산"), "서울 CGV 용산")
    }

    func testDecomposedHangulCountsAsOneCharacterPerSyllable() {
        // 한 written as three separate jamo (how a keyboard builds it) is still one character.
        let decomposed = "\u{1112}\u{1161}\u{11AB}"
        XCTAssertEqual(decomposed.count, 1)
        XCTAssertEqual(TicketInput.clampedLocation(decomposed), decomposed)
    }
}
