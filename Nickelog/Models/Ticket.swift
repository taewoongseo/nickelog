import Foundation

/// A logged movie: the core artifact of Nickelog, rendered as a ticket image.
/// Mirrors the `tickets` table described in VISION.md §8.5.
struct Ticket: Identifiable, Codable, Hashable {
    let id: UUID
    var tmdbMovieID: Int
    var title: String
    var releaseYear: Int?
    var posterURL: URL?
    /// When the film was watched. For a planned ticket this isn't used yet (it holds the
    /// date the plan was made); the real date is set when the ticket is logged.
    var dateWatched: Date
    var location: String?
    var oneLineReview: String
    var rating: Int?
    var templateID: String
    /// Permanent number stamped on the ticket. `0` means "not assigned yet";
    /// `TicketStore.addAssigningSerial(_:)` assigns the real value.
    var serialNumber: Int
    var createdAt: Date
    /// When the ticket was last edited; `nil` if it never has been.
    var updatedAt: Date?
    /// A film saved to watch later. It has no serial number, no review, and an optional
    /// `scheduledDate`, until it is logged.
    var isPlanned: Bool
    /// When a planned film is going to be watched; `nil` shows "TBD".
    var scheduledDate: Date?

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
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        isPlanned: Bool = false,
        scheduledDate: Date? = nil
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
        self.updatedAt = updatedAt
        self.isPlanned = isPlanned
        self.scheduledDate = scheduledDate
    }

    /// The chosen design, falling back to the default if the stored id is unknown.
    var design: TicketDesign {
        TicketDesign(rawValue: templateID) ?? .default
    }

    /// Serial as printed on the ticket, zero-padded to six digits (e.g. `000047`).
    /// Empty for a planned ticket, which has no number until it is logged.
    var formattedSerial: String {
        isPlanned ? "" : String(format: "%06d", serialNumber)
    }
}
