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
    @FocusState private var focusedField: Field?

    private enum Field {
        case location, review
    }

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
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if let year = releaseYear {
                Text(String(year))
                    .appStyle(.filmYear)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var slipSerial: String {
        switch mode {
        case .log: String(format: "%06d", ticketStore.nextSerialNumber)
        case .edit(let ticket, _): ticket.formattedSerial
        }
    }

    private var form: some View {
        ScrollView {
            VStack(spacing: 22) {
                AdmissionSlip(serial: slipSerial) {
                    SlipField(label: "Screened") {
                        HStack {
                            DatePicker("Date watched", selection: $dateWatched, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                            Spacer(minLength: 0)
                        }
                    }

                    SlipField(
                        label: "Played at",
                        counter: (location.count, TicketInput.locationCharacterLimit, TicketInput.locationWarningCount),
                        isFocused: focusedField == .location
                    ) {
                        TextField("", text: $location, prompt: Text("AMC Lincoln Square, Netflix, couch").foregroundStyle(AppColor.mutedSlip))
                            .appStyle(.slipEntry)
                            .foregroundStyle(AppColor.ink)
                            .focused($focusedField, equals: .location)
                            .accessibilityLabel("Played at, optional")
                            .onChange(of: location) { _, newValue in
                                let clamped = TicketInput.clampedLocation(newValue)
                                if clamped != newValue {
                                    location = clamped
                                }
                            }
                    }

                    SlipField(
                        label: "One-line review",
                        counter: (oneLineReview.count, TicketInput.reviewCharacterLimit, TicketInput.reviewWarningCount),
                        isFocused: focusedField == .review
                    ) {
                        TextField("", text: $oneLineReview, prompt: Text("One line. Make it count.").foregroundStyle(AppColor.mutedSlip), axis: .vertical)
                            .appStyle(.slipReview)
                            .foregroundStyle(AppColor.ink)
                            .lineLimit(3, reservesSpace: true)
                            .focused($focusedField, equals: .review)
                            .accessibilityLabel("One-line review")
                            .onChange(of: oneLineReview) { _, newValue in
                                let clamped = TicketInput.clampedReview(newValue)
                                if clamped != newValue {
                                    oneLineReview = clamped
                                    // The Return key can't add a line here, so it means "done".
                                    if newValue.contains(where: \.isNewline) {
                                        focusedField = nil
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 22)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        // Pinned under the form; as a bottom inset it also rides above the keyboard.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            pickDesignButton
        }
    }

    private var isReviewWritten: Bool {
        TicketInput.isReviewWritten(oneLineReview)
    }

    private var pickDesignButton: some View {
        VStack(spacing: 8) {
            Button {
                focusedField = nil
                draftTicket = makeDraft()
                navigateToPicker = true
            } label: {
                Text("Pick a Design \u{2192}")
            }
            .buttonStyle(.primaryPill)
            .disabled(!isReviewWritten)
            .accessibilityHint(isReviewWritten ? "" : "Add a one-line review to continue.")

            if !isReviewWritten {
                Text("Add a one-line review to continue.")
                    .appStyle(.secondary)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        // 34pt above the bottom edge; tighter once the keyboard is up.
        .padding(.bottom, focusedField == nil ? 34 : 10)
        .frame(maxWidth: .infinity)
        .background(AppColor.ground)
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
                oneLineReview: TicketInput.savedReview(oneLineReview)
            )
        case .edit(let ticket, _):
            var edited = ticket
            edited.dateWatched = dateWatched
            edited.location = TicketInput.savedLocation(location)
            edited.oneLineReview = TicketInput.savedReview(oneLineReview)
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
