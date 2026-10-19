import SwiftUI

/// Full-width (52pt) and compact (44pt) capsule buttons.
/// Primary: ink fill, light text. Secondary: tan fill with a soft border.
struct PillButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary }
    enum Size { case regular, compact }

    let kind: Kind
    let size: Size

    func makeBody(configuration: Configuration) -> some View {
        PillBody(kind: kind, size: size, label: configuration.label, isPressed: configuration.isPressed)
    }

    private struct PillBody: View {
        let kind: Kind
        let size: Size
        let label: ButtonStyleConfiguration.Label
        let isPressed: Bool

        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .appStyle(size == .regular ? .bodyStrong : .bodyStrongSmall)
                .foregroundStyle(kind == .primary ? AppColor.surface : AppColor.ink)
                .padding(.horizontal, size == .regular ? 24 : 22)
                .frame(maxWidth: size == .regular ? .infinity : nil, minHeight: size == .regular ? 52 : 44)
                .background(kind == .primary ? AppColor.ink : AppColor.tan, in: Capsule())
                .overlay {
                    if kind == .secondary {
                        Capsule().strokeBorder(AppColor.hairlineSoft, lineWidth: 1)
                    }
                }
                .contentShape(Capsule())
                .opacity(isEnabled ? (isPressed ? 0.8 : 1) : 0.4)
        }
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var primaryPill: PillButtonStyle { PillButtonStyle(kind: .primary, size: .regular) }
    static var secondaryPill: PillButtonStyle { PillButtonStyle(kind: .secondary, size: .regular) }
    static var primaryPillCompact: PillButtonStyle { PillButtonStyle(kind: .primary, size: .compact) }
}

#Preview("Pills") {
    VStack(spacing: 10) {
        Button { } label: { Label("Share Ticket", systemImage: "square.and.arrow.up") }
            .buttonStyle(.primaryPill)
        Button { } label: { Label("Save to Photos", systemImage: "arrow.down.to.line") }
            .buttonStyle(.secondaryPill)
        Button { } label: { Label("Log a Movie", systemImage: "plus") }
            .buttonStyle(.primaryPillCompact)
        Button("Pick a Design \u{2192}") { }
            .buttonStyle(.primaryPill)
            .disabled(true)
    }
    .padding(24)
    .background(AppColor.ground)
}
