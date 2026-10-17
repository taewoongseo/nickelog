import SwiftUI

struct LogFormView: View {
    let movie: Movie

    @EnvironmentObject private var ticketStore: TicketStore
    @Environment(\.dismiss) private var dismiss

    @State private var dateWatched = Date()
    @State private var location = ""
    @State private var oneLineReview = ""
    @State private var navigateToTicket = false
    @State private var createdTicket: Ticket?

    private let reviewCharacterLimit = 80

    var body: some View {
        Form {
            Section {
                Text(movie.title)
                    .font(.headline)
            }

            Section("Details") {
                DatePicker("Date watched", selection: $dateWatched, displayedComponents: .date)
                TextField("Where did you watch it?", text: $location)
            }

            Section("One-line review") {
                TextField("What did you think?", text: $oneLineReview, axis: .vertical)
                    .onChange(of: oneLineReview) { _, newValue in
                        if newValue.count > reviewCharacterLimit {
                            oneLineReview = String(newValue.prefix(reviewCharacterLimit))
                        }
                    }
                Text("\(oneLineReview.count)/\(reviewCharacterLimit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Print My Ticket") {
                    createTicket()
                }
                .disabled(location.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Log It")
        .navigationDestination(isPresented: $navigateToTicket) {
            if let createdTicket {
                TicketView(ticket: createdTicket)
            }
        }
    }

    private func createTicket() {
        let ticket = Ticket(
            tmdbMovieID: movie.id,
            title: movie.title,
            posterURL: movie.posterURL,
            dateWatched: dateWatched,
            location: location,
            oneLineReview: oneLineReview
        )
        ticketStore.add(ticket)
        createdTicket = ticket
        navigateToTicket = true
    }
}

#Preview {
    NavigationStack {
        LogFormView(movie: Movie(id: 1, title: "In the Mood for Love", posterPath: nil, releaseDate: "2000-09-29"))
            .environmentObject(TicketStore())
    }
}
