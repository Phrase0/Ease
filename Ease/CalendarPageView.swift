import SwiftUI

struct CalendarPageView: View {
    @State private var currentMonth = Date()
    @State private var selectedDate: Date? = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var daysInMonth: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start) - 1
        let totalDays = calendar.range(of: .day, in: .month, for: currentMonth)!.count

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for offset in 0..<totalDays {
            days.append(calendar.date(byAdding: .day, value: offset, to: interval.start))
        }
        return days
    }

    func recordsFor(_ date: Date) -> [MealRecord] {
        mockRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    func hasSymptoms(on date: Date) -> Bool {
        recordsFor(date).contains { $0.hasSymptoms }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.easeBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    monthHeader
                        .padding(.top, 4)
                    weekdayHeader
                    daysGrid
                    Divider().overlay(Color.easeDivider)
                    dayRecordsList
                }
            }
            .navigationTitle("日曆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.easeTextSecondary)
                    .padding(10)
            }
            Spacer()
            Text(currentMonth, format: .dateTime.year().month(.wide))
                .font(.headline)
                .foregroundStyle(Color.easeTextPrimary)
            Spacer()
            Button { changeMonth(by: 1) } label: {
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
            ForEach(0..<daysInMonth.count, id: \.self) { index in
                if let date = daysInMonth[index] {
                    DayCell(
                        date: date,
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        isToday: calendar.isDateInToday(date),
                        hasSymptom: hasSymptoms(on: date)
                    )
                    .onTapGesture {
                        selectedDate = calendar.startOfDay(for: date)
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
        if let date = selectedDate {
            let records = recordsFor(date)
            VStack(alignment: .leading, spacing: 0) {
                Text(date, format: .dateTime.month(.wide).day().weekday(.wide))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.easeTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                if records.isEmpty {
                    VStack(spacing: 8) {
                        Text("🌿")
                            .font(.largeTitle)
                        Text("這天沒有紀錄")
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
                } else {
                    List(records) { record in
                        NavigationLink(destination: RecordDetailView(record: record)) {
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
                Text("👆")
                    .font(.largeTitle)
                Text("點選日期查看紀錄")
                    .font(.subheadline)
                    .foregroundStyle(Color.easeTextSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
            Spacer()
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
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
}
