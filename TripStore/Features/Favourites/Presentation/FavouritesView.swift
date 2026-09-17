import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    var body: some View {
        NavigationView {
            Group {
                if favouritesManager.favouriteProducts.isEmpty {
                    EmptyStateView(title: "No Favourites Yet", message: "Tap the heart icon on any product to save it here.", iconName: "heart.slash")
                } else {
                    List {
                        ForEach(favouritesManager.favouriteProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductRowView(product: product)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favourites")
        }
    }
}
