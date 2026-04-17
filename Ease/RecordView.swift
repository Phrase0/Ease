import SwiftUI

struct RecordView: View {
    let existingRecord: MealRecord?
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var selectedMealType: MealType
    @State private var selectedFoodTags: Set<FoodTag>
    @State private var foodNote: String
    @State private var selectedDiningType: DiningType?
    @State private var selectedSymptoms: Set<Symptom>
    @State private var otherSymptomText: String
    @State private var additionalNote: String

    init(existingRecord: MealRecord? = nil) {
        self.existingRecord = existingRecord
        _date = State(initialValue: existingRecord?.date ?? Date())
        _selectedMealType = State(initialValue: existingRecord?.mealType ?? .lunch)
        _selectedFoodTags = State(initialValue: Set(existingRecord?.foodTags ?? []))
        _foodNote = State(initialValue: existingRecord?.note ?? "")
        _selectedDiningType = State(initialValue: existingRecord?.diningType)
        _selectedSymptoms = State(initialValue: Set(existingRecord?.symptoms ?? []))
        _otherSymptomText = State(initialValue: existingRecord?.otherSymptom ?? "")
        _additionalNote = State(initialValue: existingRecord?.additionalNote ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Date & Time
                Section {
                    DatePicker("日期與時間", selection: $date)
                        .datePickerStyle(.compact)
                }

                // MARK: Meal Type
                Section("餐種") {
                    Picker("選擇餐種", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: Food Tags
                Section("吃了什麼") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], alignment: .leading, spacing: 8) {
                        ForEach(FoodTag.allCases, id: \.self) { tag in
                            Button(tag.rawValue) {
                                toggleFoodTag(tag)
                            }
                            .buttonStyle(TagButtonStyle(isSelected: selectedFoodTags.contains(tag)))
                        }
                    }
                    .padding(.vertical, 4)

                    TextField("備註（例：咖啡、炸雞、泡麵）", text: $foodNote)
                }

                // MARK: Dining Type
                Section("用餐方式") {
                    HStack(spacing: 8) {
                        ForEach(DiningType.allCases, id: \.self) { type in
                            let isSelected = selectedDiningType == type
                            Button(type.rawValue) {
                                selectedDiningType = isSelected ? nil : type
                            }
                            .buttonStyle(TagButtonStyle(isSelected: isSelected, selectedColor: .blue))
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Symptoms
                Section("症狀") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], alignment: .leading, spacing: 8) {
                        ForEach(Symptom.allCases, id: \.self) { symptom in
                            Button("\(symptom.emoji) \(symptom.rawValue)") {
                                toggleSymptom(symptom)
                            }
                            .buttonStyle(TagButtonStyle(isSelected: selectedSymptoms.contains(symptom), selectedColor: .red))
                        }
                    }
                    .padding(.vertical, 4)

                    if selectedSymptoms.contains(.other) {
                        TextField("描述其他症狀", text: $otherSymptomText)
                    }
                }

                // MARK: Notes
                Section("備註（選填）") {
                    TextField("例：吃很快 / 很油 / 很晚吃", text: $additionalNote, axis: .vertical)
                        .lineLimit(3...)
                }

                // MARK: Save
                Section {
                    Button(action: save) {
                        Text("儲存")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .tint(.orange)
                }
            }
            .navigationTitle(existingRecord == nil ? "新增紀錄" : "編輯紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleFoodTag(_ tag: FoodTag) {
        if selectedFoodTags.contains(tag) {
            selectedFoodTags.remove(tag)
        } else {
            selectedFoodTags.insert(tag)
        }
    }

    private func toggleSymptom(_ symptom: Symptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
            if symptom == .other { otherSymptomText = "" }
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    private func save() {
        // TODO: Save to CoreData
        dismiss()
    }
}

#Preview {
    RecordView()
}
