import Foundation

struct PaginatedResult<T> {
    let items: [T]
    let total: Int
    let skip: Int
    let limit: Int
    var hasMore: Bool { skip + limit < total }
}
