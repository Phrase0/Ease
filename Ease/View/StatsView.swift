//
//  StatsView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: RecordStore
    @StateObject private var viewModel = StatsViewModel()
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // Time range picker
                    HStack {
                        Menu {
                            ForEach(StatsViewModel.TimeRange.allCases, id: \.self) { range in
                                Button(range.rawValue) { viewModel.selectedRange = range }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(viewModel.selectedRange.rawValue)
                                    .font(.subheadline.weight(.medium))
                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.medium))
                            }
                            .frame(minWidth: 100)
                            .foregroundStyle(Color.easeAccent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.easeAccent.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        Spacer()
                        if !viewModel.filteredRecords.isEmpty {
                            Text("共 \(viewModel.filteredRecords.count) 筆紀錄")
                                .font(.caption)
                                .foregroundStyle(Color.easeTextSecondary)
                                .padding(.trailing, 4)
                        }
                    }

                    if viewModel.selectedRange == .custom {
                        VStack(spacing: 0) {
                            HStack {
                                Text("開始")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.easeTextSecondary)
                                Spacer()
                                DatePicker("", selection: $viewModel.customStart,
                                           in: ...viewModel.customEnd,
                                           displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.easeAccent)
                                    .environment(\.locale, Locale(identifier: "en_US"))
                            }
                            .padding(.vertical, 12)

                            Divider().overlay(Color.easeDivider)

                            HStack {
                                Text("結束")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.easeTextSecondary)
                                Spacer()
                                DatePicker("", selection: $viewModel.customEnd,
                                           in: viewModel.customStart...Date(),
                                           displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.easeAccent)
                                    .environment(\.locale, Locale(identifier: "en_US"))
                            }
                            .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.easeCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if viewModel.filteredRecords.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "list.clipboard").font(.largeTitle).foregroundStyle(Color.easeTextSecondary)
                            Text("這段時間沒有紀錄")
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        let total = viewModel.filteredRecords.count

                        VStack(alignment: .leading, spacing: 12) {
                            if let worst = viewModel.worstDay {
                            Button {
                                viewModel.worstDaySheet = viewModel.worstDay
                            } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("最嚴重的一天")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.easeSymptom)
                                        .tracking(0.8)
                                    HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(worst.date, format: .dateTime.month(.wide).day().weekday(.wide))
                                                .font(.title3.weight(.semibold))
                                                .foregroundStyle(Color.easeTextPrimary)
                                            HStack(spacing: 12) {
                                                Label("\(worst.records.count) 筆", systemImage: "note.text")
                                                Label("嚴重度 \(worst.records.flatMap(\.symptoms).map(\.weight).reduce(0, +))",
                                                      systemImage: "waveform.path.ecg")
                                            }
                                            .font(.caption)
                                            .foregroundStyle(Color.easeTextSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "waveform.path.ecg")
                                            .font(.system(size: 40))
                                            .foregroundStyle(Color.easeSymptom)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.easeSymptom.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }

                        if !viewModel.activeSymptoms.isEmpty {
                            FormSection("症狀統計") {
                                ForEach(viewModel.activeSymptoms, id: \.0) { symptom, count in
                                    StatRow(label: symptom.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeEatingHabits.isEmpty {
                            FormSection("進食習慣") {
                                ForEach(viewModel.activeEatingHabits, id: \.0) { habit, count in
                                    StatRow(label: habit.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeMealTypes.isEmpty {
                            FormSection("餐種分析") {
                                ForEach(viewModel.activeMealTypes, id: \.0) { type, count in
                                    StatRow(label: type.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeFoodTags.isEmpty {
                            FormSection("吃了什麼") {
                                ForEach(viewModel.activeFoodTags, id: \.0) { tag, count in
                                    StatRow(label: tag.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeDiningTypes.isEmpty {
                            FormSection("用餐方式") {
                                ForEach(viewModel.activeDiningTypes, id: \.0) { type, count in
                                    StatRow(label: type.rawValue, count: count, total: total)
                                }
                            }
                        }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .background(Color.easeBg.ignoresSafeArea())
            .navigationTitle("不適分析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.prepareAllExport()
                            showingShareSheet = true
                        } label: {
                            Label("全部匯出", systemImage: "square.and.arrow.up.on.square")
                        }
                        Divider()
                        Button {
                            viewModel.prepareRawExport()
                            showingShareSheet = true
                        } label: {
                            Label("原始紀錄", systemImage: "list.clipboard")
                        }
                        Button {
                            viewModel.prepareSummaryExport()
                            showingShareSheet = true
                        } label: {
                            Label("統計摘要", systemImage: "chart.bar")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.filteredRecords.isEmpty)
                }
            }
            .sheet(item: $viewModel.worstDaySheet) { item in
                WorstDayDetailView(date: item.date, records: item.records)
            }
            .shareSheet(
                isPresented: $showingShareSheet,
                activityItems: { viewModel.currentShareItems },
                excludedTypes: UIActivity.ActivityType.defaultExcludedTypes,
                onComplete: { completed in
                    if completed { viewModel.handleExportSuccess() }
                }
            )
            .alert("匯出成功", isPresented: $viewModel.showingExportSuccessAlert) {
                Button("確定") { }
            } message: {
                Text("報表已成功匯出")
            }
        }
        .onAppear { viewModel.updateFilter(from: store.records) }
        .onChange(of: store.records)     { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.selectedRange) { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.customStart)   { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.customEnd)     { viewModel.updateFilter(from: store.records) }
    }

}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let count: Int
    let total: Int
    var barColor: Color = .easeAccent

    private var ratio: Double {
        guard total > 0 else { return 0 }
        return min(Double(count) / Double(total), 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Color.easeTextPrimary)
                Spacer()
                Text("\(count) 次")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(count > 0 ? Color.easeAccent : Color.easeTextSecondary)
            }
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.easeDivider)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor)
                            .frame(width: geo.size.width * ratio)
                    }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    StatsView()
        .environmentObject(RecordStore())
}
