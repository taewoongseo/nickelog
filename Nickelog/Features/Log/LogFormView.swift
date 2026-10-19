import SwiftUI

/// Details form for logging a movie. Continues to the design picker; the ticket
/// is only created (and given its serial number) once a design is chosen.
struct LogFormView: View {
    let movie: Movie
    /// Called when the user taps "Done" on the printed ticket; the caller pops the whole logging flow.
    let onFinish: () -> Void

    @EnvironmentObject private var ticketStore: TicketStore

    @State private var dateWatched = Date()
    @State private var location = ""
    @State private var oneLineReview = ""
    @State private var draftTicket: Ticket?
    @State private var navigateToPicker = false
    @State private var navigateToTicket = false
    @State private var createdTicket: Ticket?

    var body: some View {
        VStack(spacing: 0) {
            header
            form
        }
        .background(AppColor.ground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .appBackButton("Search")
        .hidesTabBar()
        .navigationDestination(isPresented: $navigateToPicker) {
            if let draftTicket {
                TicketDesignPickerView(draft: draftTicket, onPick: createTicket)
            }
        }
        .navigationDestination(isPresented: $navigateToTicket) {
            if let createdTicket {
                TicketView(ticket: createdTicket, onDone: onFinish)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Now logging")
                .appStyle(.label)
                .foregroundStyle(AppColor.red)
            Text(movie.title)
                .appStyle(.filmTitle)
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let year = movie.releaseYear {
                Text(String(year))
                    .appStyle(.filmYear)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var form: some View {
        Form {
            Section {
                DatePicker("Date watched", selection: $dateWatched, in: ...Date(), displayedComponents: .date)
                    .appStyle(.body)
                    .listRowBackground(AppColor.surface)
                TextField("Where did you watch it? (optional)", text: $location)
                    .appStyle(.body)
                    .listRowBackground(AppColor.surface)
                    .onChange(of: location) { _, newValue in
                        let clamped = TicketInput.clampedLocation(newValue)
                        if clamped != newValue {
                            location = clamped
                        }
                    }
                counter(count: location.count, limit: TicketInput.locationCharacterLimit)
            } header: {
                sectionHeader("Details")
            }

            Section {
                TextField("What did you think?", text: $oneLineReview, axis: .vertical)
                    .appStyle(.body)
                    .listRowBackground(AppColor.surface)
                    .onChange(of: oneLineReview) { _, newValue in
                        if newValue.count > TicketInput.reviewCharacterLimit {
                            oneLineReview = String(newValue.prefix(TicketInput.reviewCharacterLimit))
                        }
                    }
                counter(count: oneLineReview.count, limit: TicketInput.reviewCharacterLimit)
            } header: {
                sectionHeader("One-line review")
            }

            Section {
                Button {
                    draftTicket = makeDraft()
                    navigateToPicker = true
                } label: {
                    Text("Pick a Design \u{2192}")
                }
                .buttonStyle(.primaryPill)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .appStyle(.labelSmall)
            .foregroundStyle(AppColor.ink2)
    }

    private func counter(count: Int, limit: Int) -> some View {
        Text("\(count)/\(limit)")
            .appStyle(.counter)
            .foregroundStyle(AppColor.ink2)
            .listRowBackground(AppColor.surface)
            .accessibilityLabel("\(count) of \(limit) characters")
    }

    private func makeDraft() -> Ticket {
        Ticket(
            tmdbMovieID: movie.id,
            title: movie.title,
            releaseYear: movie.releaseYear,
            posterURL: movie.posterURL,
            dateWatched: dateWatched,
            location: TicketInput.savedLocation(location),
            oneLineReview: oneLineReview
        )
    }

    private func createTicket(with design: TicketDesign) {
        // Guards against a double tap printing the same ticket twice.
        if createdTicket == nil, var ticket = draftTicket {
            ticket.templateID = design.rawValue
            createdTicket = ticketStore.addAssigningSerial(ticket)
        }
        navigateToTicket = true
    }
}

#Preview {
    NavigationStack {
        LogFormView(movie: Movie(id: 1, title: "In the Mood for Love", posterPath: nil, releaseDate: "2000-09-29"), onFinish: {})
            .environmentObject(TicketStore())
    }
}
