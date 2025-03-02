import Foundation

struct WikipediaResponse: Codable {
    let query: QueryResponse?
}

struct QueryResponse: Codable {
    let pages: [String: WikiPage]?
}

struct WikiPage: Codable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnail: WikiImageThumbnail?
    let fullurl: String?
}

struct WikiImageThumbnail: Codable {
    let source: String
    let width: Int
    let height: Int
} 