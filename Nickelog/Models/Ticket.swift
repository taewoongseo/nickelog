import Foundation

/// A logged movie: the core artifact of Nickelog, rendered as a ticket image.
/// Mirrors the `tickets` table described in VISION.md §7.5.
struct Ticket: Identifiable, Codable, Hashable {
    let id: UUID
    var tmdbMovieID: Int
    var title: String
    var posterURL: URL?
    var dateWatched: Date
    var location: String
    var oneLineReview: String
    var rating: Int?
    var templateID: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        tmdbMovieID: Int,
        title: String,
        posterURL: URL?,
        dateWatched: Date,
        location: String,
        oneLineReview: String,
        rating: Int? = nil,
        templateID: String = "classic",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tmdbMovieID = tmdbMovieID
        self.title = title
        self.posterURL = posterURL
        self.dateWatched = dateWatched
        self.location = location
        self.oneLineReview = oneLineReview
        self.rating = rating
        self.templateID = templateID
        self.createdAt = createdAt
    }
}
