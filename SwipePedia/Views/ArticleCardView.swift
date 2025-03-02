import SwiftUI

struct ArticleCardView: View {
    let article: WikiArticle
    let onLike: () -> Void
    let onDislike: () -> Void
    let onBookmark: () -> Void
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    
    @State private var offset = CGSize.zero
    @State private var unsplashImageURL: URL?
    
    // Card animation properties
    private let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.black.opacity(0.0),
            Color(hex: "93aec1").opacity(0.7)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    private var rotationAngle: Double {
        return Double(offset.width / 300) * 20
    }
    
    private var swipeStatusOpacity: Double {
        abs(Double(offset.width / 150))
    }
    
    // Add these computed properties for button animations
    private var likeButtonScale: CGFloat {
        let threshold: CGFloat = 50
        if offset.width > threshold {
            return 1.3
        }
        return 1.0 + (max(0, offset.width) / threshold) * 0.3
    }
    
    private var dislikeButtonScale: CGFloat {
        let threshold: CGFloat = -50
        if offset.width < threshold {
            return 1.3
        }
        return 1.0 + (max(0, -offset.width) / -threshold) * 0.3
    }
    
    private var likeButtonOpacity: Double {
        1.0 + Double(max(0, offset.width) / 100)
    }
    
    private var dislikeButtonOpacity: Double {
        1.0 + Double(max(0, -offset.width) / 100)
    }
    
    private func swipeRight() {
        withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
            offset.width = 1000
            onLike()
        }
    }
    
    private func swipeLeft() {
        withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
            offset.width = -1000
            onDislike()
        }
    }
    
    private func loadImage() {
        guard unsplashImageURL == nil else { return }
        
        Task {
            do {
                print("Starting image load for article: '\(article.title)'")
                
                // First check if we have a Wikipedia thumbnail
                if let wikipediaImage = article.thumbnailURL {
                    print("Using Wikipedia image for: '\(article.title)'")
                    unsplashImageURL = wikipediaImage
                    return
                }
                
                // If no Wikipedia image, try DuckDuckGo
                let searchQuery = article.title
                print("No Wikipedia image, attempting DuckDuckGo search with query: '\(searchQuery)'")
                
                if let duckDuckGoImage = try await DuckDuckGoManager.shared.fetchImage(for: searchQuery) {
                    print("Successfully got DuckDuckGo image for: '\(article.title)'")
                    unsplashImageURL = duckDuckGoImage
                    return
                }
                
                print("DuckDuckGo search failed, trying Unsplash for: '\(article.title)'")
                // If DuckDuckGo fails, try Unsplash
                unsplashImageURL = try await UnsplashManager.shared.fetchImage(for: searchQuery)
                
                // If all fail, try fallback search
                if unsplashImageURL == nil {
                    print("All image searches failed, trying fallback for: '\(article.title)'")
                    unsplashImageURL = try await UnsplashManager.shared.fetchImage(for: "knowledge education learning")
                }
            } catch {
                print("Failed to load image for '\(article.title)': \(error)")
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Card
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: Color(hex: "93aec1").opacity(0.3), radius: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "93aec1").opacity(0.8), lineWidth: 3)
                    )
                
                // Main Content Stack
                VStack(spacing: 0) {
                    // Image Area
                    if let url = article.thumbnailURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "9dbdba").opacity(0.1))
                        } placeholder: {
                            ProgressView()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "9dbdba").opacity(0.1))
                        }
                    } else if let url = unsplashImageURL {
                        // Use Unsplash image
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "9dbdba").opacity(0.1))
                        } placeholder: {
                            ProgressView()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "9dbdba").opacity(0.1))
                        }
                    } else {
                        // Show placeholder and try to load Unsplash image
                        Rectangle()
                            .fill(Color(hex: "9dbdba").opacity(0.2))
                            .frame(height: 300)
                            .onAppear {
                                print("Loading image for article: \(article.title)")
                                loadImage()
                            }
                    }
                    
                    // Content Area with fixed height distribution
                    VStack(spacing: 0) {
                        // Text Content Area
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(article.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "93aec1"))
                                    .padding(.top, 20)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Text(article.summary)
                                    .font(.body)
                                    .foregroundColor(Color(hex: "9dbdba"))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                        }
                        .frame(height: 230)  // Keep the text area height
                        
                        Spacer(minLength: 0)  // Changed from Spacer() to Spacer(minLength: 0)
                        
                        // Button Area with fixed height
                        VStack(spacing: 0) {
                            Divider()
                                .padding(.horizontal, 30)
                            
                            // Action Buttons
                            HStack(spacing: 0) {
                                Spacer()
                                    .frame(width: 30)
                                
                                Button(action: swipeLeft) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "ec6a52"))
                                        .background(Circle().fill(.white))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                                        .scaleEffect(dislikeButtonScale)
                                        .opacity(dislikeButtonOpacity)
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: offset)
                                
                                Spacer()
                                
                                Button(action: onBookmark) {
                                    Image(systemName: "bookmark.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "f8b042"))
                                        .background(Circle().fill(.white))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                                }
                                
                                Spacer()
                                
                                Button(action: swipeRight) {
                                    Image(systemName: "heart.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "4CAF50"))
                                        .background(Circle().fill(.white))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                                        .scaleEffect(likeButtonScale)
                                        .opacity(likeButtonOpacity)
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: offset)
                                
                                Spacer()
                                    .frame(width: 30)
                            }
                            .frame(height: 80)
                            .padding(.vertical, 5)  // Reduced from 10 to 5
                        }
                        .padding(.bottom, 10)  // Reduced from 20 to 10
                    }
                }
                
                // Swipe Indicators (on top of everything)
                ZStack {
                    // LIKE overlay
                    Text("LIKE")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color(hex: "9dbdba"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "9dbdba"), lineWidth: 4)
                        )
                        .rotationEffect(.degrees(-45))
                        .opacity(offset.width > 0 ? swipeStatusOpacity : 0)
                        .padding(.leading, 45)
                    
                    // NOPE overlay
                    Text("NOPE")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color(hex: "ec6a52"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "ec6a52"), lineWidth: 4)
                        )
                        .rotationEffect(.degrees(45))
                        .opacity(offset.width < 0 ? swipeStatusOpacity : 0)
                        .padding(.trailing, 45)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .offset(offset)
            .rotationEffect(.degrees(rotationAngle))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        let width = gesture.translation.width
                        if width > 100 {
                            swipeRight()
                        } else if width < -100 {
                            swipeLeft()
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                offset = .zero
                            }
                        }
                    }
            )
        }
        .frame(height: 650)
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
    }
}

#Preview {
    ArticleCardView(
        article: .sample,
        onLike: {},
        onDislike: {},
        onBookmark: {}
    )
    .padding()
} 
