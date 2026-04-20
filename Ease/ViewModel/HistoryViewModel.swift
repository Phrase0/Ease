//
//  HistoryViewModel.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet { updateGroups() }
    }
    @Published private(set) var groupedRecords: [(Date, [MealRecord])] = []

    private var allRecords: [MealRecord] = []
    private let calendar = Calendar.current

    func load(_ records: [MealRecord]) {
        allRecords = records
        updateGroups()
    }

    private func updateGroups() {
        let sorted = allRecords.sorted { $0.date > $1.date }
        let filtered: [MealRecord]
        if searchText.isEmpty {
            filtered = sorted
        } else {
            filtered = sorted.filter { record in
                record.mealType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                record.note.localizedCaseInsensitiveContains(searchText) ||
                record.foodTags.map(\.rawValue).joined().localizedCaseInsensitiveContains(searchText)
            }
        }
        let grouped = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        groupedRecords = grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }
}
