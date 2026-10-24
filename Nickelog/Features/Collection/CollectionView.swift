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
    @State private var tab = BookTab.screened
    @FocusState private var searchFocused: Bool

    /// The tickets on the side of the book that is showing.
    private var shownTickets: [Ticket] {
        tab == .screened ? ticketStore.loggedTickets : ticketStore.plannedTickets
    }

    /// Under the title: a loading note or "No screenings yet"; once there are tickets
    /// the Screened / Coming Soon switch takes this place.
    private var caption: String? {
        if isLoading { return TicketBookLoadingView.headerCaption }
        return ticketStore.tickets.isEmpty ? "No screenings yet" : nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                if isSearching {
                    searchHeader
                } else {
                    ScreenHeader(title: "Ticket Book", caption: caption) {
                        if !isLoading && !shownTickets.isEmpty {
                            IconButton(systemName: "magnifyingglass", accessibilityLabel: "Search tickets") {
                                startSearching()
                            }
                        }
                    }
                    .padding(.top, 8)

                    if !isLoading && !ticketStore.tickets.isEmpty {
                        BookTabSwitch(
                            selection: $tab,
                            screenedCount: ticketStore.loggedTickets.count,
                            comingSoonCount: ticketStore.plannedTickets.count
                        )
                        .padding(.top, 2)
                        .padding(.bottom, 4)
                    }
                }

                if isLoading {
                    TicketBookLoadingView()
                } else if ticketStore.tickets.isEmpty {
                    emptyState
                } else if isSearching {
                    searchResults
                } else if tab == .screened && ticketStore.loggedTickets.isEmpty {
                    emptyState
                } else if tab == .comingSoon && ticketStore.plannedTickets.isEmpty {
                    comingSoonEmptyState
                } else if tab == .screened, let only = ticketStore.loggedTickets.first, ticketStore.loggedTickets.count == 1 {
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
                        Label("Add a Film", systemImage: "plus")
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

    private var comingSoonEmptyState: some View {
        VStack(spacing: 24) {
            DashedSlot {
                VStack(spacing: 10) {
                    Text("Nothing showing soon.")
                        .appStyle(.display)
                        .foregroundStyle(AppColor.ink)
                        .multilineTextAlignment(.center)

                    Text("Found a film you plan to see? Save your seat and it will wait here.")
                        .appStyle(.secondary)
                        .foregroundStyle(AppColor.ink2)
                        .multilineTextAlignment(.center)

                    Button {
                        selectTab(.logMovie)
                    } label: {
                        Label("Plan a Screening", systemImage: "plus")
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
        TicketSearch.results(in: shownTickets, query: query)
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
                sections: sections(for: matches),
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
            sections: sections(for: shownTickets),
            onOpen: { path.append($0) }
        )
        // A fresh book when switching sides, so the open ticket starts at the top.
        .id(tab)
    }

    /// Screened tickets are grouped by the month watched, newest first; Coming Soon by the
    /// month scheduled, soonest first, with the undated ones last.
    private func sections(for tickets: [Ticket]) -> [TicketMonth] {
        tab == .screened
            ? TicketGrouping.months(from: tickets)
            : TicketGrouping.comingSoonMonths(from: tickets)
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
