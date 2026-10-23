import Foundation

enum TicketSearch {
    /// A ticket matches when the text appears in its title, place, or one-line review,
    /// ignoring case and accents. Dates and release years are deliberately not searched
    /// (a title that contains "2001" still matches "2001"). An empty query matches everything.
    static func matches(_ ticket: Ticket, query: String) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return true }

        let searchable = [ticket.title, ticket.location, ticket.oneLineReview].compactMap { $0 }
        return searchable.contains { text in
            text.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    static func results(in tickets: [Ticket], query: String) -> [Ticket] {
        tickets.filter { matches($0, query: query) }
    }
}
