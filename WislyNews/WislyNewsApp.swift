import SwiftUI

@main
struct WislyNewsApp: App {
    @StateObject private var articleStore    = ArticleStore()
    @StateObject private var vocabularyStore = VocabularyStore()
    @StateObject private var readingStore    = ReadingStore()
    @StateObject private var speechService   = SpeechService()
    @StateObject private var settings        = UserSettingsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(articleStore)
                .environmentObject(vocabularyStore)
                .environmentObject(readingStore)
                .environmentObject(speechService)
                .environmentObject(settings)
        }
    }
}

// MARK: - RootView
// Onboarding tamamlanmadıysa OnboardingView, tamamlandıysa MainTabView gösterir.

private struct RootView: View {
    @EnvironmentObject private var settings:     UserSettingsStore
    @EnvironmentObject private var articleStore: ArticleStore

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                MainTabView()
                    .task { await articleStore.load() }
            } else {
                OnboardingView()
            }
        }
        .environment(\.str, AppStrings.from(settings.nativeLanguage))
        .animation(.easeInOut(duration: 0.4), value: settings.hasCompletedOnboarding)
    }
}

