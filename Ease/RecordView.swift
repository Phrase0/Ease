//
//  RecordView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct RecordView: View {
    let existingRecord: MealRecord?
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var selectedMealType: MealType
    @State private var selectedFoodTags: Set<FoodTag>
    @State private var foodNote: String
    @State private var selectedDiningType: DiningType?
    @State private var selectedEatingHabits: Set<EatingHabit>
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
        _selectedEatingHabits = State(initialValue: Set(existingRecord?.eatingHabits ?? []))
        _selectedSymptoms = State(initialValue: Set(existingRecord?.symptoms ?? []))
        _otherSymptomText = State(initialValue: existingRecord?.otherSymptom ?? "")
        _additionalNote = State(initialValue: existingRecord?.additionalNote ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.easeBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {

                        // MARK: Date & Time
                        FormSection("日期與時間") {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color.easeAccent)
                                    .frame(width: 20)
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.easeAccent)
                                Spacer()
                            }

                            Divider().overlay(Color.easeDivider)

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(Color.easeAccent)
                                    .frame(width: 20)
                                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.easeAccent)
                                Spacer()
                            }
                        }

                        // MARK: Meal Type
                        FormSection("餐種") {
                            Picker("選擇餐種", selection: $selectedMealType) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.easeAccent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // MARK: Food Tags
                        FormSection("吃了什麼") {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 68), spacing: 8)],
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(FoodTag.allCases, id: \.self) { tag in
                                    Button(tag.rawValue) { toggleFoodTag(tag) }
                                        .buttonStyle(TagButtonStyle(isSelected: selectedFoodTags.contains(tag)))
                                }
                            }

                            Divider().overlay(Color.easeDivider).padding(.top, 4)

                            TextField("備註（例：咖啡、炸雞、泡麵）", text: $foodNote)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .tint(Color.easeAccent)
                        }

                        // MARK: Dining Type
                        FormSection("用餐方式") {
                            HStack(spacing: 8) {
                                ForEach(DiningType.allCases, id: \.self) { type in
                                    let isSelected = selectedDiningType == type
                                    Button(type.rawValue) {
                                        selectedDiningType = isSelected ? nil : type
                                    }
                                    .buttonStyle(TagButtonStyle(
                                        isSelected: isSelected,
                                        selectedColor: Color.easeNavy
                                    ))
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }

                        // MARK: Eating Habits
                        FormSection("進食習慣") {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 96), spacing: 8)],
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(EatingHabit.allCases, id: \.self) { habit in
                                    Button(habit.rawValue) { toggleEatingHabit(habit) }
                                        .buttonStyle(TagButtonStyle(isSelected: selectedEatingHabits.contains(habit)))
                                }
                            }
                        }

                        // MARK: Symptoms
                        FormSection("症狀") {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 96), spacing: 8)],
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(Symptom.allCases, id: \.self) { symptom in
                                    Button("\(symptom.emoji) \(symptom.rawValue)") {
                                        toggleSymptom(symptom)
                                    }
                                    .buttonStyle(TagButtonStyle(
                                        isSelected: selectedSymptoms.contains(symptom),
                                        selectedColor: Color.easeSymptom
                                    ))
                                }
                            }

                            if selectedSymptoms.contains(.other) {
                                Divider().overlay(Color.easeDivider).padding(.top, 4)
                                TextField("描述其他症狀", text: $otherSymptomText)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.easeTextPrimary)
                                    .tint(Color.easeAccent)
                            }
                        }

                        // MARK: Additional Notes
                        FormSection("備註（選填）") {
                            TextField("例：吃很快 / 很油 / 很晚吃", text: $additionalNote, axis: .vertical)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .tint(Color.easeAccent)
                                .lineLimit(3...)
                        }

                        // MARK: Save Button
                        Button(action: save) {
                            Text("儲存")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.easeAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(existingRecord == nil ? "新增紀錄" : "編輯紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.easeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(Color.easeTextSecondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleFoodTag(_ tag: FoodTag) {
        if selectedFoodTags.contains(tag) { selectedFoodTags.remove(tag) }
        else { selectedFoodTags.insert(tag) }
    }

    private func toggleEatingHabit(_ habit: EatingHabit) {
        if selectedEatingHabits.contains(habit) { selectedEatingHabits.remove(habit) }
        else { selectedEatingHabits.insert(habit) }
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
