import SwiftUI

struct VocabularyView: View {
    @EnvironmentObject private var store: VocabularyStore
    @State private var tappedWord: String? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.savedWords.isEmpty {
                    ContentUnavailableView(
                        "Henüz kelime yok",
                        systemImage: "books.vertical",
                        description: Text("Haber okurken kelimelere tıkla, buraya kaydet.")
                    )
                } else {
                    List {
                        ForEach(store.savedWords.sorted(), id: \.self) { word in
                            Button(word) { tappedWord = word }.foregroundStyle(.primary)
                        }
                        .onDelete { idx in
                            let sorted = store.savedWords.sorted()
                            idx.forEach { store.remove(sorted[$0]) }
                        }
                    }
                }
            }
            .navigationTitle("Kelimelerim")
        }
        .sheet(item: $tappedWord) { word in
            WordPopupSheet(word: word).environmentObject(store)
        }
    }
}
