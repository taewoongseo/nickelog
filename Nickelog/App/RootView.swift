import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "ticket")
                }

            SearchView()
                .tabItem {
                    Label("Log a Movie", systemImage: "plus.circle")
                }
        }
    }
}

#Preview {
    RootView()
}
