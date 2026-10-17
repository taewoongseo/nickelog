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
        Form {
            Section {
                Text(movie.title)
                    .font(.headline)
            }

            Section("Details") {
                DatePicker("Date watched", selection: $dateWatched, in: ...Date(), displayedComponents: .date)
                TextField("Where did you watch it? (optional)", text: $location)
                    .onChange(of: location) { _, newValue in
                        let clamped = TicketInput.clampedLocation(newValue)
                        if clamped != newValue {
                            location = clamped
                        }
                    }
                Text("\(location.count)/\(TicketInput.locationCharacterLimit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("One-line review") {
                TextField("What did you think?", text: $oneLineReview, axis: .vertical)
                    .onChange(of: oneLineReview) { _, newValue in
                        if newValue.count > TicketInput.reviewCharacterLimit {
                            oneLineReview = String(newValue.prefix(TicketInput.reviewCharacterLimit))
                        }
                    }
                Text("\(oneLineReview.count)/\(TicketInput.reviewCharacterLimit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Pick a Design") {
                    draftTicket = makeDraft()
                    navigateToPicker = true
                }
            }
        }
        .navigationTitle("Log It")
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
