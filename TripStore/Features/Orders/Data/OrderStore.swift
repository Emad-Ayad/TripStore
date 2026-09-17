import Foundation

actor OrderStore {
    private let fileURL: URL
    private var cachedOrders: [Order]?
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("orders.json")
    }
    
    func allOrders() -> [Order] {
        if let cached = cachedOrders { return cached }
        guard let data = try? Data(contentsOf: fileURL),
              let items = try? JSONDecoder().decode([Order].self, from: data) else {
            cachedOrders = []
            return []
        }
        cachedOrders = items
        return items
    }
    
    func add(_ order: Order) {
        var items = allOrders()
        items.insert(order, at: 0)
        save(items)
    }
    
    private func save(_ items: [Order]) {
        cachedOrders = items
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
