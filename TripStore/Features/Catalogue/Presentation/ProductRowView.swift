import SwiftUI

struct ProductRowView: View {
    let product: Product
    var body: some View {
        HStack {
            ProductImageView(url: product.thumbnail, width: 60, height: 60).cornerRadius(8)
            VStack(alignment: .leading) {
                Text(product.title).font(.headline)
                Text(product.category).font(.caption).foregroundColor(.secondary)
                RatingView(rating: product.rating)
                Text(CurrencyFormatter.format(product.discountedPrice)).font(.subheadline).bold()
            }
        }
    }
}
