import Foundation

struct WikiArticle: Identifiable, Codable {
    let id: String
    let title: String
    let summary: String
    let thumbnailURL: URL?
    
    var url: String {
        WikipediaLanguageManager.shared.getArticleURL(title: title)
    }
    
    init(id: String, title: String, summary: String, thumbnailURL: URL?) {
        self.id = id
        self.title = title
        self.summary = summary
        self.thumbnailURL = thumbnailURL
    }
    
    static let sample = WikiArticle(
        id: "123",
        title: "Sample Article",
        summary: "This is a sample article summary for preview purposes.",
        thumbnailURL: nil
    )
} 