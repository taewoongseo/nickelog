import SwiftUI

/// Where each ticket sits, in the scroll view's own coordinate space.
private struct TicketFramesKey: PreferenceKey {
    static var defaultValue: [Ticket.ID: CGRect] = [:]

    static func reduce(value: inout [Ticket.ID: CGRect], nextValue: () -> [Ticket.ID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// The Ticket Book's scrolling body: month sections, each a riffle stack of tickets.
///
/// Selection follows the scroll: the ticket showing at a fixed line near the top of the
/// list is the one open ticket across the whole list. Scrolling down, the next ticket
/// takes over when it reaches the line; scrolling up, the previous one takes over when
/// the line re-enters its visible strip. The two switch points differ, which keeps the
/// selection from flickering when the layout shifts under it.
struct TicketBookView: View {
    let sections: [TicketMonth]
    /// Called when the already-open ticket is tapped.
    let onOpen: (Ticket) -> Void

    /// Distance from the top of the scroll view to the line that picks the open ticket.
    static let lineY: CGFloat = 40
    private static let spaceName = "ticketBook"

    /// Latest ticket positions, kept outside `@State` so scrolling doesn't re-render for them.
    private final class FrameStore {
        var frames: [Ticket.ID: CGRect] = [:]
    }

    @State private var selectedID: Ticket.ID?
    /// Set when a tap chose the open ticket, so scrolling to it isn't overruled on the way.
    /// Cleared as soon as the user drags the list.
    @State private var isPinned = false
    @State private var frameStore = FrameStore()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { outer in
            ScrollViewReader { proxy in
                book(proxy: proxy, viewportHeight: outer.size.height)
            }
        }
    }

    private func book(proxy: ScrollViewProxy, viewportHeight: CGFloat) -> some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        MonthHeaderRow(title: section.title, trailing: Self.headerText(for: section, selectedIndex: selectedIndex(in: section)))

                        RiffleLayout(selectedIndex: selectedIndex(in: section)) {
                            ForEach(section.tickets) { ticket in
                                Button {
                                    tap(ticket, proxy: proxy, viewportHeight: viewportHeight)
                                } label: {
                                    TicketCard(ticket: ticket)
                                }
                                .buttonStyle(.plain)
                                .id(ticket.id)
                                .background(frameReader(for: ticket))
                                .accessibilityLabel(accessibilityLabel(for: ticket))
                                .accessibilityValue(ticket.id == selectedID ? "Open" : "")
                                .accessibilityHint(ticket.id == selectedID ? "Opens the ticket" : "Brings the ticket forward")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 18)
            // Room for the floating tab bar so it never covers the last ticket.
            .padding(.bottom, 120)
        }
        .coordinateSpace(name: Self.spaceName)
        .simultaneousGesture(DragGesture(minimumDistance: 4).onChanged { _ in
            isPinned = false
        })
        .onPreferenceChange(TicketFramesKey.self) { frames in
            frameStore.frames = frames
            updateSelection(from: frames)
        }
        // One small tick each time a different ticket becomes the open one. The first
        // pick when the list appears is not a change the user made, so it stays silent.
        .sensoryFeedback(.selection, trigger: selectedID) { old, new in
            old != nil && new != nil
        }
    }

    private func accessibilityLabel(for ticket: Ticket) -> String {
        guard ticket.isPlanned else {
            return "\(ticket.title), \(ticket.dateWatched.formatted(date: .abbreviated, time: .omitted))"
        }
        let when = ticket.scheduledDate?.formatted(date: .abbreviated, time: .omitted) ?? "date to be decided"
        return "\(ticket.title), coming soon, \(when)"
    }

    private func selectedIndex(in section: TicketMonth) -> Int? {
        section.tickets.firstIndex { $0.id == selectedID }
    }

    private func frameReader(for ticket: Ticket) -> some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: TicketFramesKey.self,
                value: [ticket.id: geometry.frame(in: .named(Self.spaceName))]
            )
        }
    }

    /// The open ticket is the last one whose top edge is at or above the line; before any
    /// ticket reaches the line, it is the topmost ticket.
    private func updateSelection(from frames: [Ticket.ID: CGRect]) {
        guard !isPinned else { return }
        let aboveLine = frames.filter { $0.value.minY <= Self.lineY }
        let target = aboveLine.max { $0.value.minY < $1.value.minY }?.key
            ?? frames.min { $0.value.minY < $1.value.minY }?.key
        guard let target, target != selectedID else { return }
        // With Reduce Motion on, the selection changes instantly instead of springing.
        withAnimation(selectionAnimation) {
            selectedID = target
        }
    }

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .spring(duration: 0.34, bounce: 0.15)
    }

    /// Tapping the open ticket opens it. Tapping a peeking ticket makes it the open one
    /// and scrolls it up to the line.
    private func tap(_ ticket: Ticket, proxy: ScrollViewProxy, viewportHeight: CGFloat) {
        if ticket.id == selectedID {
            onOpen(ticket)
            return
        }

        isPinned = true
        // `scrollTo` lines up a point of the ticket with the same point of the viewport,
        // so this fraction puts the ticket's top edge exactly on the line.
        let cardHeight = frameStore.frames[ticket.id]?.height ?? 0
        let spare = viewportHeight - cardHeight
        let fraction = spare > 0 ? min(max(Self.lineY / spare, 0), 1) : 0
        withAnimation(selectionAnimation) {
            selectedID = ticket.id
            proxy.scrollTo(ticket.id, anchor: UnitPoint(x: 0.5, y: fraction))
        }
    }

    /// "N OF M" for the month holding the open ticket, a plain count for the others.
    static func headerText(for section: TicketMonth, selectedIndex: Int?) -> String {
        let total = section.tickets.count
        if let selectedIndex {
            return "\(selectedIndex + 1) of \(total)"
        }
        return total == 1 ? "1 ticket" : "\(total) tickets"
    }
}

#Preview("Ticket Book") {
    let store = TicketStore()
    for number in 1...6 {
        store.addAssigningSerial(Ticket(
            tmdbMovieID: number,
            title: "Movie \(number)",
            releaseYear: 2000 + number,
            posterURL: nil,
            dateWatched: Calendar.current.date(byAdding: .day, value: -number * 9, to: .now) ?? .now,
            location: "Metrograph",
            oneLineReview: "One line number \(number).",
            templateID: TicketDesign.allCases[number % 3].rawValue
        ))
    }
    return TicketBookView(sections: TicketGrouping.months(from: store.tickets), onOpen: { _ in })
        .background(AppColor.ground)
}
