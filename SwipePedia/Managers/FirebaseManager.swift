import Foundation
import FirebaseCore
import FirebaseAnalytics

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
    
    func configure() {
        FirebaseApp.configure()
        print("Firebase configured successfully") // Debug log
    }
    
    // Analytics Events
    func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        print("Logged app open event") // Debug log
    }
    
    func logArticleView(articleTitle: String) {
        let params: [String: Any] = [
            AnalyticsParameterItemID: articleTitle,
            AnalyticsParameterItemName: articleTitle,
            AnalyticsParameterContentType: "article"
        ]
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: params)
        print("Logged article view: \(articleTitle)") // Debug log
    }
    
    func logArticleAction(action: String, articleTitle: String) {
        let params: [String: Any] = [
            "action_type": action,
            "article_title": articleTitle
        ]
        Analytics.logEvent("article_interaction", parameters: params)
        print("Logged article action: \(action) for \(articleTitle)") // Debug log
    }
    
    func logBookmarkAction(action: String, count: Int) {
        let params: [String: Any] = [
            "action_type": action,
            "bookmark_count": count
        ]
        Analytics.logEvent("bookmark_action", parameters: params)
        print("Logged bookmark action: \(action), count: \(count)") // Debug log
    }
    
    func logThemeChange(isDark: Bool) {
        let params: [String: Any] = [
            "theme_mode": isDark ? "dark" : "light"
        ]
        Analytics.logEvent("theme_change", parameters: params)
        print("Logged theme change to: \(isDark ? "dark" : "light")") // Debug log
    }
    
    func logLanguageChange(to language: String) {
        let params: [String: Any] = [
            "selected_language": language
        ]
        Analytics.logEvent("language_change", parameters: params)
        print("Logged language change to: \(language)") // Debug log
    }
} 