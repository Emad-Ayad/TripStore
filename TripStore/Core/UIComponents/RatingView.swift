import SwiftUI

struct RatingView: View {
    let rating: Double
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill").foregroundColor(.orange)
            Text(String(format: "%.1f", rating)).font(.caption)
        }
    }
}
