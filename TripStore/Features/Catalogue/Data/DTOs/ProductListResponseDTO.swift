import Foundation

struct ProductListResponseDTO: Codable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
    
    func toDomain() -> PaginatedResult<Product> {
        let validProducts = products.compactMap { $0.toDomain() }
        return PaginatedResult(items: validProducts, total: total, skip: skip, limit: limit)
    }
}
