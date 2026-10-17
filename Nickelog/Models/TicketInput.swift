import Foundation

/// Input rules for the fields users type when logging a movie.
enum TicketInput {
    static let locationCharacterLimit = 25
    static let reviewCharacterLimit = 80

    /// Applied on every keystroke or paste: newlines become spaces and the text is
    /// cut at the character limit. Spaces are kept so people can type multi-word names.
    static func clampedLocation(_ raw: String) -> String {
        let singleLine = raw.unicodeScalars
            .map { CharacterSet.newlines.contains($0) ? " " : String($0) }
            .joined()
        return String(singleLine.prefix(locationCharacterLimit))
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
