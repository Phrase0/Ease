//
//  WorstDayDetailView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct WorstDayDetailView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecordStore

    private var records: [MealRecord] {
        store.records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordRowView(record: record)
                    }
                    .listRowBackground(Color.easeCard)
                    .listRowSeparatorTint(Color.easeDivider)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.easeBg)
            .navigationTitle(date.formatted(.dateTime.month(.wide).day().weekday(.abbreviated)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(Color.easeAccent)
                }
            }
        }
    }
}

#Preview {
    WorstDayDetailView(date: mockRecords[0].date)
        .environmentObject(RecordStore())
}
