import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var ticketStore: TicketStore

    var body: some View {
        NavigationStack {
            Group {
                if ticketStore.tickets.isEmpty {
                    ContentUnavailableView(
                        "No tickets yet",
                        systemImage: "ticket",
                        description: Text("Log a movie to print your first ticket.")
                    )
                } else {
                    List(ticketStore.tickets) { ticket in
                        NavigationLink(value: ticket) {
                            VStack(alignment: .leading) {
                                Text(ticket.title).font(.headline)
                                Text(ticket.oneLineReview)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .navigationDestination(for: Ticket.self) { ticket in
                        TicketView(ticket: ticket)
                    }
                }
            }
            .navigationTitle("Nickelog")
        }
    }
}

#Preview {
    CollectionView()
        .environmentObject(TicketStore())
}
