import Foundation
import Combine

@MainActor
final class VocabularyStore: ObservableObject {

    @Published private(set) var savedWords: Set<String> = []
    private let storageKey = "lexinews.savedWords"

    init() { load() }

    func isSaved(_ word: String) -> Bool { savedWords.contains(word.lowercased()) }
    func save(_ word: String)   { savedWords.insert(word.lowercased()); persist() }
    func remove(_ word: String) { savedWords.remove(word.lowercased()); persist() }

    private func load() {
        savedWords = Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }
    private func persist() {
        UserDefaults.standard.set(Array(savedWords), forKey: storageKey)
    }
}
