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
                        .font(.callout.monospacedDigit())
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("症狀")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.easeTextSecondary)
                        .tracking(0.8)

                    if currentRecord.symptoms.isEmpty {
                        Text("無症狀")
                            .font(.callout)
                            .foregroundStyle(Color.easeTextSecondary.opacity(0.5))
                    } else {
                        TagPillRow(
                            tags: currentRecord.symptoms.map { $0.rawValue },
                            foreground: .white,
                            background: Color.easeAccent
                        )
                        if let other = currentRecord.otherSymptom, !other.isEmpty {
                            Text("其他：\(other)")
                                .font(.footnote)
                                .foregroundStyle(Color.easeTextSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.easeCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Eating Habits
                if !currentRecord.eatingHabits.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("進食習慣")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .tracking(0.8)

                        TagPillRow(
                            tags: currentRecord.eatingHabits.map(\.rawValue),
                            foreground: .white,
                            background: Color.easeAccent
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Food
                if !currentRecord.foodTags.isEmpty || !currentRecord.note.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("吃了什麼")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .tracking(0.8)

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
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Dining Type
                if let diningType = currentRecord.diningType {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("用餐方式")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .tracking(0.8)

                        HStack(spacing: 4) {
                            Image(systemName: "bag")
                                .font(.caption)
                            Text(diningType.rawValue)
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.easeTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Additional notes
                if let note = currentRecord.additionalNote, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("備註")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .tracking(0.8)
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(Color.easeTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
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
            RecordView(existingRecord: rec)
        }
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(record: mockRecords[0])
    }
}
