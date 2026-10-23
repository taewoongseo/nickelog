import SwiftUI

/// The Ticket Book when it holds exactly one ticket: a dashed "Next showing" tab sits
/// above it, previewing the serial number the next ticket will get.
struct OneTicketView: View {
    let ticket: Ticket
    let nextSerialNumber: Int
    let onOpen: (Ticket) -> Void

    private var nextSerial: String {
        "No. " + String(format: "%06d", nextSerialNumber)
    }

    var body: some View {
        VStack(spacing: 0) {
            DashedSlot(openBottom: true) {
                Text("\(nextSerial) \u{00B7} Next showing")
                    .appStyle(.serial)
                    .foregroundStyle(AppColor.mutedSlip)
                    .padding(.top, 14)
                    .frame(minHeight: 64, alignment: .top)
            }
            .accessibilityElement(children: .combine)

            Button {
                onOpen(ticket)
            } label: {
                TicketCard(ticket: ticket)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(ticket.title), \(ticket.dateWatched.formatted(date: .abbreviated, time: .omitted))")
            .accessibilityHint("Opens the ticket")

            Text("Tap a ticket to open it.")
                .appStyle(.secondary)
                .foregroundStyle(AppColor.ink2)
                .padding(.top, 16)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }
}

#Preview("One ticket") {
    OneTicketView(
        ticket: Ticket(
            tmdbMovieID: 1,
            title: "In the Mood for Love",
            releaseYear: 2000,
            posterURL: nil,
            dateWatched: .now,
            location: "Metrograph",
            oneLineReview: "Every glance lands.",
            serialNumber: 1
        ),
        nextSerialNumber: 2,
        onOpen: { _ in }
    )
    .background(AppColor.ground)
}
