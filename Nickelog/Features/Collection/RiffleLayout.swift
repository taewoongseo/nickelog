import SwiftUI

/// Stacks one month's tickets like a riffled deck: every ticket overlaps the one before
/// it so only its top `peek` points show, except the open ticket (shown in full, with a
/// small gap before the next) and the last ticket (always shown in full).
/// Later tickets draw on top of earlier ones.
struct RiffleLayout: Layout {
    /// Index of the open ticket within this stack, or `nil` when none is open here.
    var selectedIndex: Int?

    /// How much of an overlapped ticket stays visible.
    static let peek: CGFloat = 64
    /// Space between the open ticket's bottom and the ticket after it.
    static let gapAfterOpen: CGFloat = 12

    /// Top edge of each ticket, measured from the top of the stack.
    static func tops(count: Int, selectedIndex: Int?, cardHeight: CGFloat) -> [CGFloat] {
        var tops: [CGFloat] = []
        var y: CGFloat = 0
        for index in 0..<max(count, 0) {
            tops.append(y)
            let isOpenWithTicketAfter = index == selectedIndex && index < count - 1
            y += isOpenWithTicketAfter ? cardHeight + gapAfterOpen : peek
        }
        return tops
    }

    static func totalHeight(count: Int, selectedIndex: Int?, cardHeight: CGFloat) -> CGFloat {
        guard count > 0 else { return 0 }
        let tops = tops(count: count, selectedIndex: selectedIndex, cardHeight: cardHeight)
        return (tops.last ?? 0) + cardHeight
    }

    private func cardHeight(in subviews: Subviews, width: CGFloat) -> CGFloat {
        subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: nil)).height ?? 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? subviews.first?.sizeThatFits(.unspecified).width ?? 0
        let height = Self.totalHeight(
            count: subviews.count,
            selectedIndex: selectedIndex,
            cardHeight: cardHeight(in: subviews, width: width)
        )
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let height = cardHeight(in: subviews, width: bounds.width)
        let tops = Self.tops(count: subviews.count, selectedIndex: selectedIndex, cardHeight: height)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + tops[index]),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: height)
            )
        }
    }
}

#Preview("Riffle stack") {
    let tickets = (1...4).map { number in
        Ticket(
            tmdbMovieID: number,
            title: "Movie \(number)",
            releaseYear: 2000 + number,
            posterURL: nil,
            dateWatched: .now,
            location: "Metrograph",
            oneLineReview: "One line number \(number).",
            templateID: TicketDesign.allCases[number % 3].rawValue,
            serialNumber: number
        )
    }
    return ScrollView {
        RiffleLayout(selectedIndex: 1) {
            ForEach(tickets) { TicketCard(ticket: $0) }
        }
        .padding(16)
    }
    .background(AppColor.ground)
}
