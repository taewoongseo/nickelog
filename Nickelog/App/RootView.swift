import SwiftUI

struct RootView: View {
    @State private var selection: AppTab = .collection
    @StateObject private var tabBarState = TabBarState()
    @State private var isKeyboardVisible = false

    var body: some View {
        // SwiftUI's TabView keeps each tab's state alive; its own bar is hidden and
        // replaced by the floating AppTabBar below.
        TabView(selection: $selection) {
            CollectionView()
                .toolbar(.hidden, for: .tabBar)
                .tag(AppTab.collection)

            SearchView()
                .toolbar(.hidden, for: .tabBar)
                .tag(AppTab.logMovie)
        }
        .tint(AppColor.ink)
        .environment(\.tabBarState, tabBarState)
        .environment(\.selectTab) { selection = $0 }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if tabBarState.isVisible && !isKeyboardVisible {
                AppTabBar(selection: $selection)
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: tabBarState.isVisible)
        .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
        // The floating bar would otherwise ride up on top of the keyboard.
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

#Preview {
    RootView()
        .environmentObject(TicketStore())
}
