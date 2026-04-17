import SwiftUI

// MARK: - Tag Button Style

struct TagButtonStyle: ButtonStyle {
    let isSelected: Bool
    var selectedColor: Color = .orange

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? selectedColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Record Row View (used in List + Calendar)

struct RecordRowView: View {
    let record: MealRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(record.mealType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(Color.orange)
                    .clipShape(Capsule())
            }

            if !record.foodSummary.isEmpty {
                Text(record.foodSummary)
                    .font(.subheadline)
                    .lineLimit(1)
            }

            if record.hasSymptoms {
                Text(record.symptomEmojis)
                    .font(.subheadline)
            } else {
                Text("無症狀")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
