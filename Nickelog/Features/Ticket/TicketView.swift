import SwiftUI

/// Placeholder ticket layout. Final visual design (typography, texture, template
/// variants — VISION.md §7.4) is being designed separately; this view exists so
/// the log → ticket flow is wired end-to-end while that design lands.
struct TicketView: View {
    let ticket: Ticket

    var body: some View {
        VStack(spacing: 16) {
            TicketCard(ticket: ticket)
                .padding()

            ShareLink(item: shareText) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Your Ticket")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var shareText: String {
        "\(ticket.title) — \(ticket.oneLineReview)"
    }
}

private struct TicketCard: View {
    let ticket: Ticket

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADMIT ONE")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(.secondary)

            Text(ticket.title)
                .font(.title2.bold())

            HStack {
                Text(Self.dateFormatter.string(from: ticket.dateWatched))
                Spacer()
                Text(ticket.location)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            Text("\u{201C}\(ticket.oneLineReview)\u{201D}")
                .font(.body.italic())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        )
    }
}

#Preview {
    NavigationStack {
        TicketView(
            ticket: Ticket(
                tmdbMovieID: 1,
                title: "In the Mood for Love",
                posterURL: nil,
                dateWatched: .now,
                location: "Metrograph",
                oneLineReview: "Every glance said more than the dialogue ever could."
            )
        )
    }
}
