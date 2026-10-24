import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case collection, logMovie

    var title: String {
        switch self {
        case .collection: "Collection"
        case .logMovie: "Add a Film"
        }
    }

    var identifier: String {
        switch self {
        case .collection: "tab.collection"
        case .logMovie: "tab.logMovie"
        }
    }

    var systemImage: String {
        switch self {
        case .collection: "ticket"
        case .logMovie: "plus"
        }
    }
}

/// Floating capsule tab bar: a frosted surface, a soft border and shadow, and a
/// tan pill behind the selected tab.
struct AppTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                item(for: tab)
            }
        }
        .padding(4)
        .background {
            Capsule().fill(.regularMaterial)
            Capsule().fill(AppColor.surface.opacity(0.88))
        }
        .overlay(Capsule().strokeBorder(AppColor.hairlineSoft, lineWidth: 1))
        .shadow(color: AppColor.ink.opacity(0.14), radius: 10, y: 6)
    }

    private func item(for tab: AppTab) -> some View {
        let isSelected = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22, weight: .regular))
                Text(tab.title)
                    .appStyle(.tab)
            }
            .foregroundStyle(isSelected ? AppColor.ink : AppColor.ink2)
            .frame(minWidth: 124, minHeight: 52)
            .background(isSelected ? AppColor.tan : Color.clear, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityIdentifier(tab.identifier)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Switching tabs from inside a screen

private struct SelectTabKey: EnvironmentKey {
    static let defaultValue: (AppTab) -> Void = { _ in }
}

extension EnvironmentValues {
    /// Lets a screen switch tabs (for example the empty Collection's "Add a Film" button).
    var selectTab: (AppTab) -> Void {
        get { self[SelectTabKey.self] }
        set { self[SelectTabKey.self] = newValue }
    }
}

// MARK: - Hiding the bar on pushed screens

/// Counts how many pushed screens currently want the tab bar hidden.
@MainActor
final class TabBarState: ObservableObject {
    @Published private(set) var hiddenRequests = 0

    var isVisible: Bool { hiddenRequests == 0 }

    func requestHidden() { hiddenRequests += 1 }
    func releaseHidden() { hiddenRequests = max(0, hiddenRequests - 1) }
}

private struct TabBarStateKey: EnvironmentKey {
    static let defaultValue: TabBarState? = nil
}

extension EnvironmentValues {
    var tabBarState: TabBarState? {
        get { self[TabBarStateKey.self] }
        set { self[TabBarStateKey.self] = newValue }
    }
}

private struct HidesTabBarModifier: ViewModifier {
    @Environment(\.tabBarState) private var tabBarState

    func body(content: Content) -> some View {
        content
            .onAppear { tabBarState?.requestHidden() }
            .onDisappear { tabBarState?.releaseHidden() }
    }
}

extension View {
    /// Hides the floating tab bar while this (pushed) screen is showing.
    func hidesTabBar() -> some View {
        modifier(HidesTabBarModifier())
    }
}

#Preview("Tab bar") {
    struct Demo: View {
        @State private var selection = AppTab.collection
        var body: some View {
            AppTabBar(selection: $selection)
                .padding(24)
                .background(AppColor.ground)
        }
    }
    return Demo()
}
