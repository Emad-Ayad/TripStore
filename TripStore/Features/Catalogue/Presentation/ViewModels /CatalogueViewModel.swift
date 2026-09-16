import Foundation
import Combine

@MainActor
final class CatalogueViewModel: ObservableObject {
    enum State { case loading, loaded, empty, error(String) }
    
    @Published var state: State = .loading
    @Published var products: [Product] = []
    @Published var isShowingStaleData = false
    
    private let repository: ProductRepositoryProtocol
    private var skip = 0
    private let limit = 20
    private var hasMore = true
    
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadInitial() async {
        guard products.isEmpty else { return }
        await fetchProducts(reset: true)
    }
    
    func refresh() async {
        await fetchProducts(reset: true)
    }
    
    func loadMore(currentItem item: Product) async {
        guard let last = products.last, last.id == item.id, hasMore else { return }
        await fetchProducts(reset: false)
    }
    
    private func fetchProducts(reset: Bool) async {
        if reset {
            skip = 0
            hasMore = true
        }
        
        do {
            let result = try await repository.fetchProducts(skip: skip, limit: limit, sortBy: .none)
            if reset { products = result.items } else { products.append(contentsOf: result.items) }
            skip += limit
            hasMore = result.hasMore
            isShowingStaleData = repository.isShowingCachedData
            state = products.isEmpty ? .empty : .loaded
        } catch {
            if products.isEmpty { state = .error(error.localizedDescription) }
            isShowingStaleData = repository.isShowingCachedData
        }
    }
}
