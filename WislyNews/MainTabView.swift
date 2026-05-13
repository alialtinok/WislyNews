import SwiftUI

struct MainTabView: View {
    @Environment(\.str) private var str

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label(str.tabNews,    systemImage: "newspaper") }
            VocabularyView()
                .tabItem { Label(str.tabMyWords, systemImage: "books.vertical") }
            ProfileView()
                .tabItem { Label(str.tabProfile, systemImage: "person") }
        }
        .tint(Theme.electricBlue)
        .preferredColorScheme(.dark)
        .toolbarBackground(Theme.backgroundTop, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
