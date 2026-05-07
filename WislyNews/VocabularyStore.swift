import Foundation
import Combine

@MainActor
final class VocabularyStore: ObservableObject {

    @Published private(set) var savedWords: [String: SavedWord] = [:]

    private let storageKey         = "wislynews.savedWords"
    private let legacyDictKey      = "lexinews.savedWords.v2"
    private let legacyStringSetKey = "lexinews.savedWords"

    init() { load() }

    // MARK: - Convenience

    var savedWordsSet: Set<String> { Set(savedWords.keys) }

    func isSaved(_ word: String) -> Bool { savedWords[word.lowercased()] != nil }

    func contexts(for word: String) -> [WordContext] {
        savedWords[word.lowercased()]?.contexts ?? []
    }

    // MARK: - Mutations

    func save(_ word: String, context: WordContext? = nil, languageID: String = "tr") {
        let key = word.lowercased()
        if var existing = savedWords[key] {
            if let context, !existing.contexts.contains(context) {
                existing.contexts.append(context)
                savedWords[key] = existing
            }
        } else {
            let contexts = context.map { [$0] } ?? []
            savedWords[key] = SavedWord(word: word, contexts: contexts)
        }
        persist()
        SharedVocabularyBridge.save(word: word, languageID: languageID)
    }

    func remove(_ word: String, languageID: String = "tr") {
        savedWords.removeValue(forKey: word.lowercased())
        persist()
        SharedVocabularyBridge.remove(word: word, languageID: languageID)
    }

    // MARK: - Persistence

    private func load() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: SavedWord].self, from: data) {
            savedWords = decoded
            return
        }

        if let data = defaults.data(forKey: legacyDictKey),
           let decoded = try? JSONDecoder().decode([String: SavedWord].self, from: data) {
            savedWords = decoded
            persist()
            defaults.removeObject(forKey: legacyDictKey)
            return
        }

        if let legacy = defaults.stringArray(forKey: legacyStringSetKey) {
            var dict: [String: SavedWord] = [:]
            for w in legacy {
                let key = w.lowercased()
                dict[key] = SavedWord(word: w)
            }
            savedWords = dict
            persist()
            defaults.removeObject(forKey: legacyStringSetKey)
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(savedWords) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
