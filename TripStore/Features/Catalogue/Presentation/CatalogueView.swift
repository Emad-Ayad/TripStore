import SwiftUI

struct CatalogueView: View {
    @StateObject private var viewModel: CatalogueViewModel
    
    init(repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CatalogueViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isShowingStaleData { StaleBanner() }
                content
            }
            .navigationTitle("TripStore")
        }
        .task { await viewModel.loadInitial() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading: ProgressView()
        case .empty: ErrorView(message: "No products", retryAction: { Task { await viewModel.refresh() } })
        case .error(let msg): ErrorView(message: msg, retryAction: { Task { await viewModel.refresh() } })
        case .loaded:
            List {
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
