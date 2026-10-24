import SwiftUI

/// Details form for logging a movie, or for editing an existing ticket. Continues to
/// the design picker; a new ticket is only created (and given its serial number) once a
/// design is chosen.
struct LogFormView: View {
    enum Mode {
        /// A new ticket for a movie. `onFinish` is called when the user taps "Done" on
        /// the printed ticket; the caller pops the whole logging flow.
        case log(movie: Movie, onFinish: () -> Void)
        /// Changing an existing ticket. The movie is locked. `onSaved` is called once the
        /// edit is saved; the caller closes the edit flow.
        case edit(ticket: Ticket, onSaved: () -> Void)
    }

    let mode: Mode

    @EnvironmentObject private var ticketStore: TicketStore

    @State private var dateWatched: Date
    @State private var location: String
    @State private var oneLineReview: String
    @State private var draftTicket: Ticket?
    @State private var navigateToPicker = false
    @State private var navigateToTicket = false
    @State private var createdTicket: Ticket?

    init(movie: Movie, onFinish: @escaping () -> Void) {
        mode = .log(movie: movie, onFinish: onFinish)
        _dateWatched = State(initialValue: Date())
        _location = State(initialValue: "")
        _oneLineReview = State(initialValue: "")
    }

    init(editing ticket: Ticket, onSaved: @escaping () -> Void) {
        mode = .edit(ticket: ticket, onSaved: onSaved)
        _dateWatched = State(initialValue: ticket.dateWatched)
        _location = State(initialValue: ticket.location ?? "")
        _oneLineReview = State(initialValue: ticket.oneLineReview)
    }

    private var title: String {
        switch mode {
        case .log(let movie, _): movie.title
        case .edit(let ticket, _): ticket.title
        }
    }

    private var releaseYear: Int? {
        switch mode {
        case .log(let movie, _): movie.releaseYear
        case .edit(let ticket, _): ticket.releaseYear
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            form
        }
        .background(AppColor.ground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .appBackButton(isEditing ? "Ticket" : "Search")
        .hidesTabBar()
        .navigationDestination(isPresented: $navigateToPicker) {
            if let draftTicket {
                TicketDesignPickerView(draft: draftTicket, isEditing: isEditing, onPick: createTicket)
            }
        }
        .navigationDestination(isPresented: $navigateToTicket) {
            if let createdTicket {
                if case .log(_, let onFinish) = mode {
                    TicketView(ticket: createdTicket, onDone: onFinish)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isEditing ? "Editing" : "Now logging")
                .appStyle(.label)
                .foregroundStyle(AppColor.red)
            Text(title)
                .appStyle(.filmTitle)
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let year = releaseYear {
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
        switch mode {
        case .log(let movie, _):
            return Ticket(
                tmdbMovieID: movie.id,
                title: movie.title,
                releaseYear: movie.releaseYear,
                posterURL: movie.posterURL,
                dateWatched: dateWatched,
                location: TicketInput.savedLocation(location),
                oneLineReview: oneLineReview
            )
        case .edit(let ticket, _):
            var edited = ticket
            edited.dateWatched = dateWatched
            edited.location = TicketInput.savedLocation(location)
            edited.oneLineReview = oneLineReview
            return edited
        }
    }

    private func createTicket(with design: TicketDesign) {
        guard var ticket = draftTicket else { return }
        ticket.templateID = design.rawValue

        switch mode {
        case .log:
            // Guards against a double tap printing the same ticket twice.
            if createdTicket == nil {
                createdTicket = ticketStore.addAssigningSerial(ticket)
            }
            navigateToTicket = true
        case .edit(_, let onSaved):
            ticketStore.update(ticket)
            onSaved()
        }
    }
}

#Preview {
    NavigationStack {
        LogFormView(movie: Movie(id: 1, title: "In the Mood for Love", posterPath: nil, releaseDate: "2000-09-29"), onFinish: {})
            .environmentObject(TicketStore())
    }
}

#Preview("Editing") {
    NavigationStack {
        LogFormView(editing: .previewSample, onSaved: {})
            .environmentObject(TicketStore())
    }
}
