import SwiftUI

@main
struct TripStoreApp: App {
    @StateObject private var container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(container)
                .environmentObject(container.favouritesManager)
                .task { await container.favouritesManager.load() }
        }
    }
}
