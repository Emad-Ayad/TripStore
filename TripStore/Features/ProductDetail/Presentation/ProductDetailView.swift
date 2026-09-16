import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !product.images.isEmpty {
                    ImageGalleryView(images: product.images)
                } else {
                    ProductImageView(url: product.thumbnail, width: nil, height: 300)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            // TODO: favourite
                        }) {
                            Image(systemName: "heart")
                                .foregroundColor(.secondary)
                                .imageScale(.large)
                        }
                    }
                    
                    if let brand = product.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        RatingView(rating: product.rating)
                        Spacer()
                        Text(product.isInStock ? "In Stock (\(product.stock))" : "Out of Stock")
                            .foregroundColor(product.isInStock ? .green : .red)
                            .font(.subheadline)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(CurrencyFormatter.format(product.discountedPrice))
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let discount = product.discountPercentage, discount > 0 {
                            Text(CurrencyFormatter.format(product.price))
                                .strikethrough()
                                .foregroundColor(.secondary)
                            Text("-\(String(format: "%.1f", discount))%")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Divider()
                    
                    Text("Description")
                        .font(.headline)
                    Text(product.description)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                // TODO: Order product
            }) {
                Text("Order Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(product.isInStock ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!product.isInStock)
            .padding()
            .background(Color(UIColor.systemBackground).shadow(radius: 2, y: -2))
        }
    }
}
