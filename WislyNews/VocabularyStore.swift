import Foundation
import Combine

@MainActor
final class VocabularyStore: ObservableObject {

    @Published private(set) var savedWords: Set<String> = []
    private let storageKey = "lexinews.savedWords"

    init() { load() }

    func isSaved(_ word: String) -> Bool { savedWords.contains(word.lowercased()) }

    func save(_ word: String, languageID: String = "tr") {
        savedWords.insert(word.lowercased())
        persist()
        SharedVocabularyBridge.save(word: word, languageID: languageID)
    }

    func remove(_ word: String, languageID: String = "tr") {
        savedWords.remove(word.lowercased())
        persist()
        SharedVocabularyBridge.remove(word: word, languageID: languageID)
    }

    private func load() {
        savedWords = Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }

    private func persist() {
        UserDefaults.standard.set(Array(savedWords), forKey: storageKey)
    }
}
