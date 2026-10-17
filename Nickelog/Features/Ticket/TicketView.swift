import SwiftUI

/// The finished ticket, shown in portrait with side margins like a wallet pass.
/// The card itself lives in `TicketCard`; this screen only frames it and offers sharing.
struct TicketView: View {
    let ticket: Ticket
    /// Set when the ticket was just printed. The back button is replaced by "Done",
    /// so the user can't step back into the picker and print the same ticket again.
    var onDone: (() -> Void)?

    private let sideMargin: CGFloat = 24

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)

            TicketCard(ticket: ticket)
                .shadow(color: .black.opacity(0.18), radius: 20, y: 9)
                .padding(.horizontal, sideMargin)

            ShareLink(item: shareText) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)
        }
        .navigationTitle("Your Ticket")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(onDone != nil)
        .toolbar {
            if let onDone {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
    }

    private var shareText: String {
        "\(ticket.title) — \(ticket.oneLineReview)"
    }
}

#Preview {
    NavigationStack {
        TicketView(ticket: .previewSample)
    }
}
