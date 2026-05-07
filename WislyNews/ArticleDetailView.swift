import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @EnvironmentObject private var articleStore:    ArticleStore
    @EnvironmentObject private var settings:        UserSettingsStore
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var readingStore:    ReadingStore
    @EnvironmentObject private var speechService:   SpeechService
    @Environment(\.str) private var str
    @State private var localLevel: CEFRLevel? = nil
    @State private var tappedWord: String?    = nil

    private var activeLevel: CEFRLevel { localLevel ?? settings.selectedLevel }
    private var version: ArticleVersion? { article.version(for: activeLevel) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CategoryPill(category: article.category)
                levelSwitcher
                if let version {
                    Text(version.title).font(Theme.Font.articleTitle)
                    Divider()
                    TappableTextView(text: version.body, savedWords: vocabularyStore.savedWords) {
                        tappedWord = $0
                    }
                    .frame(maxWidth: .infinity)
                    if !version.keyVocabulary.isEmpty {
                        keyVocabularySection(version.keyVocabulary)
                    }
                } else {
                    Text(str.noContent).foregroundStyle(.secondary)
                }
                if let url = URL(string: article.originalURL) {
                    Link(destination: url) {
                        Label(str.readOriginal, systemImage: "arrow.up.right.square").font(.footnote)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ttsToolbar }
        .onAppear { readingStore.markRead(articleID: article.id) }
        .onDisappear { speechService.stop() }
        .sheet(item: $tappedWord) { word in
            WordPopupSheet(word: word)
                .environmentObject(vocabularyStore)
                .environmentObject(settings)
        }
    }

    private var ttsToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if speechService.isPlaying {
                Button { speechService.pause() } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            } else if speechService.isPaused {
                Button { playCurrentVersion() } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                Button { speechService.stop() } label: {
                    Image(systemName: "stop.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button { playCurrentVersion() } label: {
                    Image(systemName: "play.circle")
                        .font(.title3)
                }
            }
        }
    }

    private func playCurrentVersion() {
        guard let version else { return }
        let text = version.title + ". " + version.body
        speechService.play(text: text)
    }

    private var levelSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(article.availableLevels, id: \.self) { lvl in
                    Button { localLevel = lvl } label: {
                        Text(lvl.fullName)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16).padding(.vertical, 7)
                            .background(activeLevel == lvl ? Color.accentColor : Color(.secondarySystemBackground))
                            .foregroundStyle(activeLevel == lvl ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func keyVocabularySection(_ words: [String]) -> some View {
        let unique = words.reduce(into: [String]()) { result, w in
            if !result.contains(where: { $0.caseInsensitiveCompare(w) == .orderedSame }) { result.append(w) }
        }
        return VStack(alignment: .leading, spacing: 10) {
            Text(str.keyVocabulary).font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(unique, id: \.self) { word in
                    Button { tappedWord = word } label: {
                        Text(word)
                            .font(.subheadline)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(
                                vocabularyStore.isSaved(word)
                                    ? Color.accentColor.opacity(0.15)
                                    : Color(.secondarySystemBackground)
                            )
                            .foregroundStyle(vocabularyStore.isSaved(word) ? Color.accentColor : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.maxHeight }.reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                let size = item.sizeThatFits(.unspecified)
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private struct Row { var items: [LayoutSubview] = []; var maxHeight: CGFloat = 0 }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []; var current = Row(); var x: CGFloat = 0
        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, !current.items.isEmpty {
                rows.append(current); current = Row(); x = 0
            }
            current.items.append(sv); current.maxHeight = max(current.maxHeight, size.height)
            x += size.width + spacing
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }
}
