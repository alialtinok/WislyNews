import SwiftUI

struct ArticleCard: View {
    let article: Article
    let level: CEFRLevel
    private var version: ArticleVersion? { article.version(for: level) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Category + date
            HStack(alignment: .center) {
                CategoryPill(category: article.category)
                Spacer()
                Text(article.published, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Title
            Text(version?.title ?? article.originalTitle)
                .font(Theme.Font.cardTitle)
                .lineLimit(3)
                .foregroundStyle(.primary)

            // Body preview
            if let body = version?.body {
                Text(body)
                    .font(Theme.Font.cardBody)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }

            // Level badges
            HStack(spacing: 6) {
                ForEach(article.availableLevels, id: \.self) { lvl in
                    LevelBadge(level: lvl, isActive: lvl == level)
                }
                Spacer()
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: String
    var body: some View {
        Text(category.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.categoryColor(category).opacity(0.12))
            .foregroundStyle(Theme.categoryColor(category))
            .clipShape(Capsule())
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let level: CEFRLevel
    var isActive: Bool = false

    var body: some View {
        Text(level.label)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(isActive ? Theme.levelColor(level) : Theme.levelColor(level).opacity(0.12))
            .foregroundStyle(isActive ? .white : Theme.levelColor(level))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
