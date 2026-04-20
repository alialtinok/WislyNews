import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var articleStore:    ArticleStore
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var readingStore:    ReadingStore

    var body: some View {
        NavigationStack {
            List {
                streakSection
                Section("Seviye") {
                    Picker("Varsayılan Seviye", selection: $articleStore.selectedLevel) {
                        ForEach(CEFRLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                }
                Section("İstatistikler") {
                    LabeledContent("Kayıtlı Kelime",    value: "\(vocabularyStore.savedWords.count)")
                    LabeledContent("Okunan Haber",       value: "\(readingStore.totalArticlesRead)")
                    LabeledContent("Bugün Okunan",       value: "\(readingStore.todayCount)")
                    LabeledContent("Toplam Haber",       value: "\(articleStore.articles.count)")
                }
                Section {
                    Link("Gizlilik Politikası", destination: URL(string: "https://example.com/privacy")!)
                    Link("Destek", destination: URL(string: "mailto:lexinewsapp@gmail.com")!)
                }
            }
            .navigationTitle("Profil")
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
                    Text(readingStore.currentStreak == 1 ? "günlük seri" : "günlük seri")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}
