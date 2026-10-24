import Foundation

/// In-memory ticket collection for early development.
///
/// Placeholder for Supabase-backed persistence (VISION.md §7.2, §7.6) — swap this
/// out once auth + cloud sync are wired up. Keeping it as an `ObservableObject`
/// now means the UI layer won't need to change when that happens.
@MainActor
final class TicketStore: ObservableObject {
    @Published private(set) var tickets: [Ticket] = [] {
        didSet { splitTickets() }
    }

    /// Tickets for films already watched, newest-logged first. Kept in step with `tickets`
    /// so screens can read them as often as they like without filtering each time.
    private(set) var loggedTickets: [Ticket] = []

    /// Tickets for films saved to watch later, most recently saved first.
    private(set) var plannedTickets: [Ticket] = []

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

    /// Saves a film to watch later. A planned ticket gets no serial number (that comes
    /// when it is logged) and no review. Returns the ticket as stored.
    @discardableResult
    func addPlanned(_ ticket: Ticket) -> Ticket {
        var planned = ticket
        planned.isPlanned = true
        planned.serialNumber = 0
        planned.oneLineReview = ""
        add(planned)
        return planned
    }

    /// Turns a planned ticket into a logged one: it takes the date, place, review and
    /// design from `logged`, gets the next serial number, and stays where it is in the
    /// store. Returns the ticket as stored, or `nil` if it isn't a planned ticket.
    @discardableResult
    func logPlanned(_ logged: Ticket) -> Ticket? {
        guard let index = tickets.firstIndex(where: { $0.id == logged.id }), tickets[index].isPlanned else {
            return nil
        }
        var ticket = tickets[index]
        ticket.isPlanned = false
        ticket.scheduledDate = nil
        ticket.dateWatched = logged.dateWatched
        ticket.location = logged.location
        ticket.oneLineReview = logged.oneLineReview
        ticket.templateID = logged.templateID
        lastSerialNumber += 1
        ticket.serialNumber = lastSerialNumber
        tickets[index] = ticket
        return ticket
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

        if ticket.isPlanned {
            // A planned ticket's review stays locked; its date is the scheduled one.
            let isUnchanged = ticket.scheduledDate == edited.scheduledDate
                && ticket.location == edited.location
                && ticket.templateID == edited.templateID
            if isUnchanged { return ticket }
            ticket.scheduledDate = edited.scheduledDate
            ticket.location = edited.location
            ticket.templateID = edited.templateID
        } else {
            let isUnchanged = ticket.dateWatched == edited.dateWatched
                && ticket.location == edited.location
                && ticket.oneLineReview == edited.oneLineReview
                && ticket.templateID == edited.templateID
            if isUnchanged { return ticket }
            ticket.dateWatched = edited.dateWatched
            ticket.location = edited.location
            ticket.oneLineReview = edited.oneLineReview
            ticket.templateID = edited.templateID
        }
        ticket.updatedAt = Date()
        tickets[index] = ticket
        return ticket
    }

    private func splitTickets() {
        loggedTickets = tickets.filter { !$0.isPlanned }
        plannedTickets = tickets.filter(\.isPlanned)
    }

    func delete(_ ticket: Ticket) {
        tickets.removeAll { $0.id == ticket.id }
    }
}
