import Foundation

protocol FavouriteRepositoryProtocol: Sendable {
    func allFavourites() async -> [Product]
    func add(_ product: Product) async
    func remove(id: Int) async
}
