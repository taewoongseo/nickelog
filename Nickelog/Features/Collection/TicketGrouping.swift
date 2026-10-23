import Foundation

/// A run of tickets shown under one header in the Ticket Book, newest first.
struct TicketMonth: Identifiable, Equatable {
    /// Sortable and unique, for example `2026-10`.
    let id: String
    /// Shown in the section header, for example `October 2026`.
    let title: String
    var tickets: [Ticket]
}

enum TicketGrouping {
    /// Newest date watched first. Tickets watched on the same day keep their logging
    /// order (`TicketStore` holds tickets most-recently-logged first).
    ///
    /// This is the one place that decides Ticket Book order, so other sort options
    /// can be added here later.
    static func ordered(_ tickets: [Ticket], calendar: Calendar = .current) -> [Ticket] {
        tickets.enumerated()
            .sorted { lhs, rhs in
                let leftDay = calendar.startOfDay(for: lhs.element.dateWatched)
                let rightDay = calendar.startOfDay(for: rhs.element.dateWatched)
                return leftDay != rightDay ? leftDay > rightDay : lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    /// Groups tickets into months of date watched, newest month first.
    static func months(from tickets: [Ticket], calendar: Calendar = .current) -> [TicketMonth] {
        var months: [TicketMonth] = []
        for ticket in ordered(tickets, calendar: calendar) {
            let parts = calendar.dateComponents([.year, .month], from: ticket.dateWatched)
            let id = String(format: "%04ld-%02ld", parts.year ?? 0, parts.month ?? 0)
            if months.last?.id == id {
                months[months.count - 1].tickets.append(ticket)
            } else {
                let title = ticket.dateWatched.formatted(.dateTime.month(.wide).year())
                months.append(TicketMonth(id: id, title: title, tickets: [ticket]))
            }
        }
        return months
    }
}
