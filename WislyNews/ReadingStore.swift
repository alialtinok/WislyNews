import Foundation
import Combine

@MainActor
final class ReadingStore: ObservableObject {

    @Published private(set) var readEntries: Set<String> = []
    private let storageKey       = "wislynews.readEntries"
    private let legacyStorageKey = "lexinews.readEntries"

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() { load() }

    // MARK: - Public API

    func markRead(articleID: String, date: Date = .now) {
        let entry = key(articleID: articleID, date: date)
        guard !readEntries.contains(entry) else { return }
        readEntries.insert(entry)
        persist()
    }

    func isRead(_ articleID: String, date: Date = .now) -> Bool {
        readEntries.contains(key(articleID: articleID, date: date))
    }

    var todayCount: Int {
        let prefix = Self.dateFormatter.string(from: .now) + "|"
        return readEntries.filter { $0.hasPrefix(prefix) }.count
    }

    var currentStreak: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: .now)
        let calendar = Calendar.current

        while true {
            let dayStr = Self.dateFormatter.string(from: date)
            let hasRead = readEntries.contains { $0.hasPrefix(dayStr + "|") }
            if hasRead {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak
    }

    var totalArticlesRead: Int {
        Set(readEntries.map { $0.components(separatedBy: "|").last ?? "" })
            .filter { !$0.isEmpty }.count
    }

    // MARK: - Private

    private func key(articleID: String, date: Date) -> String {
        "\(Self.dateFormatter.string(from: date))|\(articleID)"
    }

    private func load() {
        let defaults = UserDefaults.standard
        if let entries = defaults.stringArray(forKey: storageKey) {
            readEntries = Set(entries)
            return
        }
        if let legacy = defaults.stringArray(forKey: legacyStorageKey) {
            readEntries = Set(legacy)
            persist()
            defaults.removeObject(forKey: legacyStorageKey)
        }
    }

    private func persist() {
        UserDefaults.standard.set(Array(readEntries), forKey: storageKey)
    }
}
