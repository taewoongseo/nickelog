import SwiftUI

/// The paper "admission slip" that holds the Log It fields: a surface card with a
/// double rule (the ticket's border, quieted), a top row with the serial number, and a
/// dashed divider above the content.
struct AdmissionSlip<Content: View>: View {
    /// Six-digit serial, shown as "No. 000113". Empty leaves the number spot blank.
    let serial: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Admission slip")
                    .appStyle(.labelSmall)
                    .foregroundStyle(AppColor.ink2)
                Spacer(minLength: 12)
                if !serial.isEmpty {
                    Text("No. \(serial)")
                        .appStyle(.slipSerial)
                        .foregroundStyle(AppColor.red)
                }
            }
            .accessibilityElement(children: .combine)

            Line()
                .stroke(AppColor.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                .frame(height: 1.5)

            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(AppColor.hairline, lineWidth: 1))
        .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(AppColor.hairline, lineWidth: 0.5).padding(4))
    }

    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return path
        }
    }
}

/// One row on the slip: a caps label (with an optional live counter on the right), the
/// input, and an underline that turns ink while the field is focused.
struct SlipField<Content: View>: View {
    let label: String
    /// Characters used and the limit; the count turns red near the limit.
    var counter: (count: Int, limit: Int, warningCount: Int)?
    var isFocused = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .appStyle(.labelSmall)
                    .foregroundStyle(AppColor.ink2)
                Spacer(minLength: 12)
                if let counter {
                    Text("\(counter.count) / \(counter.limit)")
                        .appStyle(.counter)
                        .monospacedDigit()
                        .foregroundStyle(TicketInput.isNearLimit(count: counter.count, warningCount: counter.warningCount) ? AppColor.red : AppColor.ink2)
                        .accessibilityLabel("\(counter.count) of \(counter.limit) characters")
                }
            }

            content()
                .padding(.bottom, 4)

            Rectangle()
                .fill(isFocused ? AppColor.ink : AppColor.hairline)
                .frame(height: 1)
        }
    }
}

#Preview("Admission slip") {
    AdmissionSlip(serial: "000113") {
        SlipField(label: "Screened") {
            Text("Oct 24, 2026").appStyle(.slipEntry)
        }
        SlipField(label: "Played At", counter: (23, 25, 23), isFocused: true) {
            Text("AMC Lincoln Square").appStyle(.slipEntry)
        }
        SlipField(label: "One-line review", counter: (42, 80, 72)) {
            Text("Every glance lands.").appStyle(.slipReview)
        }
    }
    .padding(16)
    .background(AppColor.ground)
}
