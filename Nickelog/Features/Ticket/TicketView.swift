import SwiftUI

/// The finished ticket, shown in portrait with side margins like a wallet pass.
/// The card itself lives in `TicketCard`; this screen only frames it and offers sharing.
struct TicketView: View {
    /// The ticket as it was when this screen opened. What is shown is always the
    /// store's current copy of it (see `ticket`), so an edit appears right away.
    let openedTicket: Ticket
    /// Set when the ticket was just printed. The back button is replaced by "Done",
    /// so the user can't step back into the picker and print the same ticket again.
    var onDone: (() -> Void)?

    @EnvironmentObject private var ticketStore: TicketStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.selectTab) private var selectTab
    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    private let sideMargin: CGFloat = 24

    init(ticket: Ticket, onDone: (() -> Void)? = nil) {
        self.openedTicket = ticket
        self.onDone = onDone
    }

    private var ticket: Ticket {
        ticketStore.tickets.first { $0.id == openedTicket.id } ?? openedTicket
    }

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

            HStack(spacing: 12) {
                Button("Edit") {
                    isEditing = true
                }
                .buttonStyle(.borderedCapsule)

                Button("Delete") {
                    isConfirmingDelete = true
                }
                .buttonStyle(.borderedCapsuleDestructive)
            }
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
        // Edit runs the logging steps again, pre-filled, then drops back to this screen,
        // which shows the saved changes because it reads the ticket from the store.
        .navigationDestination(isPresented: $isEditing) {
            LogFormView(editing: ticket, onSaved: { isEditing = false })
        }
        .confirmationDialog("Delete this ticket?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Ticket", role: .destructive, action: deleteTicket)
        } message: {
            Text("It can't be brought back, and its number won't be used again.")
        }
    }

    /// Removes the ticket and goes back to the Ticket Book: just pops when opened from it,
    /// or ends the logging flow and switches to it when the ticket was just printed.
    private func deleteTicket() {
        ticketStore.delete(ticket)
        if let onDone {
            onDone()
            selectTab(.collection)
        } else {
            dismiss()
        }
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
            .environmentObject(TicketStore())
    }
}
