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

    func delete(_ ticket: Ticket) {
        tickets.removeAll { $0.id == ticket.id }
    }
}
