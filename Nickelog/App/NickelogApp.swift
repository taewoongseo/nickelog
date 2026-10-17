import SwiftUI

@main
struct NickelogApp: App {
    @StateObject private var ticketStore = TicketStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(ticketStore)
        }
    }
}
