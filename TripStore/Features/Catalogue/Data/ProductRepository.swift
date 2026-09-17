import Foundation

final class ProductRepository: ProductRepositoryProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheService
    
    private let lock = NSLock()
    private var _isShowingCachedData = false
    
    var isShowingCachedData: Bool {
        lock.withLock { _isShowingCachedData }
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService(), cacheService: CacheService = CacheService()) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchProducts(skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        return try await fetchWithCache(endpoint: .products(skip: skip, limit: limit, sortBy: sortBy?.apiValue?.sortBy, order: sortBy?.apiValue?.order), cacheKey: "products_\(skip)_\(limit)_\(sortBy?.rawValue ?? "")")
    }
    
    func searchProducts(query: String, skip: Int, limit: Int) async throws -> PaginatedResult<Product> {
        return try await fetchWithCache(endpoint: .searchProducts(query: query, skip: skip, limit: limit), cacheKey: "search_\(query)_\(skip)_\(limit)")
    }
    
    func fetchProductsByCategory(_ category: String, skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        return try await fetchWithCache(endpoint: .productsByCategory(category: category, skip: skip, limit: limit, sortBy: sortBy?.apiValue?.sortBy, order: sortBy?.apiValue?.order), cacheKey: "cat_\(category)_\(skip)_\(limit)_\(sortBy?.rawValue ?? "")")
    }
    
    func fetchCategories() async throws -> [String] {
        if let request = APIEndpoint.categoryList.urlRequest {
            return try await networkService.request(urlRequest: request)
        }
        return []
    }
    
    private func fetchWithCache(endpoint: APIEndpoint, cacheKey: String) async throws -> PaginatedResult<Product> {
        guard let request = endpoint.urlRequest else { throw APIError.invalidURL }
        do {
            let response: ProductListResponseDTO = try await networkService.request(urlRequest: request)
            await cacheService.save(response, forKey: cacheKey)
            lock.withLock { _isShowingCachedData = false }
            return response.toDomain()
        } catch {
            if let cached = await cacheService.load(forKey: cacheKey) as (ProductListResponseDTO, Bool)? {
                lock.withLock { _isShowingCachedData = true }
                return cached.0.toDomain()
            }
            lock.withLock { _isShowingCachedData = false }
            throw error
        }
    }
}
