import Foundation

/// In-memory ticket collection for early development.
///
/// Placeholder for Supabase-backed persistence (VISION.md §7.2, §7.6) — swap this
/// out once auth + cloud sync are wired up. Keeping it as an `ObservableObject`
/// now means the UI layer won't need to change when that happens.
@MainActor
final class TicketStore: ObservableObject {
    @Published private(set) var tickets: [Ticket] = []

    func add(_ ticket: Ticket) {
        tickets.insert(ticket, at: 0)
    }

    func delete(_ ticket: Ticket) {
        tickets.removeAll { $0.id == ticket.id }
    }
}
