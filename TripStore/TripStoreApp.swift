import SwiftUI

@main
struct TripStoreApp: App {
    @StateObject private var container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            AppTabView().environmentObject(container)
        }
    }
}
