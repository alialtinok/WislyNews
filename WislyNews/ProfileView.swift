import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var articleStore:    ArticleStore
    @EnvironmentObject private var settings:        UserSettingsStore
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var readingStore:    ReadingStore
    @Environment(\.str) private var str

    var body: some View {
        NavigationStack {
            ZStack {
                WislyBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(str.profileTitle)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 8)
                        streakSection
                        settingsSection(title: str.sectionLevel) {
                            Picker(str.defaultLevel, selection: $settings.selectedLevel) {
                                ForEach(CEFRLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                            }
                            .tint(.white)
                        }
                        settingsSection(title: str.sectionLanguage) {
                            Picker(str.nativeLanguage, selection: $settings.nativeLanguage) {
                                ForEach(NativeLanguage.all) { lang in
                                    Text("\(lang.id.uppercased())  \(lang.name)").tag(lang)
                                }
                            }
                            .tint(.white)
                        }
                        settingsSection(title: str.sectionStats) {
                            statRow(str.statSavedWords, "\(vocabularyStore.savedWords.count)")
                            statRow(str.statReadArticles, "\(readingStore.totalArticlesRead)")
                            statRow(str.statTodayRead, "\(readingStore.todayCount)")
                            statRow(str.statTotalNews, "\(articleStore.articles.count)")
                        }
                        settingsSection(title: "") {
                            Link(str.privacyPolicy, destination: URL(string: "https://alialtinok.github.io/wisly-privacy/")!)
                            Divider().overlay(Theme.hairline)
                            Link(str.support, destination: URL(string: "mailto:elothgoldarrow@gmail.com")!)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var streakSection: some View {
        HStack(spacing: 14) {
            NeonIconBadge(systemName: "flame.fill", tint: Theme.orangeGlow, size: 54)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(readingStore.currentStreak)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(readingStore.currentStreak > 0 ? Theme.orangeGlow : .white.opacity(0.55))
                Text(str.streakLabel)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.66))
            }
            Spacer()
        }
        .padding(16)
        .glassPanel(cornerRadius: 20, isSelected: readingStore.currentStreak > 0)
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            VStack(spacing: 10) {
                content()
                    .foregroundStyle(.white)
            }
            .padding(14)
            .glassPanel(cornerRadius: 16)
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.74))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .font(.subheadline)
    }
}
