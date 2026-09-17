import Foundation

enum APIEndpoint {
    case products(skip: Int, limit: Int, sortBy: String?, order: String?)
    case searchProducts(query: String, skip: Int, limit: Int)
    case productsByCategory(category: String, skip: Int, limit: Int, sortBy: String?, order: String?)
    case categoryList
    
    var urlRequest: URLRequest? {
        var urlString = "https://dummyjson.com/products"
        var queryItems: [URLQueryItem] = []
        
        switch self {
            
        case .products(let skip, let limit, let sortBy, let order):
            queryItems += [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "skip", value: "\(skip)")]
            if let s = sortBy, let o = order { queryItems += [URLQueryItem(name: "sortBy", value: s), URLQueryItem(name: "order", value: o)] }
            
        case .searchProducts(let query, let skip, let limit):
            urlString += "/search"
            queryItems += [URLQueryItem(name: "q", value: query), URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "skip", value: "\(skip)")]
            
        case .productsByCategory(let category, let skip, let limit, let sortBy, let order):
            urlString += "/category/\(category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? category)"
            queryItems += [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "skip", value: "\(skip)")]
            if let s = sortBy, let o = order { queryItems += [URLQueryItem(name: "sortBy", value: s), URLQueryItem(name: "order", value: o)] }
            
        case .categoryList:
            urlString += "/category-list"
        }
        
        guard var comps = URLComponents(string: urlString) else { return nil }
        if !queryItems.isEmpty { comps.queryItems = queryItems }
        guard let url = comps.url else { return nil }
        return URLRequest(url: url)
    }
}
