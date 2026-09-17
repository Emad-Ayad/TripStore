import SwiftUI
import Combine

@MainActor
final class DependencyContainer: ObservableObject {
    let networkService: NetworkServiceProtocol
    let cacheService: CacheService
    let productRepository: ProductRepositoryProtocol
    let favouriteRepository: FavouriteRepositoryProtocol
    let favouritesManager: FavouritesManager
    
    init() {
        self.networkService = NetworkService()
        self.cacheService = CacheService()
        self.productRepository = ProductRepository(networkService: networkService, cacheService: cacheService)
        self.favouriteRepository = FavouriteRepository()
        self.favouritesManager = FavouritesManager(repository: favouriteRepository)
    }
}
