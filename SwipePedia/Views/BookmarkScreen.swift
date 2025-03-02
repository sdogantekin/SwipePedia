import SwiftUI
import SafariServices

struct BookmarkScreen: View {
    @EnvironmentObject private var bookmarkManager: BookmarkManager
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @State private var selectedArticle: WikiArticle?
    @State private var showingSafari = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "f3b7ad").opacity(0.3),  // Soft pink
                        Color(hex: "93aec1").opacity(0.2)   // Blue-gray
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sort Picker
                    Picker(LocalizedStringKey("Sort Order"), selection: $bookmarkManager.sortOrder) {
                        ForEach(BookmarkSortOrder.allCases, id: \.self) { order in
                            Text(order.localizedName).tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .tint(Color(hex: "93aec1"))  // Blue-gray
                    
                    if bookmarkManager.bookmarkedArticles.isEmpty {
                        emptyStateView
                    } else {
                        bookmarkList
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("Bookmarks"))
        }
        .sheet(item: $selectedArticle) { article in
            if let url = URL(string: article.url) {
                SafariView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "93aec1"))  // Blue-gray
            Text(LocalizedStringKey("No Bookmarks Yet"))
                .font(.headline)
                .foregroundColor(.secondary)
            Text(LocalizedStringKey("Articles you bookmark will appear here"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var bookmarkList: some View {
        List {
            ForEach(bookmarkManager.bookmarkedArticles) { article in
                BookmarkRow(article: article, bookmarkManager: bookmarkManager) {
                    FirebaseManager.shared.logArticleView(articleTitle: article.title)
                    selectedArticle = article
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.white)  // White background for list items
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let article = bookmarkManager.bookmarkedArticles[index]
                    FirebaseManager.shared.logBookmarkAction(action: "remove", count: bookmarkManager.bookmarkedArticles.count - 1)
                    bookmarkManager.removeBookmark(article)
                }
            }
        }
        .listStyle(.plain)
        .background(Color.clear)  // Clear background for list
    }
}

struct BookmarkRow: View {
    let article: WikiArticle
    @ObservedObject var bookmarkManager: BookmarkManager
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let url = article.thumbnailURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "9dbdba").opacity(0.2))  // Sage green for placeholder
                        .frame(width: 80, height: 80)
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "9dbdba").opacity(0.2))  // Sage green for placeholder
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "93aec1"))  // Blue-gray for title
                    .lineLimit(2)
                
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "9dbdba"))  // Sage green for summary
                    .lineLimit(2)
            }
            .onTapGesture {
                onTap()
            }
            
            Spacer()
            
            Button(action: {
                bookmarkManager.shareArticle(article)
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(Color(hex: "f8b042"))
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 8)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = UIColor(Color.appAccent)
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    BookmarkScreen()
} 