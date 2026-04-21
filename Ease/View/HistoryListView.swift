//
//  HistoryListView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct HistoryListView: View {
    @EnvironmentObject private var store: RecordStore
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingNewRecord = false

    var body: some View {
        NavigationStack {
            recordList
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.easeBg)
                .navigationTitle("紀錄")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.easeBg, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showingNewRecord = true } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.easeAccent)
                        }
                    }
                }
                .sheet(isPresented: $showingNewRecord) { RecordView() }
                .navigationDestination(for: MealRecord.self) { record in
                    RecordDetailView(record: record)
                }
        }
        .onAppear { viewModel.load(store.records) }
        .onChange(of: store.records) { viewModel.load(store.records) }
    }

    private var recordList: some View {
        List {
            ForEach(viewModel.groupedRecords, id: \.0) { date, records in
                Section {
                    ForEach(records) { record in
                        NavigationLink(value: record) {
                            RecordRowView(record: record)
                        }
                        .listRowBackground(Color.easeCard)
                        .listRowSeparatorTint(Color.easeDivider)
                    }
                } header: {
                    Text(date, format: .dateTime.month(.wide).day().weekday(.abbreviated))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.easeTextSecondary)
                        .textCase(nil)
                }
            }
        }
    }
}

#Preview {
    HistoryListView()
        .environmentObject(RecordStore())
}
