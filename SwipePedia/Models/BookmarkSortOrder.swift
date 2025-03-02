import Foundation
import SwiftUI

enum BookmarkSortOrder: String, CaseIterable {
    case mostRecent = "Most Recent"
    case alphabetical = "Alphabetical"
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    func sortComparator() -> (WikiArticle, WikiArticle) -> Bool {
        switch self {
        case .mostRecent:
            // Most recent first (assuming newer items are at the start of the array)
            return { _, _ in true }
        case .alphabetical:
            return { $0.title < $1.title }
        }
    }
} 