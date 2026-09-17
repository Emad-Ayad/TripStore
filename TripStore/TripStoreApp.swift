import SwiftUI

@main
struct TripStoreApp: App {
    @StateObject private var container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(container)
                .environmentObject(container.favouritesManager)
                .environmentObject(container.orderViewModel)
                .task {
                    await container.favouritesManager.load()
                    await container.orderViewModel.load()
                }
        }
    }
}
