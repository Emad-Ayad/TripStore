import Foundation

struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
}

actor CacheService {
    private let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("TripStoreCache")
    
    init() {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }
    
    func save<T: Codable>(_ data: T, forKey key: String) {
        let entry = CacheEntry(data: data, timestamp: Date())
        let safeKey = Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
        let url = cacheDir.appendingPathComponent("\(safeKey).json")
        try? JSONEncoder().encode(entry).write(to: url, options: .atomic)
    }
    
    func load<T: Codable>(forKey key: String) -> (data: T, isStale: Bool)? {
        let safeKey = Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
        let url = cacheDir.appendingPathComponent("\(safeKey).json")
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data) else { return nil }
        let isStale = Date().timeIntervalSince(entry.timestamp) > 300
        return (entry.data, isStale)
    }
}
