import SwiftUI

/// Shown over the search results after a film is tapped: has the user already seen it
/// (log a ticket) or are they going to (save it to Coming Soon)?
struct FilmChoiceSheet: View {
    let movie: Movie
    let onLog: () -> Void
    let onPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Which showing is this?")
                    .appStyle(.label)
                    .foregroundStyle(AppColor.red)
                Text(movie.title)
                    .appStyle(.display)
                    .foregroundStyle(AppColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let year = movie.releaseYear {
                    Text(String(year))
                        .appStyle(.secondary)
                        .foregroundStyle(AppColor.ink2)
                }
            }

            VStack(spacing: 14) {
                choice(title: "Log My Stub", detail: "Print a ticket for a film you've seen.", isPrimary: true, action: onLog)
                choice(title: "Save My Seat", detail: "Save it for later.", isPrimary: false, action: onPlan)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.ground.ignoresSafeArea())
    }

    private func choice(title: String, detail: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Text(title)
            }
            .buttonStyle(isPrimary ? PillButtonStyle.primaryPill : PillButtonStyle.secondaryPill)

            Text(detail)
                .appStyle(.secondary)
                .foregroundStyle(AppColor.ink2)
        }
    }
}

/// Navigation value for saving a film to watch later (as opposed to logging it).
struct PlannedFilm: Hashable {
    let movie: Movie
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        FilmChoiceSheet(
            movie: Movie(id: 1, title: "In the Mood for Love", posterPath: nil, releaseDate: "2000-09-29"),
            onLog: {},
            onPlan: {}
        )
        .presentationDetents([.height(340)])
    }
}
