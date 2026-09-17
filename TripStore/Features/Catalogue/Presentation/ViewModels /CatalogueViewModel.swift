import Foundation
import Combine

@MainActor
final class CatalogueViewModel: ObservableObject {
    enum State { case loading, loaded, empty, error(String) }
    
    @Published var state: State = .loading
    @Published var products: [Product] = []
    @Published var isShowingStaleData = false
    

    @Published var searchQuery = ""
    @Published var selectedCategory: String? = nil
    @Published var minimumRating: Double = 0.0
    @Published var sortOption: SortOption = .none
    
    @Published var availableCategories: [String] = []
    @Published var isShowingFilterSheet = false
    
    private let repository: ProductRepositoryProtocol
    private var skip = 0
    private let limit = 20
    private var hasMore = true
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
        
        $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { await self?.fetchProducts(reset: true) }
            }
            .store(in: &cancellables)
    }
    
    func loadInitial() async {
        guard products.isEmpty else { return }
        async let fetchCats: () = fetchCategories()
        async let fetchProds: () = fetchProducts(reset: true)
        _ = await (fetchCats, fetchProds)
    }
    
    func refresh() async {
        await fetchProducts(reset: true)
    }
    
    func loadMore(currentItem item: Product) async {
        guard let last = products.last, last.id == item.id, hasMore else { return }
        await fetchProducts(reset: false)
    }
    
    func resetFilters() {
        searchQuery = ""
        selectedCategory = nil
        minimumRating = 0.0
        sortOption = .none
        Task { await fetchProducts(reset: true) }
    }
    
    func applyFilters() {
        Task { await fetchProducts(reset: true) }
    }
    
    private func fetchCategories() async {
        if let cats = try? await repository.fetchCategories() {
            self.availableCategories = cats
        }
    }
    
    private func fetchProducts(reset: Bool) async {
        if reset {
            skip = 0
            hasMore = true
            state = .loading
        }
        
        do {
            let result: PaginatedResult<Product>
            let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            

            if !query.isEmpty {
                result = try await repository.searchProducts(query: query, skip: skip, limit: limit)
            } else if let category = selectedCategory {
                result = try await repository.fetchProductsByCategory(category, skip: skip, limit: limit, sortBy: sortOption)
            } else {
                result = try await repository.fetchProducts(skip: skip, limit: limit, sortBy: sortOption)
            }
            

            var filteredItems = result.items
            
            if !query.isEmpty {
                if let cat = selectedCategory {
                    filteredItems = filteredItems.filter { $0.category == cat }
                }
                
                if sortOption != .none {
                    filteredItems.sort { a, b in
                        switch sortOption {
                        case .priceAsc: return a.discountedPrice < b.discountedPrice
                        case .priceDesc: return a.discountedPrice > b.discountedPrice
                        case .ratingDesc: return a.rating > b.rating
                        default: return false
                        }
                    }
                }
            }
            

            if minimumRating > 0 {
                filteredItems = filteredItems.filter { $0.rating >= minimumRating }
            }
            
            if reset {
                products = filteredItems
            } else {
                products.append(contentsOf: filteredItems)
            }
            
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
