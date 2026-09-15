import SwiftUI
struct StaleBanner: View {
    var body: some View {
        Text("Showing cached data. Pull to refresh.")
            .font(.footnote).padding().background(Color.yellow.opacity(0.3))
    }
}
