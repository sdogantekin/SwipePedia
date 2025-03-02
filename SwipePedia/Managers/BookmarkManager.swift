import Foundation
import SwiftUI

class BookmarkManager: ObservableObject {
    @Published private(set) var bookmarkedArticles: [WikiArticle] = []
    @Published var sortOrder: BookmarkSortOrder = .mostRecent {
        didSet {
            sortBookmarks()
        }
    }
    
    private let maxBookmarks = 50
    private let saveKey = "SavedBookmarks"
    
    init() {
        loadBookmarks()
    }
    
    func addBookmark(_ article: WikiArticle) {
        guard !bookmarkedArticles.contains(where: { $0.id == article.id }) else { return }
        
        // Remove oldest bookmark if we've reached the limit
        if bookmarkedArticles.count >= maxBookmarks {
            bookmarkedArticles.removeLast()
        }
        
        // Add new bookmark at the beginning (most recent)
        bookmarkedArticles.insert(article, at: 0)
        saveBookmarks()
        
        FirebaseManager.shared.logBookmarkAction(
            action: "add",
            count: bookmarkedArticles.count
        )
    }
    
    func removeBookmark(_ article: WikiArticle) {
        bookmarkedArticles.removeAll { $0.id == article.id }
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarkedArticles) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([WikiArticle].self, from: data) {
            bookmarkedArticles = decoded
            sortBookmarks()
        }
    }
    
    private func sortBookmarks() {
        switch sortOrder {
        case .mostRecent:
            // Already sorted by most recent (newest first)
            break
        case .alphabetical:
            bookmarkedArticles.sort(by: sortOrder.sortComparator())
        }
    }
    
    func clearAllBookmarks() {
        let count = bookmarkedArticles.count
        bookmarkedArticles.removeAll()
        saveBookmarks()
        
        FirebaseManager.shared.logBookmarkAction(
            action: "clear_all",
            count: count
        )
    }
    
    func shareArticle(_ article: WikiArticle) {
        // Create share items
        let title = article.title
        let summary = article.summary
        let url = article.url
        
        let shareText = """
        Check out this interesting article from Wikipedia!
        
        \(title)
        
        \(summary)
        
        Read more: \(url)
        
        Shared via SwipePedia
        """
        
        let activityItems: [Any] = [shareText]
        
        // Create UIActivityViewController
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
} 