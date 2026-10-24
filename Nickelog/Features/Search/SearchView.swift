import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var ticketStore: TicketStore
    @State private var query = ""
    @State private var results: [Movie] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var path = NavigationPath()
    @State private var chosenMovie: Movie?
    @FocusState private var isSearchFocused: Bool

    private let tmdbService = TMDBService()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 14) {
                    ScreenHeader(title: "Add a Film", caption: "Which one?")
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
            .navigationDestination(for: PlannedFilm.self) { planned in
                PlanFormView(movie: planned.movie, onFinish: { path = NavigationPath() })
            }
            .sheet(item: $chosenMovie) { movie in
                FilmChoiceSheet(
                    movie: movie,
                    onLog: {
                        chosenMovie = nil
                        path.append(movie)
                    },
                    onPlan: {
                        chosenMovie = nil
                        path.append(PlannedFilm(movie: movie))
                    }
                )
                .presentationDetents([.height(360), .large])
                .presentationDragIndicator(.visible)
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
            Button {
                isSearchFocused = false
                chosenMovie = movie
            } label: {
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
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppColor.muted)
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
