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
                Label("Share Ticket", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.primaryPill)
            .padding(.horizontal, sideMargin)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.ground.ignoresSafeArea())
        .navigationTitle("No. \(ticket.formattedSerial)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("No. \(ticket.formattedSerial)")
                    .appStyle(.serial)
                    .foregroundStyle(AppColor.ink)
            }
        }
        .modifier(TicketNavigationModifier(onDone: onDone))
        .hidesTabBar()
    }

    private var shareText: String {
        "\(ticket.title) — \(ticket.oneLineReview)"
    }
}

/// Opened from the Ticket Book: a back button to it. Just printed: no way back,
/// only "Done".
private struct TicketNavigationModifier: ViewModifier {
    let onDone: (() -> Void)?

    func body(content: Content) -> some View {
        if let onDone {
            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    AppToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: onDone)
                            .buttonStyle(.redText)
                    }
                }
                .swipeBackDisabled()
        } else {
            content.appBackButton("Ticket Book")
        }
    }
}

#Preview {
    NavigationStack {
        TicketView(ticket: .previewSample)
    }
}
