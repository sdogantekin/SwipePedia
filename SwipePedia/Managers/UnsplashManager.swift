import Foundation

class UnsplashManager {
    static let shared = UnsplashManager()
    private let accessKey = "tdbMChc3yRO4VpKxb9Gr9SjpoQysUNKOMxIWTawC9K0"  // You'll need to sign up at https://unsplash.com/developers
    
    func fetchImage(for query: String) async throws -> URL? {
        // Clean up the query to improve search results
        let searchQuery = query
            .components(separatedBy: CharacterSet(charactersIn: "()[]{}"))
            .first?
            .trimmingCharacters(in: .whitespaces) ?? query
        
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "https://api.unsplash.com/photos/random?query=\(encodedQuery)&orientation=landscape&content_filter=high"
        
        print("Fetching Unsplash image for query: \(searchQuery)")
        print("URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for query: \(searchQuery)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        print("Authorization Header: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = httpResponse as? HTTPURLResponse {
                print("Unsplash API Response Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode != 200 {
                    print("Unsplash API Error: \(String(data: data, encoding: .utf8) ?? "No error message")")
                    return nil
                }
            }
            
            let imageResponse = try JSONDecoder().decode(UnsplashResponse.self, from: data)
            print("Successfully fetched image URL: \(imageResponse.urls.regular)")
            return URL(string: imageResponse.urls.regular)
        } catch {
            print("Unsplash API Error: \(error)")
            return nil
        }
    }
}

struct UnsplashResponse: Codable {
    let urls: ImageURLs
    
    struct ImageURLs: Codable {
        let regular: String
    }
} 
