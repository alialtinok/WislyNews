import SwiftUI

struct WordPopupSheet: View {
    let word: String
    var pendingContext: WordContext? = nil
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var settings:        UserSettingsStore
    @Environment(\.str)     private var str
    @Environment(\.dismiss) private var dismiss

    private var existingContexts: [WordContext] { vocabularyStore.contexts(for: word) }

    private var displayContexts: [WordContext] {
        if let pendingContext, !existingContexts.contains(pendingContext) {
            return [pendingContext] + existingContexts
        }
        return existingContexts
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(word).font(.system(size: 36, weight: .bold)).padding(.top, 8)
                Divider()
                TranslationView(word: word,
                                targetLanguageCode: settings.nativeLanguage.translationCode,
                                missingLabel: str.translationMissing)

                if !displayContexts.isEmpty {
                    contextSection
                }

                Spacer(minLength: 8)

                Button {
                    let langID = settings.nativeLanguage.id
                    if vocabularyStore.isSaved(word) {
                        vocabularyStore.remove(word, languageID: langID)
                    } else {
                        vocabularyStore.save(word, context: pendingContext, languageID: langID)
                    }
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var contextSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(displayContexts, id: \.self) { ctx in
                    ContextRow(context: ctx, word: word)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ContextRow: View {
    let context: WordContext
    let word: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(highlighted(context.sentence, word: word))
                .font(.callout)
                .multilineTextAlignment(.leading)
            Text(context.articleTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func highlighted(_ sentence: String, word: String) -> AttributedString {
        var attr = AttributedString(sentence)
        let lowerSentence = sentence.lowercased()
        let lowerWord = word.lowercased()
        var searchStart = lowerSentence.startIndex
        while let range = lowerSentence.range(of: lowerWord, range: searchStart..<lowerSentence.endIndex) {
            let before = lowerSentence.startIndex < range.lowerBound
                ? lowerSentence[lowerSentence.index(before: range.lowerBound)]
                : Character(" ")
            let after = range.upperBound < lowerSentence.endIndex
                ? lowerSentence[range.upperBound]
                : Character(" ")
            let isWordBoundary = !before.isLetter && !after.isLetter
            if isWordBoundary,
               let attrRange = Range(range, in: attr) {
                attr[attrRange].font = .callout.bold()
                attr[attrRange].foregroundColor = .accentColor
            }
            searchStart = range.upperBound
        }
        return attr
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
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=en|\(targetLanguageCode)&de=info.alialtinok@gmail.com")
        else { isLoading = false; return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response  = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            let text      = response.responseData.translatedText.trimmingCharacters(in: .whitespaces)
            translation   = isValid(text, original: word) ? text : nil
        } catch {
            translation = nil
        }
        isLoading = false
    }

    private func isValid(_ text: String, original: String) -> Bool {
        if text.isEmpty { return false }
        if text.caseInsensitiveCompare(original) == .orderedSame { return false }
        if text.hasPrefix("MYMEMORY WARNING") { return false }
        if text.contains("???") { return false }
        if text.contains("%") { return false }
        if !text.contains(where: { $0.isLetter || $0.isNumber }) { return false }
        return true
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
