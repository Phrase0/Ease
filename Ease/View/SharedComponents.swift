//
//  SharedComponents.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

// MARK: - Color Tokens

extension Color {
    // 底面色
    static let easeBg            = Color(red: 243/255, green: 239/255, blue: 233/255) // #F3EFE9 暖奶油米白，頁面背景
    static let easeCard          = Color(red: 251/255, green: 248/255, blue: 245/255) // #FBF8F5 比背景略白，卡片背景
    static let easeAccent        = Color(red: 204/255, green: 125/255, blue:  71/255) // #CC7D47 暖橘棕，主要強調色
    static let easeAccentSubtle  = Color(red: 237/255, green: 222/255, blue: 209/255) // #EDDED1 accent 15% 疊背景，chip 填色 / 日曆今日圈
    static let easeAccentToday   = easeAccentSubtle

    // 文字色
    static let easeTextPrimary   = Color(red:  49/255, green:  40/255, blue:  32/255) // #312820 暖深褐，主要文字，非純黑
    static let easeTextSecondary = Color(red: 130/255, green: 117/255, blue: 104/255) // #827568 中暖棕，次要文字
    static let easeTextTertiary  = Color(red: 190/255, green: 183/255, blue: 174/255) // #BEB7AE 淡化次要文字，如「無症狀」
    static let easeTextHint      = Color(red: 164/255, green: 153/255, blue: 143/255) // #A4998F 提示說明文字

    // 症狀色
    static let easeSymptom       = Color(red: 171/255, green: 106/255, blue:  84/255) // #AB6A54 暖磚玫瑰，症狀強調色
    static let easeSymptomSubtle = Color(red: 237/255, green: 228/255, blue: 221/255) // #EDE4DD 症狀卡片底色

    // 其他
    static let easeHealthy       = Color(red: 126/255, green: 137/255, blue: 107/255) // #7E896B 鼠尾草綠，無症狀日曆點
    static let easeDivider       = Color(red: 222/255, green: 216/255, blue: 208/255) // #DED8D0 暖分隔線
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
            .animation(.easeInOut(duration: 0.15), value: isSelected)
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
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.easeAccent)
                        .frame(width: 5, height: 5)
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.easeTextSecondary)
                        .tracking(0.8)
                }
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
        FlowLayout(spacing: 8) {
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
                        .foregroundStyle(Color.easeAccent)
                        .overlay(Capsule().stroke(Color.easeAccent, lineWidth: 1))

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
                        .foregroundStyle(Color.easeTextTertiary)
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
                                .foregroundStyle(Color.easeTextTertiary)
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

