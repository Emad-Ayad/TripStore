import Foundation
struct CurrencyFormatter {
    static func format(_ value: Double) -> String {
        return "$\(String(format: "%.2f", value))"
    }
}
