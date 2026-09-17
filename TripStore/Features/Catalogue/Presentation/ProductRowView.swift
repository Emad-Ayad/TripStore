import SwiftUI

struct ProductRowView: View {
    let product: Product
    @EnvironmentObject var favouritesManager: FavouritesManager
    var body: some View {
        HStack {
            ProductImageView(url: product.thumbnail, width: 60, height: 60).cornerRadius(8)
            VStack(alignment: .leading) {
                Text(product.title).font(.headline)
                Text(product.category).font(.caption).foregroundColor(.secondary)
                RatingView(rating: product.rating)
                HStack {
                    Text(CurrencyFormatter.format(product.discountedPrice)).font(.subheadline).bold()

                    Spacer()
                    Button(action: { favouritesManager.toggleFavourite(product: product) }) {
                        Image(systemName: favouritesManager.isFavourite(id: product.id) ? "heart.fill" : "heart")
                            .foregroundColor(favouritesManager.isFavourite(id: product.id) ? .red : .secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                
                }
            }
        }
    }
}
