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
    @State private var showMonthPicker = false

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
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = abs(value.translation.height)
                        guard abs(horizontal) > vertical else { return }
                        viewModel.changeMonth(by: horizontal < 0 ? 1 : -1)
                    }
            )
            .background(Color.easeBg.ignoresSafeArea())
            .navigationTitle("日曆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showMonthPicker) {
                MonthYearPickerSheet(currentMonth: viewModel.currentMonth) { selected in
                    viewModel.jumpTo(month: selected)
                }
            }
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
            Button { showMonthPicker = true } label: {
                Text(viewModel.currentMonth, format: .dateTime.year().month(.wide))
                    .font(.headline)
                    .foregroundStyle(Color.easeTextPrimary)
            }
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

// MARK: - Month Year Picker Sheet

struct MonthYearPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    private var yearRange: [Int] {
        let y = calendar.component(.year, from: Date())
        return Array((y - 5)...(y + 1))
    }

    @State private var selectedYear: Int
    @State private var selectedMonth: Int  // 0-indexed

    init(currentMonth: Date, onSelect: @escaping (Date) -> Void) {
        let cal = Calendar.current
        _selectedYear  = State(initialValue: cal.component(.year,  from: currentMonth))
        _selectedMonth = State(initialValue: cal.component(.month, from: currentMonth) - 1)
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("取消") { dismiss() }
                    .foregroundStyle(Color.easeTextSecondary)
                Spacer()
                Button("確認") {
                    var c = DateComponents()
                    c.year = selectedYear
                    c.month = selectedMonth + 1
                    c.day = 1
                    if let date = calendar.date(from: c) { onSelect(date) }
                    dismiss()
                }
                .foregroundStyle(Color.easeAccent)
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider().overlay(Color.easeDivider)

            HStack(spacing: 0) {
                Picker("月", selection: $selectedMonth) {
                    ForEach(0..<12, id: \.self) { i in
                        Text(monthNames[i]).tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("年", selection: $selectedYear) {
                    ForEach(yearRange, id: \.self) { y in
                        Text("\(y)年").tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .tint(Color.easeAccent)
        }
        .background(Color.easeBg)
        .presentationDetents([.height(280)])
        .presentationBackground(Color.easeBg)
    }
}

#Preview {
    CalendarPageView()
        .environmentObject(RecordStore())
}
