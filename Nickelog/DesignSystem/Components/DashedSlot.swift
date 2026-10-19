import SwiftUI

/// A dashed, rounded outline, either closed or open along the bottom edge.
struct DashedSlotShape: Shape {
    var cornerRadius: CGFloat = 6
    var openBottom = false

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: 0.75, dy: 0.75)
        let r = cornerRadius
        var path = Path()
        if openBottom {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX + r, y: rect.minY), radius: r)
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY + r), radius: r)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
        }
        return path
    }
}

/// Placeholder container with a dashed border. Closed slots get a surface fill;
/// open-bottom slots (like the "Next showing" tab) are unfilled.
struct DashedSlot<Content: View>: View {
    var openBottom = false
    var borderColor: Color = AppColor.hairline
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background {
                if !openBottom {
                    RoundedRectangle(cornerRadius: 6).fill(AppColor.surface)
                }
            }
            .overlay {
                DashedSlotShape(openBottom: openBottom)
                    .stroke(borderColor, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            }
    }
}

#Preview("Dashed slots") {
    VStack(spacing: 24) {
        DashedSlot {
            Text("Coming attractions.")
                .appStyle(.display)
                .foregroundStyle(AppColor.ink)
                .frame(height: 182)
        }
        DashedSlot(openBottom: true) {
            Text("No. 000002 \u{00B7} Next showing")
                .appStyle(.serial)
                .foregroundStyle(AppColor.mutedSlip)
                .padding(.top, 14)
                .frame(height: 64, alignment: .top)
        }
    }
    .padding(16)
    .background(AppColor.ground)
}
