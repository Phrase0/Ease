//
//  RecordView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct RecordView: View {
    let existingRecord: MealRecord?
    @EnvironmentObject private var store: RecordStore
    @StateObject private var viewModel: RecordFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(existingRecord: MealRecord? = nil) {
        self.existingRecord = existingRecord
        _viewModel = StateObject(wrappedValue: RecordFormViewModel(existingRecord: existingRecord))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    // MARK: Date & Time
                    FormSection("日期與時間") {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color.easeAccent)
                                .frame(width: 20)
                            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
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
                            DatePicker("", selection: $viewModel.date, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(Color.easeAccent)
                            Spacer()
                        }
                    }

                    // MARK: Meal Type
                    FormSection("餐種") {
                        Picker("選擇餐種", selection: $viewModel.selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.easeAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Symptoms
                    FormSection("症狀") {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 96), spacing: 8)],
                            alignment: .leading,
                            spacing: 8
                        ) {
                            ForEach(Symptom.allCases, id: \.self) { symptom in
                                Button(symptom.rawValue) {
                                    viewModel.toggleSymptom(symptom)
                                }
                                .buttonStyle(TagButtonStyle(
                                    isSelected: viewModel.selectedSymptoms.contains(symptom),
                                    selectedColor: Color.easeAccent
                                ))
                            }
                        }

                        if viewModel.selectedSymptoms.contains(.other) {
                            Divider().overlay(Color.easeDivider).padding(.top, 4)
                            TextField("描述其他症狀", text: $viewModel.otherSymptomText)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .tint(Color.easeAccent)
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
                                Button(habit.rawValue) { viewModel.toggleEatingHabit(habit) }
                                    .buttonStyle(TagButtonStyle(isSelected: viewModel.selectedEatingHabits.contains(habit)))
                            }
                        }
                    }

                    // MARK: Food Tags
                    FormSection("吃了什麼") {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 68), spacing: 8)],
                            alignment: .leading,
                            spacing: 8
                        ) {
                            ForEach(FoodTag.allCases, id: \.self) { tag in
                                Button(tag.rawValue) { viewModel.toggleFoodTag(tag) }
                                    .buttonStyle(TagButtonStyle(isSelected: viewModel.selectedFoodTags.contains(tag)))
                            }
                        }

                        Divider().overlay(Color.easeDivider).padding(.top, 4)

                        TextField("備註（例：咖啡、炸雞、泡麵）", text: $viewModel.foodNote)
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextPrimary)
                            .tint(Color.easeAccent)
                    }

                    // MARK: Dining Type
                    FormSection("用餐方式") {
                        HStack(spacing: 8) {
                            ForEach(DiningType.allCases, id: \.self) { type in
                                let isSelected = viewModel.selectedDiningType == type
                                Button(type.rawValue) {
                                    viewModel.selectedDiningType = isSelected ? nil : type
                                }
                                .buttonStyle(TagButtonStyle(
                                    isSelected: isSelected,
                                    selectedColor: Color.easeAccent
                                ))
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }

                    // MARK: Additional Notes
                    FormSection("備註（選填）") {
                        TextField("例：吃很快 / 很油 / 很晚吃", text: $viewModel.additionalNote, axis: .vertical)
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextPrimary)
                            .tint(Color.easeAccent)
                            .lineLimit(3...)
                    }

                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.easeBg.ignoresSafeArea())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存", action: save)
                        .foregroundStyle(Color.easeAccent)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        let record = viewModel.buildRecord()
        if existingRecord != nil {
            store.update(record)
        } else {
            store.add(record)
        }
        dismiss()
    }
}

#Preview {
    RecordView()
        .environmentObject(RecordStore())
}
