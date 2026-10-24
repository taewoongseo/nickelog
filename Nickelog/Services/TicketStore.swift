import Foundation

/// In-memory ticket collection for early development.
///
/// Placeholder for Supabase-backed persistence (VISION.md §7.2, §7.6) — swap this
/// out once auth + cloud sync are wired up. Keeping it as an `ObservableObject`
/// now means the UI layer won't need to change when that happens.
@MainActor
final class TicketStore: ObservableObject {
    @Published private(set) var tickets: [Ticket] = []

    /// Highest serial number handed out so far. Only ever increases, so deleting
    /// a ticket never frees its number for reuse.
    private var lastSerialNumber = 0

    /// The serial the next ticket will receive, so previews can show it before saving.
    var nextSerialNumber: Int { lastSerialNumber + 1 }

    func add(_ ticket: Ticket) {
        tickets.insert(ticket, at: 0)
    }

    /// Stamps the ticket with the next serial number, then adds it.
    /// Returns the ticket as stored, including its serial.
    @discardableResult
    func addAssigningSerial(_ ticket: Ticket) -> Ticket {
        lastSerialNumber += 1
        var numbered = ticket
        numbered.serialNumber = lastSerialNumber
        add(numbered)
        return numbered
    }

    /// Saves an edit to a ticket in place. Only the editable parts are taken from
    /// `edited` (date, place, review and design); the movie, serial number, creation
    /// date and position in the collection stay as they were, and `updatedAt` is set.
    /// If nothing actually changed, the ticket is left alone (including `updatedAt`).
    /// Returns the ticket as stored, or `nil` if it no longer exists.
    @discardableResult
    func update(_ edited: Ticket) -> Ticket? {
        guard let index = tickets.firstIndex(where: { $0.id == edited.id }) else { return nil }
        var ticket = tickets[index]
        let isUnchanged = ticket.dateWatched == edited.dateWatched
            && ticket.location == edited.location
            && ticket.oneLineReview == edited.oneLineReview
            && ticket.templateID == edited.templateID
        if isUnchanged { return ticket }
        ticket.dateWatched = edited.dateWatched
        ticket.location = edited.location
        ticket.oneLineReview = edited.oneLineReview
        ticket.templateID = edited.templateID
        ticket.updatedAt = Date()
        tickets[index] = ticket
        return ticket
    }

    func delete(_ ticket: Ticket) {
        tickets.removeAll { $0.id == ticket.id }
    }
}
