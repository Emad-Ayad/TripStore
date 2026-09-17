import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if orderViewModel.orders.isEmpty {
                    EmptyStateView(title: "No Orders Yet", message: "When you place an order, it will appear here.", iconName: "bag")
                } else {
                    List {
                        ForEach(orderViewModel.orders) { order in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text("Order #\(order.id.uuidString.prefix(6))").font(.headline)
                                        Text("\(order.items.count) items • \(CurrencyFormatter.format(order.total))").font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(order.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(order.items.map { "\($0.quantity)x \($0.productTitle)" }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Order History")
        }
    }
}
