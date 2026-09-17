import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        TabView {
            CatalogueView(repository: container.productRepository)
                .tabItem { Label("Catalogue", systemImage: "magnifyingglass") }
            
            CartView()
                .tabItem { Label("Cart", systemImage: "cart.fill") }
            
            FavouritesView()
                .tabItem { Label("Favourites", systemImage: "heart.fill") }
            
            OrderHistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
        }
    }
}
