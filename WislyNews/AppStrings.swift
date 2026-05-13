import SwiftUI

// MARK: - AppStrings
// Add new UI strings here. Two static instances: turkish & english.
// For a new language: add a new static instance and update NativeLanguage.swift.

struct AppStrings {

    // MARK: Tab Bar
    let tabNews:       String
    let tabMyWords:    String
    let tabProfile:    String

    // MARK: Home
    let loadingNews:   String
    let filterAll:     String
    let levelLabel:    String
    let retryButton:   String
    let noNewsError:   String

    // MARK: Article Detail
    let keyVocabulary: String
    let readOriginal:  String
    let noContent:     String

    // MARK: Word Popup
    let wordTitle:          String
    let closeButton:        String
    let saveWord:           String
    let removeWord:         String
    let translationMissing: String

    // MARK: Vocabulary
    let vocabEmpty:       String
    let vocabEmptyDesc:   String

    // MARK: Profile
    let profileTitle:     String
    let sectionLevel:     String
    let defaultLevel:     String
    let sectionLanguage:  String
    let nativeLanguage:   String
    let sectionStats:     String
    let statSavedWords:   String
    let statReadArticles: String
    let statTodayRead:    String
    let statTotalNews:    String
    let streakLabel:      String
    let privacyPolicy:    String
    let support:          String
}

// MARK: - Turkish

extension AppStrings {
    static let turkish = AppStrings(
        tabNews:          "Haberler",
        tabMyWords:       "Kelimelerim",
        tabProfile:       "Profil",

        loadingNews:      "Haberler yükleniyor…",
        filterAll:        "Tümü",
        levelLabel:       "Seviye",
        retryButton:      "Tekrar Dene",
        noNewsError:      "Haber bulunamadı.",

        keyVocabulary:    "Anahtar Kelimeler",
        readOriginal:     "Orijinal haberi oku",
        noContent:        "Bu seviyede içerik bulunamadı.",

        wordTitle:          "Kelime",
        closeButton:        "Kapat",
        saveWord:           "Kelimeyi Kaydet",
        removeWord:         "Kaydedilenlerden Çıkar",
        translationMissing: "Çeviri bulunamadı",

        vocabEmpty:       "Henüz kelime yok",
        vocabEmptyDesc:   "Haber okurken kelimelere tıkla, buraya kaydet.",

        profileTitle:     "Profil",
        sectionLevel:     "Seviye",
        defaultLevel:     "Varsayılan Seviye",
        sectionLanguage:  "Dil",
        nativeLanguage:   "Ana Dil",
        sectionStats:     "İstatistikler",
        statSavedWords:   "Kayıtlı Kelime",
        statReadArticles: "Okunan Haber",
        statTodayRead:    "Bugün Okunan",
        statTotalNews:    "Toplam Haber",
        streakLabel:      "günlük seri",
        privacyPolicy:    "Gizlilik Politikası",
        support:          "Destek"
    )
}

// MARK: - English

extension AppStrings {
    static let english = AppStrings(
        tabNews:          "News",
        tabMyWords:       "My Words",
        tabProfile:       "Profile",

        loadingNews:      "Loading news…",
        filterAll:        "All",
        levelLabel:       "Level",
        retryButton:      "Retry",
        noNewsError:      "No articles found.",

        keyVocabulary:    "Key Vocabulary",
        readOriginal:     "Read original article",
        noContent:        "No content available at this level.",

        wordTitle:          "Word",
        closeButton:        "Close",
        saveWord:           "Save Word",
        removeWord:         "Remove from Saved",
        translationMissing: "Translation not found",

        vocabEmpty:       "No words yet",
        vocabEmptyDesc:   "Tap words while reading to save them here.",

        profileTitle:     "Profile",
        sectionLevel:     "Level",
        defaultLevel:     "Default Level",
        sectionLanguage:  "Language",
        nativeLanguage:   "Native Language",
        sectionStats:     "Statistics",
        statSavedWords:   "Saved Words",
        statReadArticles: "Articles Read",
        statTodayRead:    "Read Today",
        statTotalNews:    "Total Articles",
        streakLabel:      "day streak",
        privacyPolicy:    "Privacy Policy",
        support:          "Support"
    )
}

// MARK: - Language resolver

extension AppStrings {
    static func from(_ language: NativeLanguage) -> AppStrings {
        language.id == "tr" ? .turkish : .english
    }
}

// MARK: - SwiftUI Environment

private struct AppStringsKey: EnvironmentKey {
    static let defaultValue: AppStrings = .english
}

extension EnvironmentValues {
    var str: AppStrings {
        get { self[AppStringsKey.self] }
        set { self[AppStringsKey.self] = newValue }
    }
}
