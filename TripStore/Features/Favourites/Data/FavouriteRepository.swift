import Foundation

final class FavouriteRepository: FavouriteRepositoryProtocol, @unchecked Sendable {
    private let store: FavouriteStore
    
    init(store: FavouriteStore = FavouriteStore()) {
        self.store = store
    }
    
    func allFavourites() async -> [Product] {
        await store.allFavourites()
    }
    
    func add(_ product: Product) async {
        await store.add(product)
    }
    
    func remove(id: Int) async {
        await store.remove(id: id)
    }
}
