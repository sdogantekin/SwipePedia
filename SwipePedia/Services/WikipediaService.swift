import Foundation

class WikipediaService {
    static let shared = WikipediaService()
    private let baseURL = "https://en.wikipedia.org/api/rest_v1"
    
    enum WikiError: Error {
        case invalidURL
        case networkError
        case noData
        case decodingError
    }
    
    private init() {}
    
    struct ArticleResponse: Codable {
        let title: String
        let extract: String?
        let thumbnail: WikiImageThumbnail?
        let fullurl: String?
    }
    
    func fetchRandomArticle() async throws -> WikiArticle {
        let endpoint = "\(baseURL)/page/random/summary"
        
        guard let url = URL(string: endpoint) else {
            throw WikiError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let response = try? decoder.decode(WikiResponse.self, from: data) else {
            throw WikiError.decodingError
        }
        
        return parseArticleResponse(response)
    }
    
    private func parseArticleResponse(_ response: WikiResponse) -> WikiArticle {
        print("heooo: ")
        return WikiArticle(
            id: String(response.pageid),
            title: response.title,
            summary: response.extract,
            thumbnailURL: response.thumbnail?.source
        )
    }
}

// Response models for Wikipedia API
private struct WikiResponse: Codable {
    let title: String
    let extract: String
    let thumbnail: WikiThumbnail?
    let pageid: Int
}

private struct WikiThumbnail: Codable {
    let source: URL
} 
