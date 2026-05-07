import SwiftUI

struct WordPopupSheet: View {
    let word: String
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var settings:        UserSettingsStore
    @Environment(\.str)     private var str
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(word).font(.system(size: 36, weight: .bold)).padding(.top, 8)
                Divider()
                TranslationView(word: word,
                                targetLanguageCode: settings.nativeLanguage.translationCode,
                                missingLabel: str.translationMissing)
                Spacer()
                Button {
                    let langID = settings.nativeLanguage.id
                    if vocabularyStore.isSaved(word) { vocabularyStore.remove(word, languageID: langID) }
                    else { vocabularyStore.save(word, languageID: langID) }
                } label: {
                    Label(
                        vocabularyStore.isSaved(word) ? str.removeWord : str.saveWord,
                        systemImage: vocabularyStore.isSaved(word) ? "bookmark.slash" : "bookmark"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(vocabularyStore.isSaved(word) ? .red : .accentColor)
                .padding(.horizontal).padding(.bottom, 8)
            }
            .padding()
            .navigationTitle(str.wordTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(str.closeButton) { dismiss() } } }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct TranslationView: View {
    let word: String
    let targetLanguageCode: String
    let missingLabel: String
    @State private var translation: String? = nil
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                ProgressView()
            } else if let tr = translation {
                Text(tr)
                    .font(.title2.weight(.medium))
                    .multilineTextAlignment(.center)
            } else {
                Text(missingLabel)
                    .foregroundStyle(.secondary)
            }
        }
        .task { await fetchTranslation() }
    }

    private func fetchTranslation() async {
        guard let encoded = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=en|\(targetLanguageCode)")
        else { isLoading = false; return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response  = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            let text      = response.responseData.translatedText.trimmingCharacters(in: .whitespaces)
            translation   = text.isEmpty ? nil : text
        } catch {
            translation = nil
        }
        isLoading = false
    }
}

// MARK: - MyMemory response model

private struct MyMemoryResponse: Decodable {
    struct ResponseData: Decodable {
        let translatedText: String
        enum CodingKeys: String, CodingKey {
            case translatedText = "translatedText"
        }
    }
    let responseData: ResponseData
}
