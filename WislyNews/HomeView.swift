import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store:    ArticleStore
    @EnvironmentObject private var settings: UserSettingsStore
    @Environment(\.str) private var str
    @State private var selectedCategory: String? = nil

    private var displayedArticles: [Article] {
        store.articles(for: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WislyBackground()
                Group {
                    if store.isLoading && store.articles.isEmpty {
                        ProgressView(str.loadingNews)
                            .tint(.white)
                            .foregroundStyle(.white.opacity(0.78))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = store.errorMessage, store.articles.isEmpty {
                        ErrorView(message: error, retryLabel: str.retryButton) { Task { await store.reload() } }
                    } else {
                        articleList
                    }
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { levelPicker }
        }
        .preferredColorScheme(.dark)
    }

    private var articleList: some View {
        ScrollView {
            Text("Wisly News")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 18)
            if !store.categories.isEmpty {
                categoryChips.padding(.horizontal).padding(.top, 4)
            }
            LazyVStack(spacing: 12) {
                ForEach(displayedArticles) { article in
                    NavigationLink(value: article) {
                        ArticleCard(article: article, level: settings.selectedLevel)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollClipDisabled(false)
        .refreshable { await store.reload() }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: str.filterAll, isSelected: selectedCategory == nil) { selectedCategory = nil }
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
                .background(isSelected ? Theme.electricBlue : Theme.glass)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.84))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Theme.electricBlue : Theme.hairline, lineWidth: 1)
                )
        }
    }

    private var levelPicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(CEFRLevel.allCases, id: \.self) { level in
                    Button {
                        settings.selectedLevel = level
                    } label: {
                        if settings.selectedLevel == level {
                            Label(level.label, systemImage: "checkmark")
                        } else {
                            Text(level.label)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(settings.selectedLevel.rawValue)
                        .font(.subheadline.monospaced().weight(.bold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Theme.glass)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ErrorView: View {
    let message: String
    let retryLabel: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            NeonIconBadge(systemName: "wifi.slash", tint: .white.opacity(0.7), size: 56)
            Text(message).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.7))
            Button(retryLabel, action: retry).buttonStyle(.borderedProminent)
        }
        .padding().frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
