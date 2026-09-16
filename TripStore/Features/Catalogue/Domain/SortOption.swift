import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case none = "Default"
    case priceAsc = "Price (Low to High)"
    case priceDesc = "Price (High to Low)"
    case ratingDesc = "Rating (Highest)"
    
    var id: String { rawValue }
    
    var apiValue: (sortBy: String, order: String)? {
        switch self {
        case .none: return nil
        case .priceAsc: return ("price", "asc")
        case .priceDesc: return ("price", "desc")
        case .ratingDesc: return ("rating", "desc")
        }
    }
}
