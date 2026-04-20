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

    @Published private(set) var activeSymptoms: [(Symptom, Int)] = []
    @Published private(set) var activeMealTypes: [(MealType, Int)] = []
    @Published private(set) var activeFoodTags: [(FoodTag, Int)] = []
    @Published private(set) var activeDiningTypes: [(DiningType, Int)] = []
    @Published private(set) var activeEatingHabits: [(EatingHabit, Int)] = []

    private let calendar = Calendar.current

    func load(_ records: [MealRecord]) {
        updateFilter(from: records)
    }

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
        filteredRecords = filtered
        updateWorstDay(from: filtered)
        updateActiveStats(from: filtered)
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
