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
        .ignoresSafeArea()
        .animation(.easeInOut, value: page)
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    @Binding var page: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                OnboardingIconBadge(systemName: "newspaper.fill", size: 56)
                Text("Wisly News")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                Text("Read real news.\nLearn real English.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
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
            Button { withAnimation { page = 1 } } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
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
                .foregroundStyle(.primary)
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
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 8) {
                OnboardingIconBadge(systemName: "a.square", size: 44)
                Text("Your language")
                    .font(.system(size: 28, weight: .bold))
                Text("Translations will appear in\nyour native language.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
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

            Button { withAnimation { page = 2 } } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
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
                LanguageCodeBadge(code: language.id.uppercased())
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name).font(.headline)
                    Text(language.nameInEnglish).font(.caption).foregroundStyle(.secondary)
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
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                    )
            )
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
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 8) {
                OnboardingIconBadge(systemName: "chart.bar.fill", size: 44)
                Text("Your level")
                    .font(.system(size: 28, weight: .bold))
                Text("You can change this anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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

            Button {
                settings.hasCompletedOnboarding = true
            } label: {
                Text("Start Reading")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
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
                    Text(label).font(.subheadline.weight(.semibold))
                    Text(description).font(.caption).foregroundStyle(.secondary)
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
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingIconBadge: View {
    let systemName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: 2.5)
                .frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
    }
}

private struct LanguageCodeBadge: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(Color.accentColor)
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.12))
            )
    }
}
