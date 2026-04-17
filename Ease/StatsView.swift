import SwiftUI

struct StatsView: View {
    enum TimeRange: String, CaseIterable {
        case all = "全部"
        case today = "今日"
        case week = "最近7天"
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

    // Worst day: most records, ties broken by total symptom count
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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Time range picker
                    Picker("時間範圍", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if filteredRecords.isEmpty {
                        ContentUnavailableView("這段時間沒有紀錄", systemImage: "chart.bar")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        // Summary count
                        Text("共 \(filteredRecords.count) 筆紀錄")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        // Symptom stats
                        statsCard(title: "症狀統計", icon: "waveform.path.ecg") {
                            ForEach(Symptom.allCases.filter { $0 != .other }, id: \.self) { symptom in
                                StatRow(
                                    label: "\(symptom.emoji) \(symptom.rawValue)",
                                    count: symptomCount(symptom),
                                    total: filteredRecords.count
                                )
                            }
                        }

                        // Meal type stats
                        statsCard(title: "餐種分析", icon: "fork.knife") {
                            ForEach(MealType.allCases, id: \.self) { type in
                                let count = mealTypeCount(type)
                                if count > 0 {
                                    StatRow(label: "🍽 \(type.rawValue)", count: count, total: filteredRecords.count)
                                }
                            }
                        }

                        // Worst day
                        if let worst = worstDay {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("最嚴重的一天", systemImage: "exclamationmark.circle")
                                    .font(.headline)
                                    .padding(.horizontal)

                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(worst.date, format: .dateTime.month().day().weekday(.wide))
                                            .font(.title3.bold())
                                        HStack(spacing: 12) {
                                            Label("\(worst.records) 筆紀錄", systemImage: "note.text")
                                            Label("\(worst.symptoms) 次症狀", systemImage: "waveform.path.ecg")
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("😖")
                                        .font(.system(size: 44))
                                }
                                .padding()
                                .background(Color.red.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("統計")
        }
    }

    @ViewBuilder
    private func statsCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let count: Int
    let total: Int

    var ratio: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(count) 次")
                    .font(.subheadline.bold())
                    .foregroundStyle(count > 0 ? .primary : .secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 6)
                    Capsule().fill(Color.orange).frame(width: geo.size.width * ratio, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
        Divider()
    }
}

#Preview {
    StatsView()
}
