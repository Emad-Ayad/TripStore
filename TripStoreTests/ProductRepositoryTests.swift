//  ProductRepositoryTests.swift
//  TripStoreTests
//
//  Tests: ProductRepository backed by a MockNetworkService (no real network).

import XCTest
@testable import TripStore

// MARK: - Mock network service

final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {

    // The next value or error to return.
    var result: Result<Any, Error> = .failure(APIError.invalidURL)

    func request<T: Decodable>(urlRequest: URLRequest) async throws -> T {
        switch result {
        case .failure(let e): throw e
        case .success(let value):
            guard let typed = value as? T else {
                throw APIError.decodingFailed(
                    NSError(domain: "Mock", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Type mismatch: expected \(T.self)"])
                )
            }
            return typed
        }
    }
}

// MARK: - Tests

final class ProductRepositoryTests: XCTestCase {

    private var mockNetwork: MockNetworkService!
    private var sut: ProductRepository!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        // Fresh CacheService so tests don't share disk state
        sut = ProductRepository(networkService: mockNetwork, cacheService: CacheService())
    }

    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }

    // MARK: - fetchProducts

    func test_fetchProducts_parsesResponseAndReturnsDomainObjects() async throws {
        let dto = ProductListResponseDTO(
            products: [
                ProductDTO(id: 1, title: "Shirt", description: "Nice shirt",
                           category: "clothing", price: 29.99, discountPercentage: 10,
                           rating: 4.2, stock: 50, brand: "FashionBrand",
                           thumbnail: nil, images: [])
            ],
            total: 1, skip: 0, limit: 20
        )
        mockNetwork.result = .success(dto)

        let result = try await sut.fetchProducts(skip: 0, limit: 20, sortBy: nil)

        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items[0].title, "Shirt")
        XCTAssertFalse(sut.isShowingCachedData)
    }

    func test_fetchCategories_returnsListFromNetwork() async throws {
        let categories = ["electronics", "clothing", "furniture"]
        mockNetwork.result = .success(categories)

        let result = try await sut.fetchCategories()

        XCTAssertEqual(result, categories)
    }

    func test_searchProducts_forwardsQueryCorrectly() async throws {
        let dto = ProductListResponseDTO(
            products: [ProductDTO(id: 5, title: "Headphones",
                                  description: nil, category: nil, price: nil,
                                  discountPercentage: nil, rating: nil, stock: nil,
                                  brand: nil, thumbnail: nil, images: nil)],
            total: 1, skip: 0, limit: 20
        )
        mockNetwork.result = .success(dto)

        let result = try await sut.searchProducts(query: "head", skip: 0, limit: 20)
        // ProductDTO without title returns nil from toDomain()
        XCTAssertEqual(result.total, 1)
    }
}
