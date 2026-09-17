import SwiftUI

struct CatalogueView: View {
    @StateObject private var viewModel: CatalogueViewModel
    
    init(repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CatalogueViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationView {
            content
            .navigationTitle("TripStore")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.isShowingFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingFilterSheet) {
                FilterSortSheet(
                    selectedCategory: $viewModel.selectedCategory,
                    minimumRating: $viewModel.minimumRating,
                    sortOption: $viewModel.sortOption,
                    availableCategories: viewModel.availableCategories,
                    onApply: { viewModel.applyFilters() },
                    onReset: { viewModel.resetFilters() }
                )
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search products...")
        .task { await viewModel.loadInitial() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading: ProgressView()
        case .empty: ErrorView(message: "No products match your criteria.", retryAction: { Task { await viewModel.refresh() } })
        case .error(let msg): ErrorView(message: msg, retryAction: { Task { await viewModel.refresh() } })
        case .loaded:
            List {
                if viewModel.isShowingStaleData {
                    StaleBanner()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                ForEach(viewModel.products) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductRowView(product: product)
                            .onAppear { Task { await viewModel.loadMore(currentItem: product) } }
                    }
                }
            }
            .refreshable { await viewModel.refresh() }
        }
    }
}
