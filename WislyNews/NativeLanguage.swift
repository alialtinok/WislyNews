import Foundation

// MARK: - NativeLanguage

struct NativeLanguage: Identifiable, Codable, Hashable {
    let id: String            // BCP-47 code  e.g. "tr"
    let name: String          // Display name in that language e.g. "Türkçe"
    let nameInEnglish: String // e.g. "Turkish"
    let flag: String          // Emoji flag
    let translationCode: String // MyMemory target code e.g. "tr"

    // MARK: Supported languages
    static let all: [NativeLanguage] = [
        NativeLanguage(id: "tr", name: "Türkçe",    nameInEnglish: "Turkish", flag: "🇹🇷", translationCode: "tr"),
        NativeLanguage(id: "fr", name: "Français",  nameInEnglish: "French",  flag: "🇫🇷", translationCode: "fr"),
        NativeLanguage(id: "ru", name: "Русский",   nameInEnglish: "Russian", flag: "🇷🇺", translationCode: "ru"),
        NativeLanguage(id: "de", name: "Deutsch",   nameInEnglish: "German",  flag: "🇩🇪", translationCode: "de"),
        NativeLanguage(id: "ar", name: "العربية",   nameInEnglish: "Arabic",  flag: "🇸🇦", translationCode: "ar"),
        NativeLanguage(id: "es", name: "Español",   nameInEnglish: "Spanish", flag: "🇪🇸", translationCode: "es"),
    ]

    static let `default` = all[0] // Turkish

    static func find(id: String) -> NativeLanguage {
        all.first { $0.id == id } ?? .default
    }
}
