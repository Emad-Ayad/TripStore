import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        TabView {
            CatalogueView(repository: container.productRepository)
                .tabItem { Label("Catalogue", systemImage: "magnifyingglass") }
            
            FavouritesView()
                .tabItem { Label("Favourites", systemImage: "heart.fill") }
        }
    }
}
