//
//  HistoryViewModel.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published private(set) var groupedRecords: [(Date, [MealRecord])] = []

    private let calendar = Calendar.current

    func load(_ records: [MealRecord]) {
        let sorted = records.sorted { $0.date > $1.date }
        let grouped = Dictionary(grouping: sorted) { calendar.startOfDay(for: $0.date) }
        groupedRecords = grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }
}
