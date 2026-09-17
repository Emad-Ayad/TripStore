import SwiftUI
import SDWebImageSwiftUI

struct ImageGalleryView: View {
    let images: [String]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { urlString in
                if let url = URL(string: urlString) {
                    WebImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
        .background(Color(UIColor.secondarySystemBackground))
    }
}
