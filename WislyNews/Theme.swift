import SwiftUI

// MARK: - App Theme

enum AppThemePreference: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

enum Theme {

    // MARK: Level colors
    static func levelColor(_ level: CEFRLevel) -> Color {
        switch level {
        case .A2: return Color(hex: "#34C759") // green
        case .B1: return Color(hex: "#007AFF") // blue
        case .B2: return Color(hex: "#FF9500") // orange
        case .C1: return Color(hex: "#FF3B30") // red
        }
    }

    // MARK: Category colors
    static func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "world":    return Color(hex: "#007AFF")
        case "sports":   return Color(hex: "#34C759")
        case "science":  return Color(hex: "#AF52DE")
        case "culture":  return Color(hex: "#FF9500")
        case "business": return Color(hex: "#FF3B30")
        case "tech":     return Color(hex: "#5AC8FA")
        default:         return .secondary
        }
    }

    // MARK: Typography
    enum Font {
        static let cardTitle    = SwiftUI.Font.system(.headline,    design: .serif,     weight: .semibold)
        static let cardBody     = SwiftUI.Font.system(.subheadline, design: .default,   weight: .regular)
        static let articleTitle = SwiftUI.Font.system(.title2,      design: .serif,     weight: .bold)
        static let articleBody  = SwiftUI.Font.system(size: 17,     weight: .regular, design: .default)
    }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
