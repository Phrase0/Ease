//
//  CalendarPageView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct CalendarPageView: View {
    @EnvironmentObject private var store: RecordStore
    @StateObject private var viewModel = CalendarViewModel()

    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthHeader.padding(.top, 4)
                weekdayHeader.padding(.top, 4)
                daysGrid
                Divider().overlay(Color.easeDivider)
                dayRecordsList
                    .frame(maxHeight: .infinity)
            }
            .background(Color.easeBg.ignoresSafeArea())
            .navigationTitle("日曆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear { viewModel.load(store.records) }
        .onChange(of: store.records) { viewModel.load(store.records) }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Button { viewModel.changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.easeTextSecondary)
                    .padding(10)
            }
            Spacer()
            Text(viewModel.currentMonth, format: .dateTime.year().month(.wide))
                .font(.headline)
                .foregroundStyle(Color.easeTextPrimary)
            Spacer()
            Button { viewModel.changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.easeTextSecondary)
                    .padding(10)
            }
        }
        .padding(.horizontal, 16)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.easeTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<viewModel.daysInMonth.count, id: \.self) { index in
                if let date = viewModel.daysInMonth[index] {
                    DayCell(
                        date: date,
                        isSelected: viewModel.selectedDate.map {
                            Calendar.current.isDate($0, inSameDayAs: date)
                        } ?? false,
                        isToday: Calendar.current.isDateInToday(date),
                        hasSymptom: viewModel.hasSymptoms(on: date),
                        hasRecord: viewModel.hasRecords(on: date)
                    )
                    .onTapGesture {
                        viewModel.selectedDate = Calendar.current.startOfDay(for: date)
                    }
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var dayRecordsList: some View {
        if let date = viewModel.selectedDate {
            let records = viewModel.recordsFor(date, in: store.records)
            if records.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.clipboard").font(.largeTitle).foregroundStyle(Color.easeTextSecondary)
                    Text("這天沒有紀錄")
                        .font(.subheadline)
                        .foregroundStyle(Color.easeTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
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
                        Text(date, format: .dateTime.month(.wide).day().weekday(.wide))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .textCase(nil)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.easeBg)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "hand.point.up.fill").font(.largeTitle).foregroundStyle(Color.easeTextSecondary)
                Text("點選日期查看紀錄")
                    .font(.subheadline)
                    .foregroundStyle(Color.easeTextSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasSymptom: Bool
    let hasRecord: Bool

    private let calendar = Calendar.current

    private var dotColor: Color? {
        if hasSymptom { return .easeSymptom }
        if hasRecord  { return .easeHealthy }
        return nil
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        isSelected ? Color.easeAccent :
                        isToday    ? Color.easeAccent.opacity(0.18) :
                        Color.clear
                    )
                )
                .foregroundStyle(
                    isSelected ? Color.white :
                    isToday    ? Color.easeAccent :
                    Color.easeTextPrimary
                )
                .fontWeight(isToday ? .semibold : .regular)

            Circle()
                .fill(dotColor ?? .clear)
                .frame(width: 4, height: 4)
                .opacity(dotColor != nil ? 1 : 0)
        }
        .frame(height: 40)
    }
}

#Preview {
    CalendarPageView()
        .environmentObject(RecordStore())
}
