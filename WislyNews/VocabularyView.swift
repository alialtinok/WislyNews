import SwiftUI

// MARK: - LexiUp Banner

private struct LexiUpBanner: View {
    private let lexiUpURL = URL(string: "lexiup://")!
    private let appStoreURL = URL(string: "https://apps.apple.com/app/lexiup/id6741440462")!

    var body: some View {
        HStack(spacing: 14) {
            Image("LexiUpIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text("LexiUp ile bağlı")
                    .font(.subheadline.weight(.semibold))
                Text("Kaydettiğin kelimeler LexiUp'ta da görünür.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if UIApplication.shared.canOpenURL(lexiUpURL) {
                    UIApplication.shared.open(lexiUpURL)
                } else {
                    UIApplication.shared.open(appStoreURL)
                }
            } label: {
                Text("Aç")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Saved word row

private struct SavedWordRow: View {
    let saved: SavedWord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(saved.word)
                .font(.headline)
            if let preview = saved.contexts.first?.sentence {
                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - VocabularyView

struct VocabularyView: View {
    @EnvironmentObject private var store:    VocabularyStore
    @EnvironmentObject private var settings: UserSettingsStore
    @Environment(\.str) private var str
    @State private var tappedWord: String? = nil

    private var sortedWords: [SavedWord] {
        store.savedWords.values.sorted(by: { $0.id < $1.id })
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.savedWords.isEmpty {
                    ContentUnavailableView(
                        str.vocabEmpty,
                        systemImage: "books.vertical",
                        description: Text(str.vocabEmptyDesc)
                    )
                } else {
                    List {
                        Section {
                            LexiUpBanner()
                        }
                        Section {
                            ForEach(sortedWords) { saved in
                                Button { tappedWord = saved.word } label: {
                                    SavedWordRow(saved: saved)
                                }
                                .foregroundStyle(.primary)
                            }
                            .onDelete { idx in
                                idx.forEach { store.remove(sortedWords[$0].word) }
                            }
                        }
                    }
                }
            }
            .navigationTitle(str.tabMyWords)
        }
        .sheet(item: $tappedWord) { word in
            WordPopupSheet(word: word)
                .environmentObject(store)
                .environmentObject(settings)
        }
    }
}
