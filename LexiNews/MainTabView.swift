import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Haberler", systemImage: "newspaper") }
            VocabularyView()
                .tabItem { Label("Kelimelerim", systemImage: "books.vertical") }
            ProfileView()
                .tabItem { Label("Profil", systemImage: "person") }
        }
    }
}
