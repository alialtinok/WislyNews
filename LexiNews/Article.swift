import Foundation

// MARK: - CEFR Level

enum CEFRLevel: String, Codable, CaseIterable, Comparable {
    case A2, B1, B2, C1, C2

    private static let order: [CEFRLevel] = [.A2, .B1, .B2, .C1, .C2]

    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var label: String { rawValue }
}

// MARK: - Article Version

struct ArticleVersion: Codable {
    let level: CEFRLevel
    let title: String
    let body: String
    let keyVocabulary: [String]

    enum CodingKeys: String, CodingKey {
        case level, title, body
        case keyVocabulary = "key_vocabulary"
    }
}

// MARK: - Article

struct Article: Codable, Identifiable, Hashable {
    static func == (lhs: Article, rhs: Article) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: String
    let originalTitle: String
    let originalURL: String
    let category: String
    let published: Date
    let versions: [String: ArticleVersion]

    enum CodingKeys: String, CodingKey {
        case id, category, published, versions
        case originalTitle = "original_title"
        case originalURL   = "original_url"
    }

    func version(for level: CEFRLevel) -> ArticleVersion? {
        if let exact = versions[level.rawValue] { return exact }
        let available = availableLevels
        if let below = available.filter({ $0 < level }).max() { return versions[below.rawValue] }
        if let above = available.filter({ $0 > level }).min() { return versions[above.rawValue] }
        return nil
    }

    var availableLevels: [CEFRLevel] {
        CEFRLevel.allCases.filter { versions[$0.rawValue] != nil }.sorted()
    }
}

// MARK: - API Response

struct ArticlesResponse: Codable {
    let articles: [Article]
}
