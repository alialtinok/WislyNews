import Foundation

struct WordContext: Codable, Hashable {
    let sentence: String
    let articleID: String
    let articleTitle: String
    let capturedAt: Date
}

struct SavedWord: Codable, Identifiable, Hashable {
    let id: String
    let word: String
    var contexts: [WordContext]
    let firstSavedAt: Date

    init(word: String, contexts: [WordContext] = [], firstSavedAt: Date = Date()) {
        self.id = word.lowercased()
        self.word = word
        self.contexts = contexts
        self.firstSavedAt = firstSavedAt
    }
}
