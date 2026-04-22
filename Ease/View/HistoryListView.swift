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
    @State private var recordToDelete: MealRecord? = nil

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
                .alert("刪除紀錄", isPresented: Binding(
                    get: { recordToDelete != nil },
                    set: { if !$0 { recordToDelete = nil } }
                )) {
                    Button("刪除", role: .destructive) {
                        if let r = recordToDelete { store.delete(r) }
                        recordToDelete = nil
                    }
                    Button("取消", role: .cancel) { recordToDelete = nil }
                } message: {
                    Text("確定要刪除這筆紀錄？此動作無法復原。")
                }
        }
        .onAppear { viewModel.load(store.records) }
        .onChange(of: store.records) { viewModel.load(store.records) }
    }

    private var recordList: some View {
        Group {
            if viewModel.groupedRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.clipboard")
                        .font(.largeTitle)
                        .foregroundStyle(Color.easeTextSecondary)
                    Text("還沒有紀錄")
                        .font(.subheadline)
                        .foregroundStyle(Color.easeTextSecondary)
                    Text("請按右上角 + 新增")
                        .font(.caption)
                        .foregroundStyle(Color.easeTextSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.groupedRecords, id: \.0) { date, records in
                        Section {
                            ForEach(records) { record in
                                NavigationLink(value: record) {
                                    RecordRowView(record: record)
                                }
                                .listRowBackground(Color.easeCard)
                                .listRowSeparatorTint(Color.easeDivider)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        withAnimation(.none) { recordToDelete = record }
                                    } label: {
                                        Label("刪除", systemImage: "trash")
                                    }
                                    .tint(.easeAccent)
                                }
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
    }
}

