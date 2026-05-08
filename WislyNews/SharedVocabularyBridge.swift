import Foundation

// MARK: - Shared Vocabulary Bridge (WislyNews side)
//
// Writes vocabulary words saved by the user in WislyNews to a shared
// App Group container so Wisly Vocabulary can read and import them.
//
// App Group: group.com.wisly.shared
// Key:       "wisly.sharedVocabulary"
// Format:    JSON array of SharedVocabularyItem

struct SharedVocabularyItem: Codable, Identifiable {
    let id: String        // stable identifier (word + languageID)
    let word: String
    let languageID: String
    let savedAt: Date

    init(word: String, languageID: String) {
        self.id = "\(languageID)|\(word.lowercased())"
        self.word = word
        self.languageID = languageID
        self.savedAt = Date()
    }
}

enum SharedVocabularyBridge {

    private static let appGroupID  = "group.com.wisly.shared"
    private static let storageKey  = "wisly.sharedVocabulary"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Read

    static func loadAll() -> [SharedVocabularyItem] {
        guard
            let defaults,
            let data = defaults.data(forKey: storageKey),
            let items = try? JSONDecoder().decode([SharedVocabularyItem].self, from: data)
        else { return [] }
        return items
    }

    // MARK: - Write

    /// Adds or updates a single word. No-ops if already present.
    static func save(word: String, languageID: String) {
        var items = loadAll()
        let newItem = SharedVocabularyItem(word: word, languageID: languageID)
        guard !items.contains(where: { $0.id == newItem.id }) else { return }
        items.append(newItem)
        persist(items)
    }

    /// Removes a word from the shared store.
    static func remove(word: String, languageID: String) {
        let targetID = "\(languageID)|\(word.lowercased())"
        let items = loadAll().filter { $0.id != targetID }
        persist(items)
    }

    // MARK: - Private

    private static func persist(_ items: [SharedVocabularyItem]) {
        guard
            let defaults,
            let data = try? JSONEncoder().encode(items)
        else { return }
        defaults.set(data, forKey: storageKey)
    }
}
