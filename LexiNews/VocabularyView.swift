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

// MARK: - VocabularyView

struct VocabularyView: View {
    @EnvironmentObject private var store:    VocabularyStore
    @EnvironmentObject private var settings: UserSettingsStore
    @Environment(\.str) private var str
    @State private var tappedWord: String? = nil

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
                            ForEach(store.savedWords.sorted(), id: \.self) { word in
                                Button(word) { tappedWord = word }.foregroundStyle(.primary)
                            }
                            .onDelete { idx in
                                let sorted = store.savedWords.sorted()
                                idx.forEach { store.remove(sorted[$0]) }
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
