import Foundation

actor FavouriteStore {
    private let fileURL: URL
    private var cachedFavourites: [Product]?
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("favourites.json")
    }
    
    func allFavourites() -> [Product] {
        if let cached = cachedFavourites { return cached }
        guard let data = try? Data(contentsOf: fileURL),
              let items = try? JSONDecoder().decode([Product].self, from: data) else {
            cachedFavourites = []
            return []
        }
        cachedFavourites = items
        return items
    }
    
    func add(_ product: Product) {
        var items = allFavourites()
        if !items.contains(where: { $0.id == product.id }) {
            items.append(product)
            save(items)
        }
    }
    
    func remove(id: Int) {
        var items = allFavourites()
        items.removeAll { $0.id == id }
        save(items)
    }
    
    private func save(_ items: [Product]) {
        cachedFavourites = items
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
