import Foundation

protocol ProductRepositoryProtocol: Sendable {
    var isShowingCachedData: Bool { get }
    
    func fetchProducts(skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product>
    
    func searchProducts(query: String, skip: Int, limit: Int) async throws -> PaginatedResult<Product>
    
    func fetchProductsByCategory(_ category: String, skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product>
    
    func fetchCategories() async throws -> [String]
    
}
