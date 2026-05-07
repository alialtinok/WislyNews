import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var articleStore:    ArticleStore
    @EnvironmentObject private var settings:        UserSettingsStore
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var readingStore:    ReadingStore
    @Environment(\.str) private var str

    var body: some View {
        NavigationStack {
            List {
                streakSection
                Section(str.sectionLevel) {
                    Picker(str.defaultLevel, selection: $settings.selectedLevel) {
                        ForEach(CEFRLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                }
                Section(str.sectionLanguage) {
                    Picker(str.nativeLanguage, selection: $settings.nativeLanguage) {
                        ForEach(NativeLanguage.all) { lang in
                            Text("\(lang.flag) \(lang.name)").tag(lang)
                        }
                    }
                }
                Section(str.sectionStats) {
                    LabeledContent(str.statSavedWords,   value: "\(vocabularyStore.savedWords.count)")
                    LabeledContent(str.statReadArticles, value: "\(readingStore.totalArticlesRead)")
                    LabeledContent(str.statTodayRead,    value: "\(readingStore.todayCount)")
                    LabeledContent(str.statTotalNews,    value: "\(articleStore.articles.count)")
                }
                Section {
                    Link(str.privacyPolicy, destination: URL(string: "https://alialtinok.github.io/lexinews-privacy/")!)
                    Link(str.support,       destination: URL(string: "mailto:lexinewsapp@gmail.com")!)
                }
            }
            .navigationTitle(str.profileTitle)
        }
    }

    private var streakSection: some View {
        Section {
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(readingStore.currentStreak)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(readingStore.currentStreak > 0 ? Color.orange : Color.secondary)
                        Text("🔥")
                            .font(.system(size: 32))
                            .opacity(readingStore.currentStreak > 0 ? 1 : 0.3)
                    }
                    Text(str.streakLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}
