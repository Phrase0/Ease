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
                weekdayHeader
                daysGrid
                Divider().overlay(Color.easeDivider)
                dayRecordsList
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
        .padding(.horizontal, 8)
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
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<viewModel.daysInMonth.count, id: \.self) { index in
                if let date = viewModel.daysInMonth[index] {
                    DayCell(
                        date: date,
                        isSelected: viewModel.selectedDate.map {
                            Calendar.current.isDate($0, inSameDayAs: date)
                        } ?? false,
                        isToday: Calendar.current.isDateInToday(date),
                        hasSymptom: viewModel.hasSymptoms(on: date)
                    )
                    .onTapGesture {
                        viewModel.selectedDate = Calendar.current.startOfDay(for: date)
                    }
                } else {
                    Color.clear.frame(height: 48)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var dayRecordsList: some View {
        if let date = viewModel.selectedDate {
            let records = viewModel.recordsFor(date, in: store.records)
            VStack(alignment: .leading, spacing: 0) {
                Text(date, format: .dateTime.month(.wide).day().weekday(.wide))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.easeTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                if records.isEmpty {
                    VStack(spacing: 8) {
                        Text("🌿").font(.largeTitle)
                        Text("這天沒有紀錄")
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
                } else {
                    List(records) { record in
                        NavigationLink {
                            RecordDetailView(record: record)
                        } label: {
                            RecordRowView(record: record)
                        }
                        .listRowBackground(Color.easeCard)
                        .listRowSeparatorTint(Color.easeDivider)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            Spacer()
        } else {
            VStack(spacing: 8) {
                Text("👆").font(.largeTitle)
                Text("點選日期查看紀錄")
                    .font(.subheadline)
                    .foregroundStyle(Color.easeTextSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
            Spacer()
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasSymptom: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 3) {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline)
                .frame(width: 34, height: 34)
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
                .fill(Color.easeSymptom)
                .frame(width: 5, height: 5)
                .opacity(hasSymptom ? 1 : 0)
        }
        .frame(height: 50)
    }
}

#Preview {
    CalendarPageView()
        .environmentObject(RecordStore())
}
