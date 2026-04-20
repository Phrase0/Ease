//
//  StatsView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct StatsView: View {
    enum TimeRange: String, CaseIterable {
        case all   = "全部"
        case today = "今日"
        case week  = "最近7天"
        case month = "最近30天"
    }

    @State private var selectedRange: TimeRange = .week

    var filteredRecords: [MealRecord] {
        let now = Date()
        let cal = Calendar.current
        switch selectedRange {
        case .all:
            return mockRecords
        case .today:
            return mockRecords.filter { cal.isDateInToday($0.date) }
        case .week:
            let start = cal.date(byAdding: .day, value: -7, to: now)!
            return mockRecords.filter { $0.date >= start }
        case .month:
            let start = cal.date(byAdding: .day, value: -30, to: now)!
            return mockRecords.filter { $0.date >= start }
        }
    }

    func symptomCount(_ symptom: Symptom) -> Int {
        filteredRecords.filter { $0.symptoms.contains(symptom) }.count
    }

    func mealTypeCount(_ type: MealType) -> Int {
        filteredRecords.filter { $0.mealType == type }.count
    }

    var worstDay: (date: Date, records: Int, symptoms: Int)? {
        guard !filteredRecords.isEmpty else { return nil }
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredRecords) {
            cal.startOfDay(for: $0.date)
        }
        return grouped
            .map { (date: $0.key, records: $0.value.count, symptoms: $0.value.flatMap(\.symptoms).count) }
            .max {
                if $0.records != $1.records { return $0.records < $1.records }
                return $0.symptoms < $1.symptoms
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.easeBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Time range picker
                        Menu {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Button(range.rawValue) { selectedRange = range }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedRange.rawValue)
                                    .font(.subheadline.weight(.medium))
                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(Color.easeAccent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.easeAccent.opacity(0.1))
                            .clipShape(Capsule())
                        }

                        if filteredRecords.isEmpty {
                            VStack(spacing: 8) {
                                Text("🌿")
                                    .font(.system(size: 44))
                                Text("這段時間沒有紀錄")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.easeTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            Text("共 \(filteredRecords.count) 筆紀錄")
                                .font(.caption)
                                .foregroundStyle(Color.easeTextSecondary)

                            // Symptom stats
                            statsCard("症狀統計") {
                                ForEach(Symptom.allCases.filter { $0 != .other }, id: \.self) { symptom in
                                    StatRow(
                                        label: "\(symptom.emoji) \(symptom.rawValue)",
                                        count: symptomCount(symptom),
                                        total: filteredRecords.count
                                    )
                                }
                            }

                            // Meal type stats
                            let activeMealTypes = MealType.allCases.filter { mealTypeCount($0) > 0 }
                            if !activeMealTypes.isEmpty {
                                statsCard("餐種分析") {
                                    ForEach(activeMealTypes, id: \.self) { type in
                                        StatRow(
                                            label: "🍽 \(type.rawValue)",
                                            count: mealTypeCount(type),
                                            total: filteredRecords.count
                                        )
                                    }
                                }
                            }

                            // Worst day
                            if let worst = worstDay {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("最嚴重的一天")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.easeTextSecondary)
                                        .tracking(0.8)

                                    HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(worst.date, format: .dateTime.month(.wide).day().weekday(.wide))
                                                .font(.title3.weight(.semibold))
                                                .foregroundStyle(Color.easeTextPrimary)
                                            HStack(spacing: 12) {
                                                Label("\(worst.records) 筆", systemImage: "note.text")
                                                Label("\(worst.symptoms) 次症狀", systemImage: "waveform.path.ecg")
                                            }
                                            .font(.caption)
                                            .foregroundStyle(Color.easeTextSecondary)
                                        }
                                        Spacer()
                                        Text("😖")
                                            .font(.system(size: 40))
                                    }
                                    .padding(16)
                                    .background(Color.easeSymptom.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("統計")
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func statsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.easeTextSecondary)
                .tracking(0.8)
                .padding(.bottom, 12)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.easeCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let count: Int
    let total: Int

    var ratio: Double {
        guard total > 0 else { return 0 }
        return min(Double(count) / Double(total), 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Color.easeTextPrimary)
                Spacer()
                Text("\(count) 次")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(count > 0 ? Color.easeAccent : Color.easeTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.easeDivider)
                        .frame(height: 5)
                    Capsule()
                        .fill(Color.easeAccent)
                        .frame(width: geo.size.width * ratio, height: 5)
                }
            }
            .frame(height: 5)
        }
        .padding(.vertical, 7)
    }
}

#Preview {
    StatsView()
}
