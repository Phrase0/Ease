import SwiftUI

struct HistoryListView: View {
    @State private var searchText = ""
    @State private var showingNewRecord = false

    var filteredRecords: [MealRecord] {
        let sorted = mockRecords.sorted { $0.date > $1.date }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { record in
            record.mealType.rawValue.localizedCaseInsensitiveContains(searchText) ||
            record.note.localizedCaseInsensitiveContains(searchText) ||
            record.foodTags.map(\.rawValue).joined().localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredRecords) { record in
                NavigationLink(destination: RecordDetailView(record: record)) {
                    RecordRowView(record: record)
                }
            }
            .searchable(text: $searchText, prompt: "搜尋")
            .navigationTitle("紀錄")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewRecord = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewRecord) {
                RecordView()
            }
        }
    }
}

// MARK: - Detail View

struct RecordDetailView: View {
    let record: MealRecord
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Date / Meal type header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.date, style: .date)
                            .font(.headline)
                        Text(record.date, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(record.mealType.rawValue)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(Color.orange)
                        .clipShape(Capsule())
                }

                Divider()

                // Food
                if !record.foodTags.isEmpty || !record.note.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("吃了什麼", systemImage: "fork.knife")
                            .font(.headline)

                        if !record.foodTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(record.foodTags, id: \.self) { tag in
                                        Text(tag.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.orange.opacity(0.12))
                                            .foregroundStyle(Color.orange)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        if !record.note.isEmpty {
                            Text(record.note)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Dining type
                if let diningType = record.diningType {
                    Label(diningType.rawValue, systemImage: "bag")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Symptoms
                VStack(alignment: .leading, spacing: 10) {
                    Label("症狀", systemImage: "waveform.path.ecg")
                        .font(.headline)

                    if record.symptoms.isEmpty {
                        Text("無症狀 ✅")
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(record.symptoms, id: \.self) { symptom in
                                    Text("\(symptom.emoji) \(symptom.rawValue)")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundStyle(Color.red)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        if let other = record.otherSymptom, !other.isEmpty {
                            Text("其他：\(other)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Additional notes
                if let note = record.additionalNote, !note.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Label("備註", systemImage: "note.text")
                            .font(.headline)
                        Text(note)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("詳細紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編輯") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            RecordView(existingRecord: record)
        }
    }
}

#Preview {
    HistoryListView()
}
