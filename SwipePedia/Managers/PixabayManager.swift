import Foundation

class PixabayManager {
    static let shared = PixabayManager()
    private let apiKey = "40799654-c4f4f8b5f66f7c4d3e2c5c3d6"  // Free Pixabay API key
    
    func fetchImage(for query: String) async throws -> URL? {
        // Clean up the query
        let searchQuery = query
            .components(separatedBy: CharacterSet(charactersIn: "()[]{}"))
            .first?
            .trimmingCharacters(in: .whitespaces) ?? query
        
        print("Pixabay: Searching for '\(searchQuery)'")
        
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "https://pixabay.com/api/?key=\(apiKey)&q=\(encodedQuery)&image_type=photo&per_page=3"
        
        guard let url = URL(string: urlString) else {
            print("Pixabay: Invalid URL for query: '\(searchQuery)'")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Pixabay Response Code: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    print("Pixabay Error: Status code \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            let searchResponse = try JSONDecoder().decode(PixabayResponse.self, from: data)
            
            if let imageUrl = searchResponse.hits.first?.largeImageURL {
                print("Found Pixabay image: \(imageUrl)")
                return URL(string: imageUrl)
            }
            
            return nil
        } catch {
            print("Pixabay Error: \(error.localizedDescription)")
            return nil
        }
    }
}

struct PixabayResponse: Codable {
    let hits: [ImageResult]
    
    struct ImageResult: Codable {
        let largeImageURL: String
    }
} 