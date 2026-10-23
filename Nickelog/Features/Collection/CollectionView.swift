import SwiftUI

struct CollectionView: View {
    /// Shows the loading placeholders instead of the book. Nothing in the app turns this
    /// on yet; it is for previews now and for cloud sync later.
    var isLoading = false

    @EnvironmentObject private var ticketStore: TicketStore
    @Environment(\.selectTab) private var selectTab
    @State private var path = NavigationPath()
    @State private var isSearching = false
    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var caption: String {
        if isLoading { return TicketBookLoadingView.headerCaption }
        let count = ticketStore.tickets.count
        switch count {
        case 0: return "No screenings yet"
        case 1: return "1 ticket"
        default: return "\(count) tickets"
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                if isSearching {
                    searchHeader
                } else {
                    ScreenHeader(title: "Ticket Book", caption: caption) {
                        if !isLoading && !ticketStore.tickets.isEmpty {
                            IconButton(systemName: "magnifyingglass", accessibilityLabel: "Search tickets") {
                                startSearching()
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                if isLoading {
                    TicketBookLoadingView()
                } else if ticketStore.tickets.isEmpty {
                    emptyState
                } else if isSearching {
                    searchResults
                } else if let only = ticketStore.tickets.first, ticketStore.tickets.count == 1 {
                    OneTicketView(
                        ticket: only,
                        nextSerialNumber: ticketStore.nextSerialNumber,
                        onOpen: { path.append($0) }
                    )
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

    private var searchHeader: some View {
        HStack(spacing: 12) {
            AppSearchField(text: $query, placeholder: "Title, place or one line", isFocused: $searchFocused)

            Button("Cancel") {
                stopSearching()
            }
            .buttonStyle(.redText)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var matches: [Ticket] {
        TicketSearch.results(in: ticketStore.tickets, query: query)
    }

    private var matchCaption: String {
        let count = matches.count
        return count == 1 ? "1 ticket matches" : "\(count) tickets match"
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(matchCaption)
                .appStyle(.label)
                .foregroundStyle(AppColor.ink2)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            // A fresh book for each query, so a ticket pinned open earlier can't be left
            // selected after it drops out of the results.
            TicketBookView(
                sections: TicketGrouping.months(from: matches),
                onOpen: {
                    searchFocused = false
                    path.append($0)
                }
            )
            .id(query)
        }
    }

    private func startSearching() {
        query = ""
        isSearching = true
        searchFocused = true
    }

    private func stopSearching() {
        searchFocused = false
        query = ""
        isSearching = false
    }

    private var ticketList: some View {
        TicketBookView(
            sections: TicketGrouping.months(from: ticketStore.tickets),
            onOpen: { path.append($0) }
        )
    }
}

#Preview {
    CollectionView()
        .environmentObject(TicketStore())
}

#Preview("Loading") {
    CollectionView(isLoading: true)
        .environmentObject(TicketStore())
}
