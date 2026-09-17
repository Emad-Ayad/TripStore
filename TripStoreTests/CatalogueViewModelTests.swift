//  CatalogueViewModelTests.swift
//  TripStoreTests
//
//  Tests: loading/loaded/empty/error state paths, search, filter, sort.

import XCTest
@testable import TripStore

@MainActor
final class CatalogueViewModelTests: XCTestCase {

    private var mockRepo: MockProductRepository!
    private var sut: CatalogueViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockProductRepository()
        sut = CatalogueViewModel(repository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - State paths

    func test_loadInitial_transitionsToLoadedState_whenProductsReturned() async {
        mockRepo.stubbedProducts = .of([.stub(id: 1), .stub(id: 2)])
        await sut.loadInitial()
        guard case .loaded = sut.state else {
            XCTFail("Expected .loaded, got \(sut.state)")
            return
        }
        XCTAssertEqual(sut.products.count, 2)
    }

    func test_loadInitial_transitionsToEmptyState_whenNoProductsReturned() async {
        mockRepo.stubbedProducts = .empty
        await sut.loadInitial()
        guard case .empty = sut.state else {
            XCTFail("Expected .empty, got \(sut.state)")
            return
        }
        XCTAssertTrue(sut.products.isEmpty)
    }

    func test_loadInitial_transitionsToErrorState_whenRepositoryThrows() async {
        mockRepo.stubbedError = APIError.invalidURL
        await sut.loadInitial()
        guard case .error = sut.state else {
            XCTFail("Expected .error, got \(sut.state)")
            return
        }
    }

    func test_refresh_replacesProductList() async {
        mockRepo.stubbedProducts = .of([.stub(id: 1)])
        await sut.loadInitial()
        mockRepo.stubbedProducts = .of([.stub(id: 2), .stub(id: 3)])
        await sut.refresh()
        XCTAssertEqual(sut.products.count, 2)
        XCTAssertEqual(sut.products.map(\.id), [2, 3])
    }


    func test_resetFilters_clearsAllFiltersAndReloads() async {
        mockRepo.stubbedProducts = .of([.stub()])
        sut.searchQuery = "phone"
        sut.selectedCategory = "mobiles"
        sut.minimumRating = 3.0
        sut.sortOption = .priceDesc
        sut.resetFilters()
        // Give the Task spawned by resetFilters a moment to run
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertNil(sut.selectedCategory)
        XCTAssertEqual(sut.minimumRating, 0.0)
        XCTAssertEqual(sut.sortOption, .none)
    }

    // MARK: - Stale-data flag

    func test_isShowingStaleData_reflectsRepositoryFlag_afterLoad() async {
        mockRepo.isShowingCachedData = true
        mockRepo.stubbedProducts = .of([.stub()])
        await sut.loadInitial()
        XCTAssertTrue(sut.isShowingStaleData)
    }
}
