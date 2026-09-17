import SwiftUI

struct StaleBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "icloud.slash")
                .foregroundColor(.orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Offline Mode")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("Pull down to refresh data.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}
