import SwiftUI

/// Step between the details form and the finished ticket: the user's own ticket
/// shown in each of the three designs, tap one to choose it.
struct TicketDesignPickerView: View {
    /// The ticket as filled in so far; its design and serial are set here.
    let draft: Ticket
    /// Editing an existing ticket: its current design starts selected and its own
    /// serial number is shown, instead of the next free one.
    let isEditing: Bool
    /// Saving a film to watch later: no number is shown, and the button saves it to Coming Soon.
    let isPlanning: Bool
    let onPick: (TicketDesign) -> Void

    @EnvironmentObject private var ticketStore: TicketStore
    @State private var selectedDesign: TicketDesign

    private let sideMargin: CGFloat = 24

    init(draft: Ticket, isEditing: Bool = false, isPlanning: Bool = false, startingDesign: TicketDesign? = nil, onPick: @escaping (TicketDesign) -> Void) {
        self.draft = draft
        self.isEditing = isEditing
        self.isPlanning = isPlanning
        self.onPick = onPick
        _selectedDesign = State(initialValue: startingDesign ?? (isEditing ? draft.design : .default))
    }

    private var preview: Ticket {
        var ticket = draft
        if !isEditing && !isPlanning {
            ticket.serialNumber = ticketStore.nextSerialNumber
        }
        return ticket
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Pick a Design")
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 28) {
                    ForEach(TicketDesign.allCases) { design in
                        option(for: design)
                    }
                }
                .padding(.horizontal, sideMargin)
                .padding(.vertical, 20)
            }
        }
        .background(AppColor.ground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                onPick(selectedDesign)
            } label: {
                Text(isEditing ? "Save Changes" : (isPlanning ? "Save My Seat" : "Print My Ticket"))
            }
            .buttonStyle(.primaryPill)
            .padding(.horizontal, sideMargin)
            .padding(.vertical, 12)
            .background(AppColor.ground)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .appBackButton(isEditing ? "Edit" : (isPlanning ? "Save a Seat" : "Log It"))
        .hidesTabBar()
    }

    private func option(for design: TicketDesign) -> some View {
        let isSelected = design == selectedDesign
        return Button {
            selectedDesign = design
        } label: {
            VStack(spacing: 10) {
                TicketCard(ticket: preview, design: design)
                    .overlay {
                        NotchedTicketShape()
                            .stroke(AppColor.ink, lineWidth: isSelected ? 4 : 0)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 14, y: 6)

                Text(design.displayName)
                    .appStyle(isSelected ? .bodyStrong : .secondary)
                    .foregroundStyle(isSelected ? AppColor.ink : AppColor.ink2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(design.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        TicketDesignPickerView(draft: .previewSample, onPick: { _ in })
            .environmentObject(TicketStore())
    }
}
