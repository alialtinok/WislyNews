import SwiftUI

// MARK: - App Theme

enum Theme {
    static let backgroundTop = Color(hex: "#040815")
    static let backgroundBottom = Color(hex: "#07142B")
    static let electricBlue = Color(hex: "#0A74FF")
    static let cyanGlow = Color(hex: "#00B7FF")
    static let purpleGlow = Color(hex: "#8E4DFF")
    static let orangeGlow = Color(hex: "#FF8A00")
    static let glass = Color.white.opacity(0.09)
    static let glassStrong = Color.white.opacity(0.14)
    static let hairline = Color.white.opacity(0.18)

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

// MARK: - Neon theme building blocks

struct WislyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundTop, Theme.backgroundBottom, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [Theme.electricBlue.opacity(0.16), .clear],
                startPoint: .topTrailing,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }
}

struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = 18
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? Theme.electricBlue.opacity(0.16) : Theme.glass)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(isSelected ? Theme.electricBlue : Theme.hairline, lineWidth: isSelected ? 1.4 : 1)
                    )
                    .shadow(color: isSelected ? Theme.electricBlue.opacity(0.35) : .black.opacity(0.2),
                            radius: isSelected ? 14 : 8,
                            x: 0,
                            y: 6)
            )
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 18, isSelected: Bool = false) -> some View {
        modifier(GlassPanel(cornerRadius: cornerRadius, isSelected: isSelected))
    }
}

struct NeonIconBadge: View {
    let systemName: String
    var tint: Color = Theme.electricBlue
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(tint.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .stroke(tint, lineWidth: 1.6)
                )
                .shadow(color: tint.opacity(0.42), radius: 12)
            Image(systemName: systemName)
                .font(.system(size: size * 0.46, weight: .bold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

struct NeonPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(colors: [Theme.electricBlue, Color(hex: "#145BFF")],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Theme.electricBlue.opacity(0.45), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
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
