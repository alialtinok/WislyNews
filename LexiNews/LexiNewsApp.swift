import SwiftUI

@main
struct LexiNewsApp: App {
    @StateObject private var articleStore    = ArticleStore()
    @StateObject private var vocabularyStore = VocabularyStore()
    @StateObject private var readingStore    = ReadingStore()
    @StateObject private var speechService   = SpeechService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(articleStore)
                .environmentObject(vocabularyStore)
                .environmentObject(readingStore)
                .environmentObject(speechService)
                .task { await articleStore.load() }
        }
    }
}
