import Foundation

struct CartItem: Identifiable, Codable {
    let id: UUID
    let productId: Int
    let productTitle: String
    let productThumbnail: String
    let price: Double
    var quantity: Int
}

struct Order: Identifiable, Codable {
    let id: UUID
    let items: [CartItem]
    let subtotal: Double
    let serviceFee: Double
    let total: Double
    let timestamp: Date
}
