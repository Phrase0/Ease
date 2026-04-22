//
//  CalendarViewModel.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date() {
        didSet { updateDays() }
    }
    @Published var selectedDate: Date? = Calendar.current.startOfDay(for: Date())
    @Published private(set) var daysInMonth: [Date?] = []
    @Published private(set) var symptomDates: Set<Date> = []
    @Published private(set) var recordDates: Set<Date> = []

    private let calendar = Calendar.current

    init() {
        updateDays()
    }

    func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
    }

    func load(_ records: [MealRecord]) {
        let allDates = records.map { calendar.startOfDay(for: $0.date) }
        symptomDates = Set(records.filter(\.hasSymptoms).map { calendar.startOfDay(for: $0.date) })
        recordDates  = Set(allDates).subtracting(symptomDates)
    }

    func hasRecords(on date: Date) -> Bool {
        recordDates.contains(calendar.startOfDay(for: date))
    }

    func recordsFor(_ date: Date, in records: [MealRecord]) -> [MealRecord] {
        records
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    func hasSymptoms(on date: Date) -> Bool {
        symptomDates.contains(calendar.startOfDay(for: date))
    }

    private func updateDays() {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth),
              let totalDays = calendar.range(of: .day, in: .month, for: currentMonth)
        else { daysInMonth = []; return }

        let firstWeekday = calendar.component(.weekday, from: interval.start) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for offset in 0..<totalDays.count {
            days.append(calendar.date(byAdding: .day, value: offset, to: interval.start))
        }
        daysInMonth = days
    }
}
