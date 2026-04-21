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
            List {
                ForEach(viewModel.groupedRecords, id: \.0) { date, records in
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
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.easeTextPrimary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.easeBg)
            .searchable(text: $viewModel.searchText, prompt: "搜尋")
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
            .sheet(isPresented: $showingNewRecord) {
                RecordView()
            }
        }
        .onAppear { viewModel.load(store.records) }
        .onChange(of: store.records) { viewModel.load(store.records) }
    }
}

#Preview {
    HistoryListView()
        .environmentObject(RecordStore())
}
