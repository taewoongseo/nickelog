import SwiftUI

/// 44pt circular button holding a single icon (search, account, and similar).
struct IconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundStyle(AppColor.ink)
                .frame(width: 44, height: 44)
                .background(AppColor.surface, in: Circle())
                .overlay(Circle().strokeBorder(AppColor.hairlineSoft, lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// 44pt bordered capsule on a surface fill, used for Edit and Delete.
struct BorderedCapsuleButtonStyle: ButtonStyle {
    var isDestructive = false

    func makeBody(configuration: Configuration) -> some View {
        CapsuleBody(isDestructive: isDestructive, label: configuration.label, isPressed: configuration.isPressed)
    }

    private struct CapsuleBody: View {
        let isDestructive: Bool
        let label: ButtonStyleConfiguration.Label
        let isPressed: Bool

        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .appStyle(.callout)
                .foregroundStyle(isDestructive ? AppColor.red : AppColor.ink)
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .background(AppColor.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(AppColor.hairlineSoft, lineWidth: 1))
                .contentShape(Capsule())
                .opacity(isEnabled ? (isPressed ? 0.7 : 1) : 0.4)
        }
    }
}

/// Plain red text action (for example "Cancel"), 44pt tall.
struct RedTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appStyle(.body)
            .foregroundStyle(AppColor.red)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == BorderedCapsuleButtonStyle {
    static var borderedCapsule: BorderedCapsuleButtonStyle { BorderedCapsuleButtonStyle() }
    static var borderedCapsuleDestructive: BorderedCapsuleButtonStyle { BorderedCapsuleButtonStyle(isDestructive: true) }
}

extension ButtonStyle where Self == RedTextButtonStyle {
    static var redText: RedTextButtonStyle { RedTextButtonStyle() }
}

#Preview("Action buttons") {
    VStack(spacing: 16) {
        HStack {
            IconButton(systemName: "magnifyingglass", accessibilityLabel: "Search", action: {})
            IconButton(systemName: "person", accessibilityLabel: "Account", action: {})
        }
        HStack {
            Button { } label: { Label("Edit", systemImage: "pencil") }
                .buttonStyle(.borderedCapsule)
            Button { } label: { Label("Delete", systemImage: "trash") }
                .buttonStyle(.borderedCapsuleDestructive)
        }
        Button("Cancel") { }
            .buttonStyle(.redText)
    }
    .padding(24)
    .background(AppColor.ground)
}
