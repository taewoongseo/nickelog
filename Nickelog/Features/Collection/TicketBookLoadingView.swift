import SwiftUI

/// The Ticket Book while tickets are still being fetched: grey placeholder tickets in
/// the same overlapping layout, pulsing gently, with a note underneath. Not yet shown
/// by the app; it waits for cloud sync.
struct TicketBookLoadingView: View {
    /// Caption for the screen header while this view is showing.
    static let headerCaption = "Collecting your tickets\u{2026}"

    private static let placeholderCount = 5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDimmed = false

    var body: some View {
        VStack(spacing: 0) {
            RiffleLayout(selectedIndex: nil) {
                ForEach(0..<Self.placeholderCount, id: \.self) { _ in
                    NotchedTicketShape()
                        .fill(AppColor.divider)
                        .overlay(NotchedTicketShape().stroke(AppColor.hairline, lineWidth: 1))
                        .aspectRatio(TicketMetrics.referenceWidth / TicketMetrics.referenceHeight, contentMode: .fit)
                }
            }
            .opacity(isDimmed ? 0.55 : 1)
            .accessibilityHidden(true)

            Text("Syncing with your account.")
                .appStyle(.secondary)
                .foregroundStyle(AppColor.ink2)
                .padding(.top, 20)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .accessibilityElement(children: .combine)
        .onAppear(perform: updatePulse)
        .onChange(of: reduceMotion) { updatePulse() }
    }

    private func updatePulse() {
        if reduceMotion {
            withAnimation(nil) { isDimmed = false }
        } else {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                isDimmed = true
            }
        }
    }
}

#Preview("Loading") {
    VStack(spacing: 0) {
        ScreenHeader(title: "Ticket Book", caption: TicketBookLoadingView.headerCaption)
        TicketBookLoadingView()
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .background(AppColor.ground)
}
