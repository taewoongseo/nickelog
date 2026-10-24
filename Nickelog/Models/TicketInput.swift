import Foundation

/// Input rules for the fields users type when logging a movie.
enum TicketInput {
    static let locationCharacterLimit = 25
    static let reviewCharacterLimit = 80

    /// Counters turn red from these counts up, so the user sees the limit coming.
    static let locationWarningCount = 23
    static let reviewWarningCount = 72

    /// Applied on every keystroke or paste: newlines become spaces and the text is
    /// cut at the character limit. Spaces are kept so people can type multi-word names.
    static func clampedLocation(_ raw: String) -> String {
        singleLine(raw, limit: locationCharacterLimit)
    }

    /// Same rules for the one-line review: newlines become spaces, cut at its limit.
    static func clampedReview(_ raw: String) -> String {
        singleLine(raw, limit: reviewCharacterLimit)
    }

    /// Whether the review has something written in it: empty or spaces-only doesn't count.
    static func isReviewWritten(_ review: String) -> Bool {
        !review.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether a counter at `count` should show its warning color.
    static func isNearLimit(count: Int, warningCount: Int) -> Bool {
        count >= warningCount
    }

    /// Counts and cuts by whole characters (what a person sees as one letter), so a
    /// Korean syllable or an accented letter is never split. Text that already fits
    /// is returned untouched, so a character still being composed is left alone.
    private static func singleLine(_ raw: String, limit: Int) -> String {
        guard raw.count > limit || raw.unicodeScalars.contains(where: { CharacterSet.newlines.contains($0) }) else {
            return raw
        }
        let singleLine = raw.unicodeScalars
            .map { CharacterSet.newlines.contains($0) ? " " : String($0) }
            .joined()
        return String(singleLine.prefix(limit))
    }

    /// Applied when the ticket is saved: the review without surrounding spaces or newlines.
    static func savedReview(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Applied when the ticket is saved: trims surrounding whitespace, and returns
    /// `nil` when nothing is left, so a blank location stays blank.
    static func savedLocation(_ raw: String) -> String? {
        let trimmed = clampedLocation(raw).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension Movie {
    /// Four-digit release year from TMDB's `YYYY-MM-DD` date, or `nil` when the
    /// date is missing or empty.
    var releaseYear: Int? {
        guard let releaseDate, releaseDate.count >= 4 else { return nil }
        return Int(releaseDate.prefix(4))
    }
}
