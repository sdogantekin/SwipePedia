import Foundation
import SwiftUI

@MainActor
class SwipeScreenViewModel: ObservableObject {
    @Published var articles: [WikiArticle] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    private let preloadThreshold = 3
    private let maxPreloadedArticles = 5
    
    init() {
        Task {
            await preloadArticles()
        }
        
        // Listen for language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("WikipediaLanguageChanged"),
            object: nil
        )
    }
    
    @objc private func languageChanged() {
        Task {
            await refreshContent()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func preloadArticles() async {
        guard articles.count < maxPreloadedArticles else { return }
        
        isLoading = true
        error = nil
        
        do {
            let newArticles = try await fetchRandomArticles()
            articles.append(contentsOf: newArticles)
        } catch {
            self.error = "Failed to load articles: \(error.localizedDescription)"
            self.showError = true
        }
        
        isLoading = false
    }
    
    func removeArticle(_ article: WikiArticle) {
        articles.removeAll { $0.id == article.id }
        
        if articles.count <= preloadThreshold {
            Task {
                await preloadArticles()
            }
        }
    }
    
    private func fetchRandomArticles() async throws -> [WikiArticle] {
        let url = WikipediaLanguageManager.shared.getRandomArticleURL()
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(WikipediaResponse.self, from: data)
        
        guard let pages = result.query?.pages?.values else {
            return []
        }
        
        return pages.compactMap { page in
            parseWikiPage(page)
        }
    }
    
    private func parseWikiPage(_ page: WikiPage) -> WikiArticle {
        return WikiArticle(
            id: String(page.pageid),
            title: page.title,
            summary: page.extract ?? "",
            thumbnailURL: page.thumbnail?.source != nil ? URL(string: page.thumbnail!.source) : nil
        )
    }
    
    func refreshContent() async {
        articles.removeAll()
        await preloadArticles()
    }
} 