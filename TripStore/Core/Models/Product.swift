import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double?
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String?
    let images: [String]
    
    var isInStock: Bool { stock > 0 }
    var discountedPrice: Double {
        guard let discount = discountPercentage, discount > 0 else { return price }
        return price * (1 - (discount / 100.0))
    }
}
