//
//  StatsViewModel.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

// MARK: - WorstDayItem

struct WorstDayItem: Identifiable {
    let id = UUID()
    let date: Date
    let records: [MealRecord]
}

// MARK: - StatsViewModel

class StatsViewModel: ObservableObject {
    enum TimeRange: String, CaseIterable {
        case all    = "全部"
        case today  = "今日"
        case week   = "最近7天"
        case month  = "最近30天"
        case custom = "自訂"
    }

    @Published var selectedRange: TimeRange = .week
    @Published var customStart: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @Published var customEnd: Date = Date()
    @Published private(set) var filteredRecords: [MealRecord] = []
    @Published private(set) var worstDay: WorstDayItem? = nil
    @Published var worstDaySheet: WorstDayItem? = nil
    @Published var currentShareItems: [Any] = []
    @Published var showingExportSuccessAlert = false

    @Published private(set) var activeSymptoms: [(Symptom, Int)] = []
    @Published private(set) var activeMealTypes: [(MealType, Int)] = []
    @Published private(set) var activeFoodTags: [(FoodTag, Int)] = []
    @Published private(set) var activeDiningTypes: [(DiningType, Int)] = []
    @Published private(set) var activeEatingHabits: [(EatingHabit, Int)] = []

    private let calendar = Calendar.current

    func updateFilter(from records: [MealRecord]) {
        let now = Date()
        let filtered: [MealRecord]
        switch selectedRange {
        case .all:
            filtered = records
        case .today:
            filtered = records.filter { calendar.isDateInToday($0.date) }
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            filtered = records.filter { $0.date >= start }
        case .month:
            let start = calendar.date(byAdding: .day, value: -30, to: now)!
            filtered = records.filter { $0.date >= start }
        case .custom:
            let start = calendar.startOfDay(for: customStart)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEnd)!
            filtered = records.filter { $0.date >= start && $0.date <= end }
        }
        let symptomRecords = filtered.filter(\.hasSymptoms)
        filteredRecords = symptomRecords
        updateWorstDay(from: symptomRecords)
        updateActiveStats(from: symptomRecords)
    }

    private func updateActiveStats(from records: [MealRecord]) {
        activeSymptoms = Symptom.allCases.compactMap { s -> (Symptom, Int)? in
            guard s != .other else { return nil }
            let c = records.filter { $0.symptoms.contains(s) }.count
            return c > 0 ? (s, c) : nil
        }
        activeMealTypes = MealType.allCases.compactMap { t in
            let c = records.filter { $0.mealType == t }.count
            return c > 0 ? (t, c) : nil
        }
        activeFoodTags = FoodTag.allCases.compactMap { t in
            let c = records.filter { $0.foodTags.contains(t) }.count
            return c > 0 ? (t, c) : nil
        }
        activeDiningTypes = DiningType.allCases.compactMap { t in
            let c = records.filter { $0.diningType == t }.count
            return c > 0 ? (t, c) : nil
        }
        activeEatingHabits = EatingHabit.allCases.compactMap { h in
            let c = records.filter { $0.eatingHabits.contains(h) }.count
            return c > 0 ? (h, c) : nil
        }
    }

    private func updateWorstDay(from records: [MealRecord]) {
        guard !records.isEmpty else { worstDay = nil; return }
        let grouped = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        typealias DaySummary = (date: Date, recs: [MealRecord], score: Int)
        let summaries: [DaySummary] = grouped.map { key, value in
            let score = value.flatMap { $0.symptoms }.map { $0.weight }.reduce(0, +)
            return (date: key, recs: value, score: score)
        }
        guard let best = summaries.max(by: { a, b in
            a.score != b.score ? a.score < b.score : a.recs.count < b.recs.count
        }) else { worstDay = nil; return }
        worstDay = WorstDayItem(date: best.date, records: best.recs.sorted { $0.date < $1.date })
    }

}

// MARK: - CSV Export

extension StatsViewModel {

    private static let fileTimestamp: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        return f
    }()

    private static let csvDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private static let csvTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var csvDateRangeText: String {
        let df = StatsViewModel.csvDateFormatter
        switch selectedRange {
        case .all:    return "全部"
        case .today:  return df.string(from: Date())
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: Date())!
            return "\(df.string(from: start))~\(df.string(from: Date()))"
        case .month:
            let start = calendar.date(byAdding: .day, value: -30, to: Date())!
            return "\(df.string(from: start))~\(df.string(from: Date()))"
        case .custom:
            return "\(df.string(from: customStart))~\(df.string(from: customEnd))"
        }
    }

    // MARK: Generate CSV strings

    func generateRawRecordsCSV() -> String {
        var csv = "不適紀錄_原始資料, \(csvDateRangeText)\n\n"
        csv += "日期,時間,餐種,食物描述,食物標籤,用餐方式,進食習慣,症狀,嚴重度分數,其他症狀,補充說明\n"

        let df = StatsViewModel.csvDateFormatter
        let tf = StatsViewModel.csvTimeFormatter

        for r in filteredRecords.sorted(by: { $0.date < $1.date }) {
            let date = df.string(from: r.date)
            let time = tf.string(from: r.date)
            let mealType = r.mealType.rawValue
            let note = r.note.replacingOccurrences(of: ",", with: "，")
            let tags = r.foodTags.map(\.rawValue).joined(separator: "、")
            let dining = r.diningType?.rawValue ?? ""
            let habits = r.eatingHabits.map(\.rawValue).joined(separator: "、")
            let symptoms = r.symptoms.filter { $0 != .other }.map(\.rawValue).joined(separator: "、")
            let score = r.symptoms.map(\.weight).reduce(0, +)
            let otherSymptom = (r.otherSymptom ?? "").replacingOccurrences(of: ",", with: "，")
            let additional = (r.additionalNote ?? "").replacingOccurrences(of: ",", with: "，")

            csv += "\(date),\(time),\(mealType),\(note),\(tags),\(dining),\(habits),\(symptoms),\(score),\(otherSymptom),\(additional)\n"
        }
        return csv
    }

    func generateStatsCSV() -> String {
        let total = filteredRecords.count
        var csv = "不適分析統計, \(csvDateRangeText)\n"
        csv += "總紀錄筆數,\(total)\n\n"

        func pct(_ count: Int) -> String {
            guard total > 0 else { return "0%" }
            return "\(Int(round(Double(count) / Double(total) * 100)))%"
        }

        if !activeSymptoms.isEmpty {
            csv += "症狀統計\n症狀,次數,佔比%\n"
            for (s, c) in activeSymptoms { csv += "\(s.rawValue),\(c),\(pct(c))\n" }
            csv += "\n"
        }

        if !activeEatingHabits.isEmpty {
            csv += "進食習慣\n習慣,次數,佔比%\n"
            for (h, c) in activeEatingHabits { csv += "\(h.rawValue),\(c),\(pct(c))\n" }
            csv += "\n"
        }

        if !activeMealTypes.isEmpty {
            csv += "餐種分析\n餐種,次數,佔比%\n"
            for (t, c) in activeMealTypes { csv += "\(t.rawValue),\(c),\(pct(c))\n" }
            csv += "\n"
        }

        if !activeFoodTags.isEmpty {
            csv += "食物標籤\n標籤,次數,佔比%\n"
            for (t, c) in activeFoodTags { csv += "\(t.rawValue),\(c),\(pct(c))\n" }
            csv += "\n"
        }

        if !activeDiningTypes.isEmpty {
            csv += "用餐方式\n方式,次數,佔比%\n"
            for (t, c) in activeDiningTypes { csv += "\(t.rawValue),\(c),\(pct(c))\n" }
        }

        return csv
    }

    // MARK: Create file URLs

    func createRawRecordsCSVFileURL() -> URL {
        let fileName = "不適紀錄_原始資料_\(StatsViewModel.fileTimestamp.string(from: Date())).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try generateRawRecordsCSV().write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error creating raw records CSV: \(error)")
        }
        return fileURL
    }

    func createStatsCSVFileURL() -> URL {
        let fileName = "不適分析統計_\(StatsViewModel.fileTimestamp.string(from: Date())).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try generateStatsCSV().write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error creating stats CSV: \(error)")
        }
        return fileURL
    }

    // MARK: Prepare export

    func prepareRawExport() {
        currentShareItems = [createRawRecordsCSVFileURL()]
    }

    func prepareSummaryExport() {
        currentShareItems = [createStatsCSVFileURL()]
    }

    func prepareAllExport() {
        currentShareItems = [createRawRecordsCSVFileURL(), createStatsCSVFileURL()]
    }

    func handleExportSuccess() {
        showingExportSuccessAlert = true
    }
}
