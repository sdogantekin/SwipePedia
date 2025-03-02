import Foundation
import SwiftUI

class WikipediaLanguageManager: ObservableObject {
    static let shared = WikipediaLanguageManager()
    
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    
    private init() {}
    
    var currentLanguage: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }
    
    var baseAPIURL: String {
        "https://\(currentLanguage.rawValue).wikipedia.org/w/api.php"
    }
    
    func getRandomArticleURL() -> URL {
        var components = URLComponents(string: baseAPIURL)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "generator", value: "random"),
            URLQueryItem(name: "grnnamespace", value: "0"),
            URLQueryItem(name: "grnlimit", value: "10"),
            URLQueryItem(name: "prop", value: "extracts|pageimages|info"),
            URLQueryItem(name: "exintro", value: "true"),
            URLQueryItem(name: "explaintext", value: "true"),
            URLQueryItem(name: "inprop", value: "url"),
            URLQueryItem(name: "piprop", value: "thumbnail"),
            URLQueryItem(name: "pithumbsize", value: "400"),
            URLQueryItem(name: "uselang", value: currentLanguage.rawValue)
        ]
        return components.url!
    }
    
    func getArticleURL(title: String) -> String {
        let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        let encodedTitle = title.replacingOccurrences(of: " ", with: "_")
        return "https://\(languageCode).wikipedia.org/wiki/\(encodedTitle)"
    }
    
    // Add this method to refresh content when language changes
    func languageChanged() {
        objectWillChange.send()
        NotificationCenter.default.post(name: NSNotification.Name("WikipediaLanguageChanged"), object: nil)
    }
} 