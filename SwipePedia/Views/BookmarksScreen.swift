import SwiftUI

struct BookmarksScreen: View {
    @ObservedObject var bookmarkManager: BookmarkManager
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @State private var selectedArticle: WikiArticle?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(bookmarkManager.bookmarkedArticles) { article in
                        BookmarkRow(
                            article: article,
                            bookmarkManager: bookmarkManager,
                            onTap: {
                                selectedArticle = article
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(Text("Bookmarks", bundle: .main))
            .background(Color(hex: "f3f3f3"))
        }
        .sheet(item: $selectedArticle) { article in
            if let url = URL(string: article.url) {
                SafariView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
    }
} 