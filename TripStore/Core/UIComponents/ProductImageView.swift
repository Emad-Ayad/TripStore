import SwiftUI
import SDWebImageSwiftUI

struct ProductImageView: View {
    let url: String?
    let width: CGFloat?
    let height: CGFloat?
    
    var body: some View {
        if let url = url, let parsed = URL(string: url) {
            WebImage(url: parsed) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            .frame(width: width, height: height)
            .clipped()
        } else {
            Image(systemName: "photo")
                .frame(width: width, height: height)
                .background(Color.gray.opacity(0.2))
        }
    }
}
