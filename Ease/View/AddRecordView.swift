//
//  RecordView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct AddRecordView: View {
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
                        EqualTagGrid(
                            items: Symptom.allCases,
                            label: \.rawValue,
                            isSelected: { viewModel.selectedSymptoms.contains($0) },
                            onTap: { viewModel.toggleSymptom($0) },
                            selectedColor: .easeAccent
                        )

                        if viewModel.selectedSymptoms.contains(.other) {
                            Divider().overlay(Color.easeDivider).padding(.top, 4)
                            TextField("描述其他症狀", text: $viewModel.otherSymptomText)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .tint(Color.easeAccent)
                        }
                    }

                    if viewModel.selectedMealType != .fasting {
                        // MARK: Eating Habits
                        FormSection("進食習慣") {
                            EqualTagGrid(
                                items: EatingHabit.allCases,
                                label: \.rawValue,
                                isSelected: { viewModel.selectedEatingHabits.contains($0) },
                                onTap: { viewModel.toggleEatingHabit($0) }
                            )
                        }

                        // MARK: Food Tags
                        FormSection("吃了什麼") {
                            EqualTagGrid(
                                items: FoodTag.allCases,
                                label: \.rawValue,
                                isSelected: { viewModel.selectedFoodTags.contains($0) },
                                onTap: { viewModel.toggleFoodTag($0) }
                            )

                            Divider().overlay(Color.easeDivider).padding(.top, 4)

                            TextField("備註（例：咖啡、炸雞、泡麵）", text: $viewModel.foodNote, axis: .vertical)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .tint(Color.easeAccent)
                        }

                        // MARK: Dining Type
                        FormSection("用餐方式") {
                            EqualTagGrid(
                                items: DiningType.allCases,
                                label: \.rawValue,
                                isSelected: { viewModel.selectedDiningType == $0 },
                                onTap: { type in
                                    viewModel.selectedDiningType = viewModel.selectedDiningType == type ? nil : type
                                }
                            )
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
                    Button("儲存") {
                        viewModel.save(to: store)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.easeAccent)
                }
            }
        }
    }
}

#Preview("新增") {
    AddRecordView()
        .environmentObject(RecordStore())
}

#Preview("編輯") {
    AddRecordView(existingRecord: mockRecords[0])
        .environmentObject(RecordStore())
}
