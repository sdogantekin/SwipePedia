import Foundation

class BingImageManager {
    static let shared = BingImageManager()
    private let apiKey = "YOUR_BING_API_KEY"  // You'll need to get this from Azure Portal
    
    func fetchImage(for query: String) async throws -> URL? {
        let searchQuery = query
            .components(separatedBy: CharacterSet(charactersIn: "()[]{}"))
            .first?
            .trimmingCharacters(in: .whitespaces) ?? query
        
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "https://api.bing.microsoft.com/v7.0/images/search?q=\(encodedQuery)&count=1"
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BingImageResponse.self, from: data)
        
        return URL(string: response.value.first?.contentUrl ?? "")
    }
}

struct BingImageResponse: Codable {
    let value: [BingImage]
    
    struct BingImage: Codable {
        let contentUrl: String
    }
} 