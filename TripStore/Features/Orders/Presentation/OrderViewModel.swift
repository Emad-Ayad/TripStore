import Foundation
import Combine

@MainActor
final class OrderViewModel: ObservableObject {
    @Published private(set) var orders: [Order] = []
    @Published var cartItems: [CartItem] = []
    
    private let store = OrderStore()
    
    var subtotal: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    var serviceFee: Double { subtotal * 0.05 }
    var total: Double { subtotal + serviceFee }
    
    func load() async {
        self.orders = await store.allOrders()
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.productId == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            let item = CartItem(
                id: UUID(),
                productId: product.id,
                productTitle: product.title,
                productThumbnail: product.thumbnail ?? "",
                price: product.discountedPrice,
                quantity: quantity
            )
            cartItems.append(item)
        }
    }
    
    func removeFromCart(productId: Int) {
        cartItems.removeAll { $0.productId == productId }
    }
    
    func placeOrder() async {
        guard !cartItems.isEmpty else { return }
        
        let order = Order(
            id: UUID(),
            items: cartItems,
            subtotal: subtotal,
            serviceFee: serviceFee,
            total: total,
            timestamp: Date()
        )
        
        await store.add(order)
        cartItems.removeAll()
        await load()
    }
}
