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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.displayDate)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.easeTextPrimary)
                    Text("\(record.displayTime) \(record.displayAmPm)")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(Color.easeTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    Text(record.mealType.rawValue)
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

                // Food
                if !record.foodTags.isEmpty || !record.note.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
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
                                .foregroundStyle(Color.easeTextPrimary)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("症狀")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.easeTextSecondary)
                        .tracking(0.8)

                    if record.symptoms.isEmpty {
                        Text("無症狀")
                            .font(.callout)
                            .foregroundStyle(Color.easeTextSecondary.opacity(0.5))
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
