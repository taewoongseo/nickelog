import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var ticketStore: TicketStore
    @State private var query = ""
    @State private var results: [Movie] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var path = NavigationPath()
    @FocusState private var isSearchFocused: Bool

    private let tmdbService = TMDBService()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 14) {
                    ScreenHeader(title: "Log a Movie", caption: "What did you see?")
                    AppSearchField(text: $query, placeholder: "Search films", isFocused: $isSearchFocused)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)

                resultsList
                    .overlay { statusMessage }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppColor.ground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                LogFormView(movie: movie, onFinish: { path = NavigationPath() })
            }
            .onChange(of: query) { _, newValue in
                search(for: newValue)
            }
            // Otherwise the field takes focus (and the keyboard) back when you return.
            .onChange(of: path.count) { _, count in
                if count > 0 { isSearchFocused = false }
            }
        }
    }

    private var resultsList: some View {
        List(results) { movie in
            NavigationLink(value: movie) {
                HStack {
                    Text(movie.title)
                        .appStyle(.bodyStrong)
                        .foregroundStyle(AppColor.ink)
                    Spacer()
                    if let year = movie.releaseDate?.prefix(4) {
                        Text(year)
                            .appStyle(.secondary)
                            .foregroundStyle(AppColor.ink2)
                    }
                }
                .padding(.vertical, 6)
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(AppColor.divider)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let errorMessage {
            message(errorMessage)
        } else if results.isEmpty && !query.isEmpty && !isSearching {
            message("No results for \u{201C}\(query)\u{201D}.")
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .appStyle(.secondary)
            .foregroundStyle(AppColor.ink2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
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
