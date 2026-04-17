import SwiftUI

// MARK: - Color Tokens

extension Color {
    static let easeBg            = Color(red: 0.953, green: 0.937, blue: 0.914) // warm cream
    static let easeCard          = Color(red: 0.984, green: 0.973, blue: 0.959) // lighter warm white
    static let easeAccent        = Color(red: 0.808, green: 0.478, blue: 0.227) // terracotta
    static let easeNavy          = Color(red: 0.216, green: 0.282, blue: 0.369) // dusty navy
    static let easeSage          = Color(red: 0.482, green: 0.608, blue: 0.478) // sage
    static let easeTextPrimary   = Color(red: 0.192, green: 0.157, blue: 0.125) // warm dark brown
    static let easeTextSecondary = Color(red: 0.510, green: 0.459, blue: 0.408) // medium warm brown
    static let easeSymptom       = Color(red: 0.643, green: 0.349, blue: 0.314) // dusty terracotta-rose
    static let easeDivider       = Color(red: 0.871, green: 0.847, blue: 0.816) // warm divider
}

// MARK: - Tag Button Style

struct TagButtonStyle: ButtonStyle {
    let isSelected: Bool
    var selectedColor: Color = .easeAccent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? selectedColor : Color.easeCard)
            .foregroundStyle(isSelected ? Color.white : Color.easeTextSecondary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.easeDivider, lineWidth: 1)
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Form Section Card

struct FormSection<Content: View>: View {
    let title: String?
    let content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.easeTextSecondary)
                    .tracking(0.8)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.easeCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Horizontal Tag Row (Detail View)

struct TagPillRow: View {
    let tags: [String]
    let foreground: Color
    let background: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(background)
                        .foregroundStyle(foreground)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Record Row View (List + Calendar)

struct RecordRowView: View {
    let record: MealRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(record.date, style: .time)
                .font(.caption.monospacedDigit())
                .foregroundStyle(Color.easeTextSecondary)
                .frame(width: 46, alignment: .leading)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(record.mealType.rawValue)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.easeAccent.opacity(0.12))
                        .foregroundStyle(Color.easeAccent)
                        .clipShape(Capsule())

                    if let diningType = record.diningType {
                        Text(diningType.rawValue)
                            .font(.caption)
                            .foregroundStyle(Color.easeTextSecondary)
                    }
                }

                if !record.foodSummary.isEmpty {
                    Text(record.foodSummary)
                        .font(.subheadline)
                        .foregroundStyle(Color.easeTextPrimary)
                        .lineLimit(1)
                }

                if record.hasSymptoms {
                    Text(record.symptomEmojis)
                        .font(.subheadline)
                } else {
                    Text("無症狀")
                        .font(.caption)
                        .foregroundStyle(Color.easeTextSecondary.opacity(0.6))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
