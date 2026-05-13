import Foundation
import Combine

// MARK: - UserSettingsStore
// Single source of truth for all user preferences.
// New languages / settings should be added here, nowhere else.

@MainActor
final class UserSettingsStore: ObservableObject {

    // MARK: Published
    @Published var nativeLanguage: NativeLanguage {
        didSet { UserDefaults.standard.set(nativeLanguage.id, forKey: Keys.nativeLanguage) }
    }

    @Published var selectedLevel: CEFRLevel {
        didSet { UserDefaults.standard.set(selectedLevel.rawValue, forKey: Keys.selectedLevel) }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    // MARK: Init
    init() {
        Self.migrateLegacyKeysIfNeeded()

        let langID  = UserDefaults.standard.string(forKey: Keys.nativeLanguage) ?? ""
        let levelRW = UserDefaults.standard.string(forKey: Keys.selectedLevel) ?? ""

        nativeLanguage         = NativeLanguage.find(id: langID)
        selectedLevel          = CEFRLevel(rawValue: levelRW) ?? .B1
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
    }

    // MARK: Keys
    private enum Keys {
        static let nativeLanguage = "wislynews.nativeLanguage"
        static let selectedLevel  = "wislynews.selectedLevel"
        static let onboarding     = "wislynews.onboardingDone"
    }

    private enum LegacyKeys {
        static let nativeLanguage = "lexinews.nativeLanguage"
        static let selectedLevel  = "lexinews.selectedLevel"
        static let onboarding     = "lexinews.onboardingDone"
    }

    private static func migrateLegacyKeysIfNeeded() {
        let defaults = UserDefaults.standard
        let pairs: [(legacy: String, new: String)] = [
            (LegacyKeys.nativeLanguage, Keys.nativeLanguage),
            (LegacyKeys.selectedLevel,  Keys.selectedLevel),
            (LegacyKeys.onboarding,     Keys.onboarding),
        ]
        for pair in pairs {
            guard defaults.object(forKey: pair.new) == nil,
                  let value = defaults.object(forKey: pair.legacy) else { continue }
            defaults.set(value, forKey: pair.new)
            defaults.removeObject(forKey: pair.legacy)
        }
    }
}
