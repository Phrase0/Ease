//
//  HistoryListView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct HistoryListView: View {
    @State private var searchText = ""
    @State private var showingNewRecord = false

    var filteredRecords: [MealRecord] {
        let sorted = mockRecords.sorted { $0.date > $1.date }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { record in
            record.mealType.rawValue.localizedCaseInsensitiveContains(searchText) ||
            record.note.localizedCaseInsensitiveContains(searchText) ||
            record.foodTags.map(\.rawValue).joined().localizedCaseInsensitiveContains(searchText)
        }
    }

    var groupedRecords: [(Date, [MealRecord])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredRecords) {
            cal.startOfDay(for: $0.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedRecords, id: \.0) { date, records in
                    Section {
                        ForEach(records) { record in
                            NavigationLink {
                                RecordDetailView(record: record)
                            } label: {
                                RecordRowView(record: record)
                            }
                            .listRowBackground(Color.easeCard)
                            .listRowSeparatorTint(Color.easeDivider)
                        }
                    } header: {
                        Text(date, format: .dateTime.month(.wide).day().weekday(.abbreviated))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.easeBg)
            .searchable(text: $searchText, prompt: "搜尋")
            .navigationTitle("紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewRecord = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.easeAccent)
                    }
                }
            }
            .sheet(isPresented: $showingNewRecord) {
                RecordView()
            }
        }
    }
}

#Preview {
    HistoryListView()
}
