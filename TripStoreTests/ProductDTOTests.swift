//  ProductDTOTests.swift
//  TripStoreTests
//
//  Tests: DTO → Domain mapping and JSON decoding.

import XCTest
@testable import TripStore

final class ProductDTOTests: XCTestCase {

    func test_productDTO_toDomain_returnsNil_whenTitleIsMissing() {
        let dto = ProductDTO(id: 1, title: nil, description: nil,
                             category: nil, price: nil, discountPercentage: nil,
                             rating: nil, stock: nil, brand: nil, thumbnail: nil, images: nil)
        XCTAssertNil(dto.toDomain(), "DTO without title should not produce a domain Product")
    }

    func test_productDTO_toDomain_mapsAllFields() {
        let dto = ProductDTO(
            id: 7, title: "Sneakers", description: "Cool shoes",
            category: "footwear", price: 79.99, discountPercentage: 5.0,
            rating: 4.5, stock: 20, brand: "Nike", thumbnail: "thumb.jpg",
            images: ["a.jpg", "b.jpg"]
        )
        let product = dto.toDomain()!
        XCTAssertEqual(product.id, 7)
        XCTAssertEqual(product.title, "Sneakers")
        XCTAssertEqual(product.category, "footwear")
        XCTAssertEqual(product.price, 79.99, accuracy: 0.001)
        XCTAssertEqual(product.discountPercentage, 5.0)
        XCTAssertEqual(product.rating, 4.5, accuracy: 0.001)
        XCTAssertEqual(product.images.count, 2)
    }

    func test_productDTO_toDomain_fillsDefaultsForNilFields() {
        let dto = ProductDTO(id: 3, title: "Widget", description: nil,
                             category: nil, price: nil, discountPercentage: nil,
                             rating: nil, stock: nil, brand: nil, thumbnail: nil, images: nil)
        let product = dto.toDomain()!
        XCTAssertEqual(product.description, "")
        XCTAssertEqual(product.category, "Uncategorized")
        XCTAssertEqual(product.price, 0.0, accuracy: 0.001)
        XCTAssertEqual(product.rating, 0.0, accuracy: 0.001)
        XCTAssertEqual(product.stock, 0)
        XCTAssertTrue(product.images.isEmpty)
    }

    func test_productListResponseDTO_toDomain_skipsInvalidProducts() {
        let validDTO   = ProductDTO(id: 1, title: "Valid", description: nil,
                                    category: nil, price: 10, discountPercentage: nil,
                                    rating: nil, stock: nil, brand: nil, thumbnail: nil, images: nil)
        let invalidDTO = ProductDTO(id: 2, title: nil, description: nil,
                                    category: nil, price: nil, discountPercentage: nil,
                                    rating: nil, stock: nil, brand: nil, thumbnail: nil, images: nil)
        let listDTO = ProductListResponseDTO(
            products: [validDTO, invalidDTO], total: 2, skip: 0, limit: 20
        )
        let result = listDTO.toDomain()
        XCTAssertEqual(result.items.count, 1, "Only valid DTOs should be mapped to domain")
        XCTAssertEqual(result.total, 2)
    }

    func test_paginatedResult_hasMore_isTrueWhenMoreItemsExist() {
        let result = PaginatedResult<Product>(items: [], total: 50, skip: 0, limit: 20)
        XCTAssertTrue(result.hasMore, "0+20 < 50 so hasMore should be true")
    }

    func test_paginatedResult_hasMore_isFalseWhenExhausted() {
        let result = PaginatedResult<Product>(items: [], total: 20, skip: 0, limit: 20)
        XCTAssertFalse(result.hasMore, "0+20 == 20, no more pages")
    }
}
