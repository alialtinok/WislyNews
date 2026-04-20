import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ArticleStore
    @State private var selectedCategory: String? = nil

    private var displayedArticles: [Article] {
        store.articles(for: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading && store.articles.isEmpty {
                    ProgressView("Haberler yükleniyor…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = store.errorMessage, store.articles.isEmpty {
                    ErrorView(message: error) { Task { await store.reload() } }
                } else {
                    articleList
                }
            }
            .navigationTitle("LexiNews")
            .toolbar { levelPicker }
        }
    }

    private var articleList: some View {
        ScrollView {
            if !store.categories.isEmpty {
                categoryChips.padding(.horizontal).padding(.top, 4)
            }
            LazyVStack(spacing: 12) {
                ForEach(displayedArticles) { article in
                    NavigationLink(value: article) {
                        ArticleCard(article: article, level: store.selectedLevel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .refreshable { await store.reload() }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Tümü", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(store.categories, id: \.self) { cat in
                    chip(title: cat.capitalized, isSelected: selectedCategory == cat) { selectedCategory = cat }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private var levelPicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Picker("Seviye", selection: $store.selectedLevel) {
                ForEach(CEFRLevel.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
        }
    }
}

private struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash").font(.system(size: 48)).foregroundStyle(.secondary)
            Text(message).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button("Tekrar Dene", action: retry).buttonStyle(.borderedProminent)
        }
        .padding().frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
