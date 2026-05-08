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
        string: "https://raw.githubusercontent.com/alialtinok/wislynews-content/main/output/articles.json"
    )!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]
        let legacy = DateFormatter()
        legacy.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        legacy.timeZone   = TimeZone(identifier: "UTC")

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = isoFractional.date(from: raw) { return date }
            if let date = isoPlain.date(from: raw)      { return date }
            if let date = legacy.date(from: raw)        { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognized date format: \(raw)")
        }
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
