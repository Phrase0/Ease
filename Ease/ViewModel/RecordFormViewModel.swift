//
//  RecordFormViewModel.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

class RecordFormViewModel: ObservableObject {
    @Published var date: Date
    @Published var selectedMealType: MealType
    @Published var selectedFoodTags: Set<FoodTag>
    @Published var foodNote: String
    @Published var selectedDiningType: DiningType?
    @Published var selectedEatingHabits: Set<EatingHabit>
    @Published var selectedSymptoms: Set<Symptom>
    @Published var otherSymptomText: String
    @Published var additionalNote: String

    let existingRecord: MealRecord?

    init(existingRecord: MealRecord? = nil) {
        self.existingRecord = existingRecord
        date               = existingRecord?.date ?? Date()
        selectedMealType   = existingRecord?.mealType ?? .lunch
        selectedFoodTags   = Set(existingRecord?.foodTags ?? [])
        foodNote           = existingRecord?.note ?? ""
        selectedDiningType = existingRecord?.diningType
        selectedEatingHabits = Set(existingRecord?.eatingHabits ?? [])
        selectedSymptoms   = Set(existingRecord?.symptoms ?? [])
        otherSymptomText   = existingRecord?.otherSymptom ?? ""
        additionalNote     = existingRecord?.additionalNote ?? ""
    }

    func toggleFoodTag(_ tag: FoodTag) {
        if selectedFoodTags.contains(tag) { selectedFoodTags.remove(tag) }
        else { selectedFoodTags.insert(tag) }
    }

    func toggleEatingHabit(_ habit: EatingHabit) {
        if selectedEatingHabits.contains(habit) { selectedEatingHabits.remove(habit) }
        else { selectedEatingHabits.insert(habit) }
    }

    func toggleSymptom(_ symptom: Symptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
            if symptom == .other { otherSymptomText = "" }
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    func save(to store: RecordStore) {
        let record = MealRecord(
            id: existingRecord?.id ?? UUID(),
            date: date,
            mealType: selectedMealType,
            foodTags: FoodTag.allCases.filter { selectedFoodTags.contains($0) },
            note: foodNote,
            diningType: selectedDiningType,
            eatingHabits: EatingHabit.allCases.filter { selectedEatingHabits.contains($0) },
            symptoms: Symptom.allCases.filter { selectedSymptoms.contains($0) },
            otherSymptom: otherSymptomText.isEmpty ? nil : otherSymptomText,
            additionalNote: additionalNote.isEmpty ? nil : additionalNote
        )
        if existingRecord != nil {
            store.update(record)
        } else {
            store.add(record)
        }
    }
}
