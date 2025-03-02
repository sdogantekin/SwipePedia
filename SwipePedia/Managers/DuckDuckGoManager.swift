import Foundation

class DuckDuckGoManager {
    static let shared = DuckDuckGoManager()
    
    func fetchImage(for query: String) async throws -> URL? {
        // Clean up and encode the query
        let searchQuery = query.trimmingCharacters(in: .whitespaces)
        
        print("DuckDuckGo: Processing query: '\(searchQuery)'")
        
        // Using the same endpoint as duckduckgo-search library
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "https://duckduckgo.com/?q=\(encodedQuery)&t=_"
        
        guard let url = URL(string: urlString) else {
            print("DuckDuckGo: Invalid URL created for query: '\(searchQuery)'")
            return nil
        }
        
        print("DuckDuckGo: Making request to URL: \(urlString)")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("https://duckduckgo.com", forHTTPHeaderField: "Referer")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        // Log the full request details
        print("DuckDuckGo: Full request details:")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Timeout: \(request.timeoutInterval) seconds")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("DuckDuckGo Response Code: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    print("DuckDuckGo Error: Status code \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            // Parse the HTML response to extract VQD token
            if let htmlString = String(data: data, encoding: .utf8),
               let vqd = extractVQD(from: htmlString) {
                
                // Make second request to get images using VQD
                let imageUrlString = "https://duckduckgo.com/i.js?q=\(encodedQuery)&vqd=\(vqd)&p=1&s=0"
                guard let imageUrl = URL(string: imageUrlString) else { return nil }
                
                var imageRequest = URLRequest(url: imageUrl)
                imageRequest.timeoutInterval = 15
                imageRequest.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
                imageRequest.setValue("https://duckduckgo.com", forHTTPHeaderField: "Referer")
                
                let (imageData, imageResponse) = try await URLSession.shared.data(for: imageRequest)
                
                if let imageResults = try? JSONDecoder().decode(DuckDuckGoImageResponse.self, from: imageData),
                   let firstImageUrl = imageResults.results.first?.image {
                    print("Found DuckDuckGo image: \(firstImageUrl)")
                    return URL(string: firstImageUrl)
                }
            }
            
            return nil
        } catch {
            print("DuckDuckGo Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractVQD(from html: String) -> String? {
        // Look for vqd token in the HTML
        let pattern = "vqd=(['\"])([^'\"]+)\\1"
        if let range = html.range(of: pattern, options: .regularExpression),
           let vqd = html[range].split(separator: "=").last?.trimmingCharacters(in: .init(charactersIn: "'\"")) {
            print("Found VQD token: \(vqd)")
            return vqd
        }
        return nil
    }
}

struct DuckDuckGoImageResponse: Codable {
    let results: [ImageResult]
    
    struct ImageResult: Codable {
        let image: String
        let title: String?
        let width: Int?
        let height: Int?
    }
} 
