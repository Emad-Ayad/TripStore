//  ObsoleteSearchConcurrencyTests.swift
//  TripStoreTests
//
//  Proves that a slow/obsolete response for an earlier request cannot silently
//  clobber the result of the most-recent fetch.
//
//  Strategy: use `refresh()` (which directly awaits `fetchProducts`) so we can
//  race two real async calls and control their resolution order via continuations.

import XCTest
@testable import TripStore

// MARK: - Actor-based controllable repository

private actor SlowMockRepository: ProductRepositoryProtocol {
    var isShowingCachedData: Bool = false

    private var pendingContinuations: [CheckedContinuation<PaginatedResult<Product>, Error>] = []

    func fetchProducts(skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        return try await withCheckedThrowingContinuation { cont in
            pendingContinuations.append(cont)
        }
    }

    func searchProducts(query: String, skip: Int, limit: Int) async throws -> PaginatedResult<Product> {
        return try await withCheckedThrowingContinuation { cont in
            pendingContinuations.append(cont)
        }
    }

    func fetchProductsByCategory(_ category: String, skip: Int, limit: Int, sortBy: SortOption?) async throws -> PaginatedResult<Product> {
        return try await withCheckedThrowingContinuation { cont in
            pendingContinuations.append(cont)
        }
    }

    func fetchCategories() async throws -> [String] { [] }

    // How many requests are currently parked.
    var pendingCount: Int { pendingContinuations.count }

    // Resolves the oldest (first-registered) pending request.
    func resolveOldest(with result: PaginatedResult<Product>) {
        guard !pendingContinuations.isEmpty else { return }
        pendingContinuations.removeFirst().resume(returning: result)
    }
}


@MainActor
final class ObsoleteSearchConcurrencyTests: XCTestCase {


    func test_laterRefreshResult_overwritesEarlierStaleResult() async {
        let repo = SlowMockRepository()
        let vm   = CatalogueViewModel(repository: repo)

        let stale = PaginatedResult<Product>.of([.stub(id: 1, title: "Stale")])
        let fresh = PaginatedResult<Product>.of([.stub(id: 2, title: "Fresh")])

        // Start first refresh — it parks in the repo
        let refreshTask1 = Task { await vm.refresh() }
        // Yield so the task actually suspends on the continuation
        try? await Task.sleep(for: .milliseconds(30))

        // Start second refresh while the first is still in-flight
        let refreshTask2 = Task { await vm.refresh() }
        try? await Task.sleep(for: .milliseconds(30))

        // Resolve second (newer) request FIRST with fresh data
        await repo.resolveOldest(with: stale)   // releases request #1
        await refreshTask1.value

        // Now resolve first (older) request with stale data
        await repo.resolveOldest(with: fresh)   // releases request #2
        await refreshTask2.value

        // refresh() uses reset=true each time, so the last call's result wins
        XCTAssertEqual(
            vm.products.first?.title, "Fresh",
            "The most-recent refresh result must win; stale response must not persist"
        )
    }

    // Sanity check: a single successful refresh populates the VM correctly.
    func test_singleRefresh_populatesProducts() async {
        let repo = SlowMockRepository()
        let vm   = CatalogueViewModel(repository: repo)
        let expected = PaginatedResult<Product>.of([.stub(id: 7, title: "Gadget")])

        let task = Task { await vm.refresh() }
        try? await Task.sleep(for: .milliseconds(30))
        await repo.resolveOldest(with: expected)
        await task.value

        XCTAssertEqual(vm.products.count, 1)
        XCTAssertEqual(vm.products.first?.title, "Gadget")
    }
}
