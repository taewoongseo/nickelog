import Foundation

/// A logged movie: the core artifact of Nickelog, rendered as a ticket image.
/// Mirrors the `tickets` table described in VISION.md §8.5.
struct Ticket: Identifiable, Codable, Hashable {
    let id: UUID
    var tmdbMovieID: Int
    var title: String
    var releaseYear: Int?
    var posterURL: URL?
    var dateWatched: Date
    var location: String?
    var oneLineReview: String
    var rating: Int?
    var templateID: String
    /// Permanent number stamped on the ticket. `0` means "not assigned yet";
    /// `TicketStore.addAssigningSerial(_:)` assigns the real value.
    var serialNumber: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        tmdbMovieID: Int,
        title: String,
        releaseYear: Int? = nil,
        posterURL: URL?,
        dateWatched: Date,
        location: String?,
        oneLineReview: String,
        rating: Int? = nil,
        templateID: String = TicketDesign.default.rawValue,
        serialNumber: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tmdbMovieID = tmdbMovieID
        self.title = title
        self.releaseYear = releaseYear
        self.posterURL = posterURL
        self.dateWatched = dateWatched
        self.location = location
        self.oneLineReview = oneLineReview
        self.rating = rating
        self.templateID = templateID
        self.serialNumber = serialNumber
        self.createdAt = createdAt
    }

    /// The chosen design, falling back to the default if the stored id is unknown.
    var design: TicketDesign {
        TicketDesign(rawValue: templateID) ?? .default
    }

    /// Serial as printed on the ticket, zero-padded to six digits (e.g. `000047`).
    var formattedSerial: String {
        String(format: "%06d", serialNumber)
    }
}
