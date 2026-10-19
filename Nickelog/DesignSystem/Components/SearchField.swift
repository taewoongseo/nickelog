import SwiftUI

/// 44pt capsule search field with a magnifier and a round clear button.
struct AppSearchField: View {
    @Binding var text: String
    let placeholder: String
    /// Owned by the screen, so it can drop focus when the user navigates away.
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.ink2)
                .accessibilityHidden(true)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColor.muted))
                .appStyle(.body)
                .foregroundStyle(AppColor.ink)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .focused($isFocused)
                .accessibilityLabel(placeholder)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColor.surface)
                        .frame(width: 28, height: 28)
                        .background(AppColor.hairlineSoft, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .frame(minHeight: 44)
        .background(AppColor.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(AppColor.hairline, lineWidth: 1))
        .contentShape(Capsule())
        .onTapGesture { isFocused = true }
    }
}

#Preview("Search field") {
    struct Demo: View {
        @State private var empty = ""
        @State private var filled = "Jaws"
        @FocusState private var focused: Bool
        var body: some View {
            VStack(spacing: 16) {
                AppSearchField(text: $empty, placeholder: "Search films", isFocused: $focused)
                AppSearchField(text: $filled, placeholder: "Search films", isFocused: $focused)
            }
            .padding(16)
            .background(AppColor.ground)
        }
    }
    return Demo()
}
