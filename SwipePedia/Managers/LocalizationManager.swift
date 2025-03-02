import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @Published private(set) var currentLocale: Locale = .current
    
    private init() {
        updateLocale()
    }
    
    func updateLocale() {
        guard let language = AppLanguage(rawValue: appLanguage) else { return }
        currentLocale = language.locale
        
        // Update system-wide language settings
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Notify all views of language change
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
} 