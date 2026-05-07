import Foundation

enum ArticleServiceError: LocalizedError {
    case badStatus(Int)
    case empty

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "Sunucu hatası (\(code)). Lütfen tekrar dene."
        case .empty:               return "Haber bulunamadı."
        }
    }
}

final class ArticleService {

    private static let articlesURL = URL(
        string: "https://raw.githubusercontent.com/alialtinok/lexinews-content/main/output/articles.json"
    )!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        fmt.timeZone   = TimeZone(identifier: "UTC")
        d.dateDecodingStrategy = .formatted(fmt)
        return d
    }()

    func fetchArticles() async throws -> [Article] {
        let (data, response) = try await URLSession.shared.data(from: Self.articlesURL)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw ArticleServiceError.badStatus(http.statusCode)
        }
        let result = try decoder.decode(ArticlesResponse.self, from: data)
        if result.articles.isEmpty { throw ArticleServiceError.empty }
        return result.articles.sorted { $0.published > $1.published }
    }
}
