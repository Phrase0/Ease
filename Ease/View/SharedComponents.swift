//
//  SharedComponents.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

// MARK: - Color Tokens

extension Color {
    static let easeBg            = Color(red: 0.953, green: 0.937, blue: 0.914) // warm cream 溫暖的米色背景
    static let easeCard          = Color(red: 0.984, green: 0.973, blue: 0.959) // lighter warm white 較淺的暖白色（卡片用）
    static let easeAccent        = Color(red: 0.808, green: 0.478, blue: 0.227) // terracotta 陶土色（重點色）
    static let easeTextPrimary   = Color(red: 0.192, green: 0.157, blue: 0.125) // warm dark brown 主要文字（暖深棕）
    static let easeTextSecondary = Color(red: 0.510, green: 0.459, blue: 0.408) // medium warm brown 次要文字（中等暖棕）
    static let easeSymptom       = Color(red: 0.671, green: 0.416, blue: 0.329) // deep brick-red 症狀色（深磚紅）
    static let easeHealthy       = Color(red: 0.725, green: 0.725, blue: 0.616) // muted sage green 健康色（鼠尾草綠）
    static let easeDivider       = Color(red: 0.871, green: 0.847, blue: 0.816) // warm divider 分隔線（暖灰色）
}

// MARK: - Tag Button Style

struct TagButtonStyle: ButtonStyle {
    let isSelected: Bool
    var selectedColor: Color = .easeAccent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? selectedColor : Color.easeBg)
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

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(subviews: subviews, in: proposal.width ?? 0).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(subviews: subviews, in: bounds.width)
        for (subview, point) in zip(subviews, result.origins) {
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func layout(subviews: Subviews, in maxWidth: CGFloat) -> (origins: [CGPoint], size: CGSize) {
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return (origins, CGSize(width: maxWidth, height: y + lineHeight))
    }
}

// MARK: - Equal Tag Grid (3-per-row, equal width, last row padded)

struct EqualTagGrid<Item: Hashable>: View {
    let items: [Item]
    let label: (Item) -> String
    let isSelected: (Item) -> Bool
    let onTap: (Item) -> Void
    var selectedColor: Color = .easeAccent

    private let columns = 3
    private let spacing: CGFloat = 8

    private var rows: [[Item?]] {
        let padded = ((items.count + columns - 1) / columns) * columns
        return stride(from: 0, to: padded, by: columns).map { start in
            (0..<columns).map { offset -> Item? in
                let i = start + offset
                return i < items.count ? items[i] : nil
            }
        }
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, item in
                        if let item {
                            Button(label(item)) { onTap(item) }
                                .buttonStyle(TagButtonStyle(
                                    isSelected: isSelected(item),
                                    selectedColor: selectedColor
                                ))
                                .frame(maxWidth: .infinity)
                        } else {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Wrapping Tag Row (Detail View)

struct TagPillRow: View {
    let tags: [String]
    let foreground: Color
    let background: Color

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(background)
                    .foregroundStyle(foreground)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Record Row View (List + Calendar)

struct RecordRowView: View {
    let record: MealRecord

    private var visibleFoodText: String {
        var parts: [String] = record.foodTags.prefix(2).map(\.rawValue)
        if !record.note.isEmpty { parts.append(record.note) }
        return parts.joined(separator: "、")
    }

    private var extraFoodCount: Int {
        max(0, record.foodTags.count - 2)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            VStack(alignment: .leading) {
                Text(record.displayTime)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.easeTextSecondary)
                Text(record.displayAmPm)
                    .font(.caption2)
                    .foregroundStyle(Color.easeTextSecondary)
                    .padding(.leading, 1)
            }
            .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                // Row 1: meal type + dining type
                HStack(spacing: 6) {
                    Text(record.mealType.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.easeAccent.opacity(0.12))
                        .foregroundStyle(Color.easeAccent)
                        .clipShape(Capsule())

                    if let diningType = record.diningType {
                        Text(diningType.rawValue)
                            .font(.caption)
                            .foregroundStyle(Color.easeTextSecondary)
                    }
                }

                // Row 2: symptoms — plain text, primary signal
                if record.hasSymptoms {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(record.symptoms.prefix(3).map(\.rawValue).joined(separator: "、"))
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextPrimary)
                        if record.symptoms.count > 3 {
                            Text(" +\(record.symptoms.count - 3)")
                                .font(.caption)
                                .foregroundStyle(Color.easeTextSecondary)
                        }
                    }
                    .padding(.leading, 3)
                } else {
                    Text("無症狀")
                        .font(.subheadline)
                        .foregroundStyle(Color.easeTextSecondary.opacity(0.45))
                        .padding(.leading, 3)
                }

                // Row 3: food — supporting info with +N
                if !visibleFoodText.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(visibleFoodText)
                            .font(.caption)
                            .foregroundStyle(Color.easeTextSecondary)
                            .lineLimit(1)
                        if extraFoodCount > 0 {
                            Text(" +\(extraFoodCount)")
                                .font(.caption2)
                                .foregroundStyle(Color.easeTextSecondary.opacity(0.6))
                        }
                    }
                    .padding(.leading, 3)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}

