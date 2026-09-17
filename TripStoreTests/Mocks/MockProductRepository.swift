//  MockProductRepository.swift
//  TripStoreTests

import Foundation
@testable import TripStore

/// Controllable test-double for ProductRepositoryProtocol.
final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {

    // MARK: Spy state
    private(set) var fetchProductsCallCount = 0
    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?

    // MARK: Stubbable responses
    var stubbedProducts: PaginatedResult<Product> = .empty
    var stubbedSearchResult: PaginatedResult<Product> = .empty
    var stubbedCategories: [String] = []
    var stubbedError: Error?
    var delay: Duration?

    // MARK: ProductRepositoryProtocol
    var isShowingCachedData: Bool = false

    func fetchProducts(skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        fetchProductsCallCount += 1
        if let d = delay { try await Task.sleep(for: d) }
        if let e = stubbedError { throw e }
        return stubbedProducts
    }

    func searchProducts(query: String, skip: Int, limit: Int) async throws -> PaginatedResult<Product> {
        searchCallCount += 1
        lastSearchQuery = query
        if let d = delay { try await Task.sleep(for: d) }
        if let e = stubbedError { throw e }
        return stubbedSearchResult
    }

    func fetchProductsByCategory(_ category: String, skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        if let d = delay { try await Task.sleep(for: d) }
        if let e = stubbedError { throw e }
        return stubbedProducts
    }

    func fetchCategories() async throws -> [String] {
        if let e = stubbedError { throw e }
        return stubbedCategories
    }
}

// MARK: - Helpers

extension PaginatedResult where T == Product {
    static var empty: PaginatedResult<Product> {
        PaginatedResult(items: [], total: 0, skip: 0, limit: 20)
    }
    static func of(_ products: [Product], total: Int? = nil) -> PaginatedResult<Product> {
        PaginatedResult(items: products, total: total ?? products.count, skip: 0, limit: 20)
    }
}

extension Product {
    static func stub(
        id: Int = 1,
        title: String = "Test Product",
        category: String = "electronics",
        price: Double = 100.0,
        discountPercentage: Double? = nil,
        rating: Double = 4.0,
        stock: Int = 10
    ) -> Product {
        Product(
            id: id, title: title, description: "Stub description",
            category: category, price: price,
            discountPercentage: discountPercentage, rating: rating,
            stock: stock, brand: "TestBrand", thumbnail: nil, images: []
        )
    }
}
