import SwiftUI

/// The designed ticket: main body on the left, stub on the right, cut out by a
/// notched outline. Everything is laid out in real views so variable-length
/// text can reflow; sizes scale from the 1300x640 reference by the card's width.
struct TicketCard: View {
    let ticket: Ticket
    /// Overrides the ticket's own design, for previews in the design picker.
    var design: TicketDesign?

    private var theme: TicketTheme {
        .theme(for: design ?? ticket.design)
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / TicketMetrics.referenceWidth
            TicketCardContent(ticket: ticket, theme: theme, scale: scale)
                .frame(width: geo.size.width, height: geo.size.width / TicketMetrics.aspectRatio)
        }
        .aspectRatio(TicketMetrics.aspectRatio, contentMode: .fit)
    }
}

private struct TicketCardContent: View {
    let ticket: Ticket
    let theme: TicketTheme
    let scale: CGFloat

    private var inset: CGFloat { TicketMetrics.inset * scale }
    private var innerWidth: CGFloat { (TicketMetrics.referenceWidth - 2 * TicketMetrics.inset) * scale }
    private var innerHeight: CGFloat { (TicketMetrics.referenceHeight - 2 * TicketMetrics.inset) * scale }
    private var mainWidth: CGFloat { TicketMetrics.mainFraction * innerWidth }
    private var dividerWidth: CGFloat { 3 * scale }

    var body: some View {
        ZStack(alignment: .topLeading) {
            theme.paper

            TicketDecoration(theme: theme, scale: scale)

            HStack(spacing: 0) {
                TicketMainBody(ticket: ticket, theme: theme, scale: scale)
                    .frame(width: mainWidth, height: innerHeight)

                DashedLine(vertical: true)
                    .stroke(theme.ruleSecondary, style: StrokeStyle(lineWidth: dividerWidth, dash: [9 * scale, 6 * scale]))
                    .frame(width: dividerWidth, height: innerHeight)

                TicketStub(ticket: ticket, theme: theme, scale: scale)
                    .frame(width: innerWidth - mainWidth - dividerWidth, height: innerHeight)
            }
            .padding(inset)

            PaperGrainOverlay()
        }
        .clipShape(NotchedTicketShape())
    }
}

// MARK: - Main body

private struct TicketMainBody: View {
    let ticket: Ticket
    let theme: TicketTheme
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            topHalf
                .frame(maxHeight: .infinity)
            bottomHalf
                .frame(maxHeight: .infinity)
        }
        .padding(.top, 36 * scale)
        .padding(.bottom, 36 * scale)
        .padding(.leading, 68 * scale)
        .padding(.trailing, 56 * scale)
    }

    private var topHalf: some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            VStack(alignment: .leading, spacing: 14 * scale) {
                Text(ticket.title)
                    .font(theme.title.font(scale: scale))
                    .lineSpacing(theme.title.lineSpacing(scale: scale))
                    .foregroundStyle(theme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)

                if let year = ticket.releaseYear {
                    Text(String(year))
                        .font(theme.year.font(scale: scale))
                        .tracking(theme.year.tracking * scale)
                        .foregroundStyle(theme.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            DateLocationBox(ticket: ticket, theme: theme, scale: scale)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private var bottomHalf: some View {
        VStack(alignment: .leading, spacing: 20 * scale) {
            OrnamentDivider(theme: theme, scale: scale)

            Text("\u{201C}\(ticket.oneLineReview)\u{201D}")
                .font(theme.review.font(scale: scale))
                .lineSpacing(theme.review.lineSpacing(scale: scale))
                .foregroundStyle(theme.inkSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

/// Bordered two-cell box: date on the left, location on the right (1 : 1.3).
/// A blank location leaves its cell empty and the box unchanged.
private struct DateLocationBox: View {
    let ticket: Ticket
    let theme: TicketTheme
    let scale: CGFloat

    private var boxWidth: CGFloat {
        (TicketMetrics.mainFraction * (TicketMetrics.referenceWidth - 2 * TicketMetrics.inset) - 68 - 56) * scale
    }

    var body: some View {
        HStack(spacing: 0) {
            cell(Text(ticket.dateWatched.formatted(.dateTime.month(.abbreviated).day().year())))
                .frame(width: boxWidth / 2.3, alignment: .leading)

            Rectangle()
                .fill(theme.accent)
                .frame(width: 1 * scale)

            cell(Text(ticket.location ?? ""))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(Rectangle().strokeBorder(theme.accent, lineWidth: 2 * scale))
        .frame(width: boxWidth)
    }

    private func cell(_ text: Text) -> some View {
        text
            .font(theme.meta.font(scale: scale))
            .foregroundStyle(theme.inkSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 22 * scale)
            .padding(.vertical, 14 * scale)
    }
}

/// Dashed rule with a small star sitting on it, the line breaking around the star.
private struct OrnamentDivider: View {
    let theme: TicketTheme
    let scale: CGFloat

    var body: some View {
        ZStack {
            DashedLine()
                .stroke(theme.ruleSecondary, style: StrokeStyle(lineWidth: 1 * scale, dash: [6 * scale, 4 * scale]))
                .frame(height: 1 * scale)

            Text("\u{2726}")
                .font(.system(size: 20 * scale))
                .foregroundStyle(theme.ornament)
                .padding(.horizontal, 14 * scale)
                .background(theme.paper)
        }
    }
}

// MARK: - Stub

private struct TicketStub: View {
    let ticket: Ticket
    let theme: TicketTheme
    let scale: CGFloat

    /// Section heights as flex ratios of the stub's height: 3 : 0.55 : 0.55 : 0.75.
    private let ratios: [CGFloat] = [3, 0.55, 0.55, 0.75]

    var body: some View {
        GeometryReader { geo in
            let unit = geo.size.height / ratios.reduce(0, +)
            VStack(spacing: 0) {
                admitOne
                    .frame(height: unit * ratios[0])

                section(unit * ratios[1], dashed: true) {
                    Text(ticket.formattedSerial)
                        .font(theme.serialNumber.font(scale: scale))
                        .tracking(theme.serialNumber.tracking * scale)
                        .foregroundStyle(theme.serial)
                }

                section(unit * ratios[2], dashed: true) {
                    Text("5\u{00A2}")
                        .font(theme.price.font(scale: scale))
                        .foregroundStyle(theme.accent)
                }

                section(unit * ratios[3], dashed: false) {
                    Text("NICKELOG")
                        .font(theme.wordmark.font(scale: scale))
                        .tracking(theme.wordmark.tracking * scale)
                        .foregroundStyle(theme.accent)
                }
            }
        }
    }

    private var admitOne: some View {
        Text("ADMIT ONE")
            .font(theme.admitOne.font(scale: scale))
            .tracking(theme.admitOne.tracking * scale)
            .foregroundStyle(theme.accent)
            .fixedSize()
            .rotationEffect(.degrees(90))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func section<Content: View>(_ height: CGFloat, dashed: Bool, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .top) {
                DashedLine()
                    .stroke(
                        dashed ? theme.ruleSecondary : theme.accent,
                        style: dashed ? StrokeStyle(lineWidth: 2 * scale, dash: [8 * scale, 5 * scale]) : StrokeStyle(lineWidth: 2 * scale)
                    )
                    .frame(height: 2 * scale)
            }
    }
}

// MARK: - Shared drawing

/// A straight line through the middle of its frame, horizontal by default.
struct DashedLine: Shape {
    var vertical = false

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if vertical {
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
        return path
    }
}

#Preview("Grindhouse Gothic") {
    TicketCard(ticket: .previewSample, design: .grindhouseGothic)
        .padding(24)
}

#Preview("Marquee Prestige") {
    TicketCard(ticket: .previewSample, design: .marqueePrestige)
        .padding(24)
}

#Preview("Sector Blue") {
    TicketCard(ticket: .previewSample, design: .sectorBlue)
        .padding(24)
}

extension Ticket {
    /// Sample data for SwiftUI previews and visual checks.
    static var previewSample: Ticket {
        Ticket(
            tmdbMovieID: 240,
            title: "The Godfather Part II",
            releaseYear: 1974,
            posterURL: nil,
            dateWatched: Date(timeIntervalSince1970: 1_773_446_400),
            location: "AMC Lincoln Sq.",
            oneLineReview: "Rare occasion of a stronger sequel to an existing masterpiece \u{2014} Coppola somehow tops himself.",
            serialNumber: 47
        )
    }
}
