import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: UserSettingsStore
    @State private var page: Int = 0

    var body: some View {
        TabView(selection: $page) {
            WelcomePage(page: $page).tag(0)
            LanguagePage(page: $page).tag(1)
            LevelPage().tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .animation(.easeInOut, value: page)
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    @Binding var page: Int

    var body: some View {
        ZStack {
            WislyBackground()
            VStack(spacing: 0) {
                Spacer(minLength: 28)
                VStack(spacing: 20) {
                NeonIconBadge(systemName: "newspaper.fill", size: 64)
                Text("Wisly News")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text("Read real news.\nLearn real English.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            VStack(spacing: 12) {
                featureRow(icon: "magnifyingglass",       text: "Tap any word for instant translation")
                featureRow(icon: "chart.bar.fill",        text: "Choose your CEFR level — A2 to C1")
                featureRow(icon: "flame.fill",            text: "Build a daily reading streak")
                featureRow(icon: "bookmark.fill",         text: "Saved words sync with Wisly automatically")
            }
            .padding(.horizontal, 32)
            Spacer()
            NeonPrimaryButton(title: "Get Started") { withAnimation { page = 1 } }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.86))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Page 2: Language Selection

private struct LanguagePage: View {
    @EnvironmentObject private var settings: UserSettingsStore
    @Binding var page: Int

    var body: some View {
        ZStack {
            WislyBackground()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 12) {
                NeonIconBadge(systemName: "globe", size: 72)
                Text("Your language")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text("Translations will appear in\nyour native language.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(.bottom, 32)

            VStack(spacing: 12) {
                ForEach(NativeLanguage.all) { lang in
                    LanguageCard(
                        language: lang,
                        isSelected: settings.nativeLanguage.id == lang.id
                    ) {
                        settings.nativeLanguage = lang
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            NeonPrimaryButton(title: "Continue") { withAnimation { page = 2 } }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            }
        }
    }
}

private struct LanguageCard: View {
    let language: NativeLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                LanguageCodeBadge(language: language)
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name).font(.headline).foregroundStyle(.white)
                    Text(language.nameInEnglish).font(.caption).foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassPanel(cornerRadius: 16, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Page 3: Level Selection

private struct LevelPage: View {
    @EnvironmentObject private var settings: UserSettingsStore

    private let levels: [(CEFRLevel, String, String)] = [
        (.A2, "Elementary",        "Basic everyday topics"),
        (.B1, "Intermediate",      "Common situations"),
        (.B2, "Upper-Intermediate","Wider range of topics"),
        (.C1, "Advanced",          "Complex, detailed texts"),
    ]

    var body: some View {
        ZStack {
            WislyBackground()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 12) {
                NeonIconBadge(systemName: "chart.bar.fill", size: 72)
                Text("Your level")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text("You can change this anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(.bottom, 28)

            VStack(spacing: 10) {
                ForEach(levels, id: \.0) { level, label, desc in
                    LevelCard(
                        level: level,
                        label: label,
                        description: desc,
                        isSelected: settings.selectedLevel == level
                    ) {
                        settings.selectedLevel = level
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            NeonPrimaryButton(title: "Start Reading") {
                settings.hasCompletedOnboarding = true
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            }
        }
    }
}

private struct LevelCard: View {
    let level: CEFRLevel
    let label: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(level.rawValue)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .foregroundStyle(isSelected ? Color.white : Theme.levelColor(level))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Theme.levelColor(level) : Theme.levelColor(level).opacity(0.12))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    Text(description).font(.caption).foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassPanel(cornerRadius: 14, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

private struct LanguageCodeBadge: View {
    let language: NativeLanguage

    private var symbol: String {
        switch language.id {
        case "tr": return "moon.stars.fill"
        case "fr": return "a.square.fill"
        case "ru": return "building.columns.fill"
        case "de": return "building.columns"
        case "ar": return "crescentmoon.fill"
        case "es": return "sun.max.fill"
        default:   return "a.square"
        }
    }

    private var tint: Color {
        switch language.id {
        case "tr": return Color(hex: "#FF3448")
        case "fr": return Theme.electricBlue
        case "ru": return Theme.purpleGlow
        case "de": return Theme.orangeGlow
        case "ar": return Color(hex: "#28C76F")
        case "es": return Color(hex: "#FFC400")
        default:   return Theme.electricBlue
        }
    }

    var body: some View {
        NeonIconBadge(systemName: symbol, tint: tint, size: 48)
    }
}
