import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    var body: some View {
        VStack {
            Text("Error").font(.headline)
            Text(message).font(.subheadline)
            Button("Retry", action: retryAction).padding()
        }
    }
}
