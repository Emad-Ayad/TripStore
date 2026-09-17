import Foundation

struct ProductDTO: Codable {
    let id: Int
    let title: String?
    let description: String?
    let category: String?
    let price: Double?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let brand: String?
    let thumbnail: String?
    let images: [String]?
    
    func toDomain() -> Product? {
        guard let title = title else { return nil }
        return Product(
            id: id, title: title, description: description ?? "",
            category: category ?? "Uncategorized", price: price ?? 0.0,
            discountPercentage: discountPercentage, rating: rating ?? 0.0,
            stock: stock ?? 0, brand: brand, thumbnail: thumbnail,
            images: images ?? []
        )
    }
}
