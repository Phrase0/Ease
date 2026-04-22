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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

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
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.easeAccent.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        Spacer()
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
                        VStack(spacing: 8) {
                            Image(systemName: "leaf.fill").font(.system(size: 44)).foregroundStyle(Color.easeTextSecondary)
                            Text("這段時間沒有紀錄")
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        Text("共 \(viewModel.filteredRecords.count) 筆紀錄")
                            .font(.caption)
                            .foregroundStyle(Color.easeTextSecondary)

                        let total = viewModel.filteredRecords.count

                        if !viewModel.activeSymptoms.isEmpty {
                            statsCard("症狀統計") {
                                ForEach(viewModel.activeSymptoms, id: \.0) { symptom, count in
                                    StatRow(label: symptom.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeEatingHabits.isEmpty {
                            statsCard("進食習慣") {
                                ForEach(viewModel.activeEatingHabits, id: \.0) { habit, count in
                                    StatRow(label: habit.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeMealTypes.isEmpty {
                            statsCard("餐種分析") {
                                ForEach(viewModel.activeMealTypes, id: \.0) { type, count in
                                    StatRow(label: type.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeFoodTags.isEmpty {
                            statsCard("吃了什麼") {
                                ForEach(viewModel.activeFoodTags, id: \.0) { tag, count in
                                    StatRow(label: tag.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if !viewModel.activeDiningTypes.isEmpty {
                            statsCard("用餐方式") {
                                ForEach(viewModel.activeDiningTypes, id: \.0) { type, count in
                                    StatRow(label: type.rawValue, count: count, total: total)
                                }
                            }
                        }

                        if let worst = viewModel.worstDay {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("最嚴重的一天")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.easeTextSecondary)
                                    .tracking(0.8)

                                Button {
                                    viewModel.worstDaySheet = viewModel.worstDay
                                } label: {
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
                                        Image(systemName: "waveform.path.ecg").font(.system(size: 40)).foregroundStyle(Color.easeSymptom)
                                    }
                                    .padding(16)
                                    .background(Color.easeSymptom.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .background(Color.easeBg.ignoresSafeArea())
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $viewModel.worstDaySheet) { item in
                WorstDayDetailView(date: item.date, records: item.records)
            }
        }
        .onAppear { viewModel.load(store.records) }
        .onChange(of: store.records)     { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.selectedRange) { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.customStart)   { viewModel.updateFilter(from: store.records) }
        .onChange(of: viewModel.customEnd)     { viewModel.updateFilter(from: store.records) }
    }

    @ViewBuilder
    private func statsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.easeTextSecondary)
                .tracking(0.8)
                .padding(.bottom, 12)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.easeCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let count: Int
    let total: Int

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
            Capsule()
                .fill(Color.easeDivider)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.easeAccent)
                        .frame(height: 5)
                        .scaleEffect(x: ratio, anchor: .leading)
                }
        }
        .padding(.vertical, 7)
    }
}

#Preview {
    StatsView()
        .environmentObject(RecordStore())
}
