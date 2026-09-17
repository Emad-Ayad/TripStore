import SwiftUI

struct FilterSortSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedCategory: String?
    @Binding var minimumRating: Double
    @Binding var sortOption: SortOption
    let availableCategories: [String]
    let onApply: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort")) {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Filter by Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(String?.none)
                        ForEach(availableCategories, id: \.self) { category in
                            Text(category.capitalized).tag(String?(category))
                        }
                    }
                }
                
                Section(header: Text("Minimum Rating: \(String(format: "%.1f", minimumRating))")) {
                    Slider(value: $minimumRating, in: 0...5, step: 0.5)
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarItems(
                leading: Button("Reset") {
                    onReset()
                    dismiss()
                },
                trailing: Button("Apply") {
                    onApply()
                    dismiss()
                }
            )
        }
    }
}
