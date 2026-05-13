import SwiftUI

// MARK: - Wisly Banner

private struct WislyBanner: View {
    private let appURL      = URL(string: "wisly://")!
    private let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id6765777781")!

    var body: some View {
        HStack(spacing: 14) {
            NeonIconBadge(systemName: "books.vertical.fill", size: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text("Wisly: Learn English Words")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text("Kaydettiğin kelimeler bu uygulamada da görünür.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            Button {
                openWisly()
            } label: {
                Text("Aç")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.electricBlue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .glassPanel(cornerRadius: 18, isSelected: true)
    }

    private func openWisly() {
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL) { didOpen in
                if !didOpen {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
}

// MARK: - Saved word row

private struct SavedWordRow: View {
    let saved: SavedWord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(saved.word)
                .font(.headline)
                .foregroundStyle(.white)
            if let preview = saved.contexts.first?.sentence {
                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 10)
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
            ZStack {
                WislyBackground()
                if store.savedWords.isEmpty {
                    VStack(spacing: 14) {
                        NeonIconBadge(systemName: "books.vertical", size: 64)
                        Text(str.vocabEmpty)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text(str.vocabEmptyDesc)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.66))
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(str.tabMyWords)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            WislyBanner()
                            ForEach(sortedWords) { saved in
                                Button { tappedWord = saved.word } label: {
                                    SavedWordRow(saved: saved)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 14)
                                        .glassPanel(cornerRadius: 14)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.remove(saved.word)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .sheet(item: $tappedWord) { word in
            WordPopupSheet(word: word)
                .environmentObject(store)
                .environmentObject(settings)
        }
    }
}
