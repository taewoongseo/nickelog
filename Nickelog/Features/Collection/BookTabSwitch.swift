import SwiftUI

/// Which list the Ticket Book is showing.
enum BookTab: Hashable {
    /// Films already watched and logged.
    case screened
    /// Films saved to watch later.
    case comingSoon
}

/// Two words under the Ticket Book's title, each with its own count: the active one in
/// ink with a thin underline, the other dimmed.
struct BookTabSwitch: View {
    @Binding var selection: BookTab
    let screenedCount: Int
    let comingSoonCount: Int

    var body: some View {
        HStack(spacing: 24) {
            word("Screened", count: screenedCount, tab: .screened)
            word("Coming Soon", count: comingSoonCount, tab: .comingSoon)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }

    private func word(_ title: String, count: Int, tab: BookTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Text("\(title) \(count)")
                .appStyle(.label)
                .foregroundStyle(isSelected ? AppColor.ink : AppColor.muted)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isSelected ? AppColor.ink : Color.clear)
                        .frame(height: 1.5)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(count)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    struct Demo: View {
        @State private var tab = BookTab.screened
        var body: some View {
            BookTabSwitch(selection: $tab, screenedCount: 12, comingSoonCount: 3)
                .padding(.vertical, 20)
                .background(AppColor.ground)
        }
    }
    return Demo()
}
