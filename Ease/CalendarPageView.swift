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
            VStack(spacing: 0) {
                monthHeader
                weekdayHeader
                daysGrid
                Divider()
                dayRecordsList
            }
            .navigationTitle("日曆")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
            }
            Spacer()
            Text(currentMonth, format: .dateTime.year().month(.wide))
                .font(.title3.bold())
            Spacer()
            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
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
                Text(date, format: .dateTime.month().day().weekday(.wide))
                    .font(.subheadline.bold())
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                if records.isEmpty {
                    ContentUnavailableView("這天沒有紀錄", systemImage: "calendar.badge.exclamationmark")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(records) { record in
                        NavigationLink(destination: RecordDetailView(record: record)) {
                            RecordRowView(record: record)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        } else {
            ContentUnavailableView("點選日期查看紀錄", systemImage: "hand.tap")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Helpers

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
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(
                        isSelected ? Color.orange :
                        isToday ? Color.orange.opacity(0.2) :
                        Color.clear
                    )
                )
                .foregroundStyle(isSelected ? .white : .primary)

            Circle()
                .fill(Color.red)
                .frame(width: 5, height: 5)
                .opacity(hasSymptom ? 1 : 0)
        }
        .frame(height: 48)
    }
}

#Preview {
    CalendarPageView()
}
