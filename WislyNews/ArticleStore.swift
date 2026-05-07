import Foundation
import Combine

@MainActor
final class ArticleStore: ObservableObject {

    @Published var articles:     [Article] = []
    @Published var isLoading:    Bool      = false
    @Published var errorMessage: String?   = nil

    var categories: [String] {
        Array(Set(articles.map { $0.category })).sorted()
    }

    func articles(for category: String? = nil) -> [Article] {
        guard let category else { return articles }
        return articles.filter { $0.category == category }
    }

    private let service = ArticleService()

    func load() async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { articles = try await service.fetchArticles() }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func reload() async { articles = []; await load() }
}
