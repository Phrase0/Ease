//
//  RecordDetailView.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import SwiftUI

struct RecordDetailView: View {
    let record: MealRecord
    @State private var isEditing = false

    var body: some View {
        ZStack {
            Color.easeBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // Header: date, time, meal type
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.date, style: .date)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.easeTextPrimary)
                            Text(record.date, style: .time)
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextSecondary)
                        }
                        Spacer()
                        Text(record.mealType.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.easeAccent.opacity(0.12))
                            .foregroundStyle(Color.easeAccent)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Food
                    if !record.foodTags.isEmpty || !record.note.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("吃了什麼")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.easeTextSecondary)
                                .tracking(0.8)

                            if !record.foodTags.isEmpty {
                                TagPillRow(
                                    tags: record.foodTags.map(\.rawValue),
                                    foreground: Color.easeAccent,
                                    background: Color.easeAccent.opacity(0.1)
                                )
                            }

                            if !record.note.isEmpty {
                                Text(record.note)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.easeTextSecondary)
                            }

                            if let diningType = record.diningType {
                                HStack(spacing: 4) {
                                    Image(systemName: "bag")
                                        .font(.caption)
                                    Text(diningType.rawValue)
                                        .font(.caption)
                                }
                                .foregroundStyle(Color.easeTextSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.easeCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Symptoms
                    VStack(alignment: .leading, spacing: 10) {
                        Text("症狀")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.easeTextSecondary)
                            .tracking(0.8)

                        if record.symptoms.isEmpty {
                            Text("無症狀")
                                .font(.subheadline)
                                .foregroundStyle(Color.easeTextSecondary.opacity(0.6))
                        } else {
                            TagPillRow(
                                tags: record.symptoms.map { "\($0.emoji) \($0.rawValue)" },
                                foreground: Color.easeSymptom,
                                background: Color.easeSymptom.opacity(0.1)
                            )
                            if let other = record.otherSymptom, !other.isEmpty {
                                Text("其他：\(other)")
                                    .font(.caption)
                                    .foregroundStyle(Color.easeTextSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.easeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Additional notes
                    if let note = record.additionalNote, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
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
            }
        }
        .navigationTitle("詳細紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.easeBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編輯") { isEditing = true }
                    .foregroundStyle(Color.easeAccent)
            }
        }
        .sheet(isPresented: $isEditing) {
            RecordView(existingRecord: record)
        }
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(record: mockRecords[0])
    }
}
