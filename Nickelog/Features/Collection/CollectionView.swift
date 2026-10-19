import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var ticketStore: TicketStore
    @Environment(\.selectTab) private var selectTab

    private var caption: String {
        let count = ticketStore.tickets.count
        switch count {
        case 0: return "No screenings yet"
        case 1: return "1 ticket"
        default: return "\(count) tickets"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenHeader(title: "Ticket Book", caption: caption)
                    .padding(.top, 8)

                if ticketStore.tickets.isEmpty {
                    emptyState
                } else {
                    ticketList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppColor.ground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Ticket.self) { ticket in
                TicketView(ticket: ticket)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            DashedSlot {
                VStack(spacing: 10) {
                    Text("Coming attractions.")
                        .appStyle(.display)
                        .foregroundStyle(AppColor.ink)
                        .multilineTextAlignment(.center)

                    Text("Your first feature hasn't screened yet. Log a film and we'll print the stub.")
                        .appStyle(.secondary)
                        .foregroundStyle(AppColor.ink2)
                        .multilineTextAlignment(.center)

                    Button {
                        selectTab(.logMovie)
                    } label: {
                        Label("Log a Movie", systemImage: "plus")
                    }
                    .buttonStyle(.primaryPillCompact)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .frame(minHeight: 182)
            }

            BrandImprint()
        }
        .padding(.horizontal, 16)
        .padding(.top, 26)
    }

    private var ticketList: some View {
        List(ticketStore.tickets) { ticket in
            NavigationLink(value: ticket) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticket.title)
                        .appStyle(.bodyStrong)
                        .foregroundStyle(AppColor.ink)
                    Text(ticket.oneLineReview)
                        .appStyle(.secondary)
                        .foregroundStyle(AppColor.ink2)
                        .lineLimit(1)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(AppColor.surface)
            .listRowSeparatorTint(AppColor.divider)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 12)
    }
}

#Preview {
    CollectionView()
        .environmentObject(TicketStore())
}
