import SwiftUI

/// Reference geometry for the ticket, in points at the 1300x640 design scale.
/// The card multiplies these by `width / referenceWidth`.
enum TicketMetrics {
    static let referenceWidth: CGFloat = 1300
    static let referenceHeight: CGFloat = 640
    static let aspectRatio: CGFloat = referenceWidth / referenceHeight

    static let notchRadius: CGFloat = 42
    /// Distance from the outer edge to the first decorative rule.
    static let inset: CGFloat = 14
    /// Share of the inner width taken by the main body (the rest is the stub).
    static let mainFraction: CGFloat = 0.78

    /// X position of the dashed divider between main body and stub.
    static var dividerX: CGFloat {
        inset + mainFraction * (referenceWidth - 2 * inset)
    }
}

/// A rounded rectangle with six concave circular notches: one at each outer
/// corner plus one where the stub divider meets the top and bottom edges.
/// The arcs cut into the ticket, like a coin-punch.
struct NotchedTicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / TicketMetrics.referenceWidth
        let r = TicketMetrics.notchRadius * scale
        let dx = rect.minX + TicketMetrics.dividerX * scale
        let left = rect.minX, right = rect.maxX, top = rect.minY, bottom = rect.maxY

        var path = Path()
        path.move(to: CGPoint(x: left + r, y: top))
        path.addLine(to: CGPoint(x: dx - r, y: top))
        path.addNotch(center: CGPoint(x: dx, y: top), radius: r, from: .pi, to: 0)
        path.addLine(to: CGPoint(x: right - r, y: top))
        path.addNotch(center: CGPoint(x: right, y: top), radius: r, from: .pi, to: .pi / 2)
        path.addLine(to: CGPoint(x: right, y: bottom - r))
        path.addNotch(center: CGPoint(x: right, y: bottom), radius: r, from: 3 * .pi / 2, to: .pi)
        path.addLine(to: CGPoint(x: dx + r, y: bottom))
        path.addNotch(center: CGPoint(x: dx, y: bottom), radius: r, from: 2 * .pi, to: .pi)
        path.addLine(to: CGPoint(x: left + r, y: bottom))
        path.addNotch(center: CGPoint(x: left, y: bottom), radius: r, from: 2 * .pi, to: 3 * .pi / 2)
        path.addLine(to: CGPoint(x: left, y: top + r))
        path.addNotch(center: CGPoint(x: left, y: top), radius: r, from: .pi / 2, to: 0)
        path.closeSubpath()
        return path
    }
}

private extension Path {
    /// Arc that bulges into the shape. Every notch sweeps the same screen
    /// direction (counter-clockwise on screen) when going around the outline.
    mutating func addNotch(center: CGPoint, radius: CGFloat, from start: CGFloat, to end: CGFloat) {
        addArc(
            center: center,
            radius: radius,
            startAngle: .radians(Double(start)),
            endAngle: .radians(Double(end)),
            clockwise: true
        )
    }
}
