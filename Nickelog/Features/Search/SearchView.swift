import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var ticketStore: TicketStore
    @State private var query = ""
    @State private var results: [Movie] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    private let tmdbService = TMDBService()

    var body: some View {
        NavigationStack {
            List(results) { movie in
                NavigationLink(value: movie) {
                    HStack {
                        Text(movie.title)
                        Spacer()
                        if let year = movie.releaseDate?.prefix(4) {
                            Text(year).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .overlay {
                if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "exclamationmark.triangle")
                } else if results.isEmpty && !query.isEmpty && !isSearching {
                    ContentUnavailableView.search
                }
            }
            .navigationTitle("Log a Movie")
            .navigationDestination(for: Movie.self) { movie in
                LogFormView(movie: movie)
            }
            .searchable(text: $query, prompt: "Search for a movie")
            .onChange(of: query) { _, newValue in
                search(for: newValue)
            }
        }
    }

    private func search(for query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        isSearching = true
        errorMessage = nil
        Task {
            do {
                results = try await tmdbService.searchMovies(query: query)
            } catch TMDBError.missingAPIKey {
                errorMessage = "Add a TMDB API key in Config/Secrets.xcconfig to enable search."
            } catch {
                errorMessage = "Couldn't reach TMDB. Try again."
            }
            isSearching = false
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(TicketStore())
}
