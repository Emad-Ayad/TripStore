import SwiftUI

struct CartView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Group {
                if orderViewModel.cartItems.isEmpty {
                    EmptyStateView(title: "Your Cart is Empty", message: "Add some products to your cart to see them here.", iconName: "cart")
                } else {
                    VStack(spacing: 0) {
                        List {
                            ForEach($orderViewModel.cartItems) { $item in
                                HStack {
                                    ProductImageView(url: item.productThumbnail, width: 50, height: 50).cornerRadius(8)
                                    VStack(alignment: .leading) {
                                        Text(item.productTitle).font(.headline).lineLimit(1)
                                        Text(CurrencyFormatter.format(item.price)).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Stepper("\(item.quantity)", value: $item.quantity, in: 1...99)
                                        .labelsHidden()
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let item = orderViewModel.cartItems[index]
                                    orderViewModel.removeFromCart(productId: item.productId)
                                }
                            }
                        }
                        .listStyle(.plain)
                        
                        checkoutFooter
                    }
                }
            }
            .navigationTitle("Cart")
            .alert("Order Successful!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your order has been placed successfully.")
            }
        }
    }
    
    private var checkoutFooter: some View {
        VStack(spacing: 12) {
            HStack { Text("Subtotal"); Spacer(); Text(CurrencyFormatter.format(orderViewModel.subtotal)) }
            HStack { Text("Service Fee (5%)"); Spacer(); Text(CurrencyFormatter.format(orderViewModel.serviceFee)) }
            Divider()
            HStack { 
                Text("Total").font(.title3).fontWeight(.bold)
                Spacer()
                Text(CurrencyFormatter.format(orderViewModel.total)).font(.title3).fontWeight(.bold)
            }
            
            Button(action: submitOrder) {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Checkout")
                            .font(.headline)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isSubmitting)
        }
        .padding()
        .background(Color(UIColor.systemBackground).shadow(radius: 4, y: -2))
    }
    
    private func submitOrder() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await orderViewModel.placeOrder()
            isSubmitting = false
            showSuccess = true
        }
    }
}
