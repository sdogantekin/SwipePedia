import SwiftUI

struct SwipeScreen: View {
    @StateObject private var viewModel = SwipeScreenViewModel()
    @EnvironmentObject private var bookmarkManager: BookmarkManager
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Title space
                    Color.clear
                        .frame(height: 20)
                    
                    if viewModel.articles.isEmpty {
                        if viewModel.isLoading {
                            ProgressView(LocalizedStringKey("Loading articles..."))
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "magazine")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                Text(LocalizedStringKey("No more articles to show"))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        cardStack
                            .padding(.vertical, 20)
                    }
                    
                    Spacer(minLength: 100) // Fixed minimum space at bottom
                }
                
                if viewModel.isLoading {
                    loadingOverlay
                }
                
                // Toast overlay
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: LocalizedStringKey("Article bookmarked!"))
                            .transition(.move(edge: .bottom))
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("Discover"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(LocalizedStringKey("Error"), isPresented: $viewModel.showError) {
                Button(LocalizedStringKey("OK"), role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error)
                } else {
                    Text(LocalizedStringKey("Unknown error occurred"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90) // Increased safe area for tab bar
            }
        }
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force refresh content in the selected language
            Task {
                await viewModel.refreshContent()
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "f3b7ad").opacity(0.3),  // Soft pink with lower opacity
                Color(hex: "93aec1").opacity(0.2)   // Blue-gray with lower opacity
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var cardStack: some View {
        GeometryReader { geometry in
            ZStack {
                // Show background cards first (max 3)
                ForEach(viewModel.articles.prefix(3).reversed()) { article in
                    ArticleCardView(
                        article: article,
                        onLike: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                likeArticle(article)
                            }
                        },
                        onDislike: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                dislikeArticle(article)
                            }
                        },
                        onBookmark: {
                            bookmarkArticle(article)
                        }
                    )
                    .frame(width: geometry.size.width * 0.9)
                    .frame(height: 600) // Fixed height for consistency
                    .offset(y: calculateCardOffset(for: article))
                    .offset(x: calculateHorizontalOffset(for: article))
                    .scaleEffect(calculateCardScale(for: article))
                    .rotationEffect(.degrees(calculateCardRotation(for: article)))
                    .zIndex(calculateZIndex(for: article))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var loadingOverlay: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "f3b7ad").opacity(0.5))
    }
    
    private func calculateCardOffset(for article: WikiArticle) -> CGFloat {
        guard let index = viewModel.articles.firstIndex(where: { $0.id == article.id }) else { return 0 }
        return CGFloat(index) * -50 // Increased from -30 to -50 for more pronounced stacking
    }
    
    private func calculateHorizontalOffset(for article: WikiArticle) -> CGFloat {
        guard let index = viewModel.articles.firstIndex(where: { $0.id == article.id }) else { return 0 }
        return CGFloat(index) * 12 // Increased from 8 to 12 to match vertical change
    }
    
    private func calculateCardScale(for article: WikiArticle) -> CGFloat {
        guard let index = viewModel.articles.firstIndex(where: { $0.id == article.id }) else { return 1 }
        let scale = 1 - CGFloat(index) * 0.1 // Increased from 0.08 to 0.1
        return max(scale, 0.8) // Adjusted minimum scale
    }
    
    private func calculateCardRotation(for article: WikiArticle) -> Double {
        guard let index = viewModel.articles.firstIndex(where: { $0.id == article.id }) else { return 0 }
        return Double(index) * -4 // Increased from -3 to -4
    }
    
    private func calculateZIndex(for article: WikiArticle) -> Double {
        guard let index = viewModel.articles.firstIndex(where: { $0.id == article.id }) else { return 0 }
        return Double(viewModel.articles.count - index) * 20 // Increased z-index separation
    }
    
    private func likeArticle(_ article: WikiArticle) {
        FirebaseManager.shared.logArticleAction(action: "like", articleTitle: article.title)
        viewModel.removeArticle(article)
    }
    
    private func dislikeArticle(_ article: WikiArticle) {
        FirebaseManager.shared.logArticleAction(action: "dislike", articleTitle: article.title)
        viewModel.removeArticle(article)
    }
    
    private func bookmarkArticle(_ article: WikiArticle) {
        FirebaseManager.shared.logArticleAction(action: "bookmark", articleTitle: article.title)
        bookmarkManager.addBookmark(article)
        
        // Show toast
        withAnimation {
            showToast = true
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

#Preview {
    SwipeScreen()
} 