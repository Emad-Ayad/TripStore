import Foundation
import Combine

@MainActor
final class FavouritesManager: ObservableObject {
    @Published private(set) var favouriteIDs: Set<Int> = []
    @Published private(set) var favouriteProducts: [Product] = []
    
    private let repository: FavouriteRepositoryProtocol
    
    init(repository: FavouriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() async {
        let items = await repository.allFavourites()
        self.favouriteProducts = items
        self.favouriteIDs = Set(items.map { $0.id })
    }
    
    func isFavourite(id: Int) -> Bool {
        favouriteIDs.contains(id)
    }
    
    func toggleFavourite(product: Product) {
        Task {
            if isFavourite(id: product.id) {
                await repository.remove(id: product.id)
            } else {
                await repository.add(product)
            }
            await load()
        }
    }
}
