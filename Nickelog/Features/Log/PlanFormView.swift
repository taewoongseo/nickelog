import SwiftUI

/// The planning version of the admission slip, for a film the user is going to watch.
/// The date and place are optional and the review stays locked until the film is
/// watched. Continues to the design picker; the ticket is saved to Coming Soon once a
/// design is chosen.
struct PlanFormView: View {
    enum Mode {
        /// Saving a film to watch later. `onFinish` is called when the user taps "Done" on
        /// the saved ticket; the caller pops the whole flow.
        case new(movie: Movie, onFinish: () -> Void)
        /// Changing a planned ticket's date, place or design. `onSaved` is called once saved.
        case edit(ticket: Ticket, onSaved: () -> Void)
    }

    let mode: Mode

    @EnvironmentObject private var ticketStore: TicketStore

    @State private var scheduledDate: Date?
    @State private var location: String
    @State private var draftTicket: Ticket?
    @State private var navigateToPicker = false
    @State private var navigateToTicket = false
    @State private var savedTicket: Ticket?
    @FocusState private var isLocationFocused: Bool

    init(movie: Movie, onFinish: @escaping () -> Void) {
        mode = .new(movie: movie, onFinish: onFinish)
        _scheduledDate = State(initialValue: nil)
        _location = State(initialValue: "")
    }

    init(editing ticket: Ticket, onSaved: @escaping () -> Void) {
        mode = .edit(ticket: ticket, onSaved: onSaved)
        _scheduledDate = State(initialValue: ticket.scheduledDate)
        _location = State(initialValue: ticket.location ?? "")
    }

    private var title: String {
        switch mode {
        case .new(let movie, _): movie.title
        case .edit(let ticket, _): ticket.title
        }
    }

    private var releaseYear: Int? {
        switch mode {
        case .new(let movie, _): movie.releaseYear
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
        .appBackButton(isEditing ? "Ticket" : "Add a Film")
        .hidesTabBar()
        .navigationDestination(isPresented: $navigateToPicker) {
            if let draftTicket {
                TicketDesignPickerView(draft: draftTicket, isEditing: isEditing, isPlanning: !isEditing, onPick: savePlanned)
            }
        }
        .navigationDestination(isPresented: $navigateToTicket) {
            if let savedTicket, case .new(_, let onFinish) = mode {
                TicketView(ticket: savedTicket, onDone: onFinish)
            }
        }
    }

    private var header: some View {
        FormFilmHeader(label: isEditing ? "Editing" : "Saving a seat", title: title, year: releaseYear)
    }

    private var form: some View {
        ScrollView {
            // A planned ticket has no number yet, so the slip's number spot stays blank.
            AdmissionSlip(serial: "") {
                SlipField(label: "Showing on") {
                    dateRow
                }

                SlipField(
                    label: "Playing at",
                    counter: (location.count, TicketInput.locationCharacterLimit, TicketInput.locationWarningCount),
                    isFocused: isLocationFocused
                ) {
                    TextField("", text: $location, prompt: Text("AMC Lincoln Square, Netflix, couch").foregroundStyle(AppColor.mutedSlip))
                        .appStyle(.slipEntry)
                        .foregroundStyle(AppColor.ink)
                        .focused($isLocationFocused)
                        .accessibilityLabel("Playing at, optional")
                        .onChange(of: location) { _, newValue in
                            let clamped = TicketInput.clampedLocation(newValue)
                            if clamped != newValue {
                                location = clamped
                            }
                        }
                }

                SlipField(label: "One-line review") {
                    Text("Not yet screened")
                        .appStyle(.slipReview)
                        .foregroundStyle(AppColor.mutedSlip)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                        .accessibilityLabel("One-line review, available once you've watched the film")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 22)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PinnedActionBar(title: "Pick a Design \u{2192}", isKeyboardUp: isLocationFocused) {
                isLocationFocused = false
                draftTicket = makeDraft()
                navigateToPicker = true
            }
        }
    }

    /// "TBD" until a date is chosen; then the built-in date picker with a way back to TBD.
    @ViewBuilder
    private var dateRow: some View {
        HStack(spacing: 12) {
            if let date = scheduledDate {
                DatePicker(
                    "Showing on",
                    selection: Binding(get: { date }, set: { scheduledDate = $0 }),
                    displayedComponents: .date
                )
                .labelsHidden()

                Button {
                    scheduledDate = nil
                } label: {
                    Text("TBD")
                        .appStyle(.labelSmall)
                        .foregroundStyle(AppColor.ink2)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("Clear the date")
            } else {
                Button {
                    scheduledDate = Date()
                } label: {
                    Text("TBD")
                        .appStyle(.slipEntry)
                        .foregroundStyle(AppColor.mutedSlip)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("Date to be decided")
                .accessibilityHint("Choose a date")
            }
            Spacer(minLength: 0)
        }
    }

    private func makeDraft() -> Ticket {
        switch mode {
        case .new(let movie, _):
            return Ticket(
                tmdbMovieID: movie.id,
                title: movie.title,
                releaseYear: movie.releaseYear,
                posterURL: movie.posterURL,
                dateWatched: Date(),
                location: TicketInput.savedLocation(location),
                oneLineReview: "",
                isPlanned: true,
                scheduledDate: scheduledDate
            )
        case .edit(let ticket, _):
            var edited = ticket
            edited.scheduledDate = scheduledDate
            edited.location = TicketInput.savedLocation(location)
            return edited
        }
    }

    private func savePlanned(with design: TicketDesign) {
        guard var ticket = draftTicket else { return }
        ticket.templateID = design.rawValue

        switch mode {
        case .new:
            // Guards against a double tap saving the same film twice.
            if savedTicket == nil {
                savedTicket = ticketStore.addPlanned(ticket)
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
        PlanFormView(
            movie: Movie(id: 1, title: "In the Mood for Love", posterPath: nil, releaseDate: "2000-09-29"),
            onFinish: {}
        )
        .environmentObject(TicketStore())
    }
}

#Preview("Editing") {
    NavigationStack {
        PlanFormView(editing: .previewSample, onSaved: {})
            .environmentObject(TicketStore())
    }
}
