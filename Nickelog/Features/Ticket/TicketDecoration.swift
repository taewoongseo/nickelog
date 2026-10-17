import SwiftUI

/// The purely decorative layer under the ticket's text: the double rule, the
/// hatched stripe, and the four corner stars. All positions and sizes are in
/// reference points (1300x640) multiplied by `scale`.
struct TicketDecoration: View {
    let theme: TicketTheme
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .strokeBorder(theme.accent, lineWidth: 3 * scale)
                .padding(14 * scale)

            Rectangle()
                .strokeBorder(theme.ruleSecondary, lineWidth: 1 * scale)
                .padding(20 * scale)

            HatchedStripe(color: theme.accent, scale: scale)
                .frame(width: 12 * scale)
                .padding(.leading, 30 * scale)
                .padding(.vertical, 28 * scale)

            cornerStars
        }
    }

    private var cornerStars: some View {
        let inset = 34 * scale
        return ZStack {
            star.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            star.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            star.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            star.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .padding(inset)
    }

    private var star: some View {
        Text("\u{2726}")
            .font(.system(size: 26 * scale))
            .foregroundStyle(theme.ornament)
    }
}

/// 45-degree diagonal stripes, 4 wide with a 5 gap, drawn at 40% opacity.
private struct HatchedStripe: View {
    let color: Color
    let scale: CGFloat

    var body: some View {
        Canvas { context, size in
            let stripeWidth = 4 * scale
            let period = 9 * scale
            let step = period * 2.0.squareRoot()
            var path = Path()
            var offset = -size.height
            while offset < size.width + size.height {
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset + size.height, y: size.height))
                offset += step
            }
            context.stroke(path, with: .color(color.opacity(0.4)), lineWidth: stripeWidth * 2.0.squareRoot())
        }
        .clipped()
    }
}

/// Aged-paper grain laid over the whole ticket. Multiplying keeps each palette's
/// own paper color; the overlay sits on top so nothing is left looking flat.
struct PaperGrainOverlay: View {
    var body: some View {
        Image("PaperGrain")
            .resizable()
            .scaledToFill()
            .blendMode(.multiply)
            .opacity(0.55)
            .allowsHitTesting(false)
    }
}
