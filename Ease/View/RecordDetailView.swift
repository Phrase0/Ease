//
//  RecordDetailView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct RecordDetailView: View {
    let record: MealRecord
    @EnvironmentObject private var store: RecordStore
    @State private var editingRecord: MealRecord? = nil

    private var currentRecord: MealRecord {
        store.records.first(where: { $0.id == record.id }) ?? record
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentRecord.displayDate)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.easeTextPrimary)
                    Text("\(currentRecord.displayTime) \(currentRecord.displayAmPm)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Color.easeTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    Text(currentRecord.mealType.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.easeAccent.opacity(0.12))
                        .foregroundStyle(Color.easeAccent)
                        .clipShape(Capsule())
                }
                .padding(16)
                .background(Color.easeCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Symptoms
                FormSection("症狀") {
                    if currentRecord.symptoms.isEmpty {
                        Text("無症狀")
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextSecondary.opacity(0.5))
                    } else {
                        TagPillRow(
                            tags: currentRecord.symptoms.map { $0.rawValue },
                            foreground: .white,
                            background: Color.easeAccent
                        )
                        if let other = currentRecord.otherSymptom, !other.isEmpty {
                            Text("其他：\(other)")
                                .font(.caption)
                                .foregroundStyle(Color.easeTextSecondary)
                                .padding(.leading, 3)
                        }
                    }
                }

                // Eating Habits
                if !currentRecord.eatingHabits.isEmpty {
                    FormSection("進食習慣") {
                        TagPillRow(
                            tags: currentRecord.eatingHabits.map(\.rawValue),
                            foreground: .white,
                            background: Color.easeAccent
                        )
                    }
                }

                // Food
                if !currentRecord.foodTags.isEmpty || !currentRecord.note.isEmpty {
                    FormSection("吃了什麼") {
                        if !currentRecord.foodTags.isEmpty {
                            TagPillRow(
                                tags: currentRecord.foodTags.map(\.rawValue),
                                foreground: .white,
                                background: Color.easeAccent
                            )
                        }
                        if !currentRecord.note.isEmpty {
                            Text(currentRecord.note)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextPrimary)
                                .padding(.leading, 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                // Dining Type
                if let diningType = currentRecord.diningType {
                    FormSection("用餐方式") {
                        HStack(spacing: 4) {
                            Image(systemName: "fork.knife")
                                .font(.caption)
                                .foregroundStyle(Color.easeAccent)
                                .padding(.leading, 2)
                            Text(diningType.rawValue)
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.easeTextPrimary)
                    }
                }

                // Additional Notes
                if let note = currentRecord.additionalNote, !note.isEmpty {
                    FormSection("備註") {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(Color.easeBg.ignoresSafeArea())
        .navigationTitle("詳細紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.easeBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編輯") { editingRecord = currentRecord }
                    .foregroundStyle(Color.easeAccent)
                    .fontWeight(.semibold)
            }
        }
        .sheet(item: $editingRecord) { rec in
            AddRecordView(existingRecord: rec)
        }
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(record: mockRecords[0])
    }
    .environmentObject(RecordStore())
}
