import SwiftUI

struct BookmarkCardView: View {
    let article: WikiArticle
    let onRemove: () -> Void
    @ObservedObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(article.title)
                .font(.headline)
                .foregroundColor(Color(hex: "93aec1"))
            
            // Summary
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(Color(hex: "9dbdba"))
                .lineLimit(3)
            
            // Action Buttons
            HStack {
                Spacer()
                
                // Share Button
                Button(action: {
                    bookmarkManager.shareArticle(article)
                }) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(hex: "f8b042"))
                }
                
                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "bookmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(hex: "ec6a52"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: Color(hex: "93aec1").opacity(0.2), radius: 4)
        )
    }
} 