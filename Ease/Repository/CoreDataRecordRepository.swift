//
//  CoreDataRecordRepository.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import CoreData

class CoreDataRecordRepository: RecordRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> [MealRecord] {
        let request = NSFetchRequest<MealRecordEntity>(entityName: "MealRecordEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request).map { $0.toModel() }
        } catch {
            return []
        }
    }

    func add(_ record: MealRecord) {
        let entity = MealRecordEntity(context: context)
        entity.update(from: record)
        save()
    }

    func update(_ record: MealRecord) {
        guard let entity = fetchEntity(id: record.id) else { return }
        entity.update(from: record)
        save()
    }

    func delete(_ record: MealRecord) {
        guard let entity = fetchEntity(id: record.id) else { return }
        context.delete(entity)
        save()
    }

    private func fetchEntity(id: UUID) -> MealRecordEntity? {
        let request = NSFetchRequest<MealRecordEntity>(entityName: "MealRecordEntity")
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}

private extension MealRecordEntity {
    func update(from record: MealRecord) {
        id = record.id
        date = record.date
        mealType = record.mealType.rawValue
        note = record.note
        diningType = record.diningType?.rawValue
        otherSymptom = record.otherSymptom
        additionalNote = record.additionalNote
        foodTagsData = try? JSONEncoder().encode(record.foodTags)
        symptomsData = try? JSONEncoder().encode(record.symptoms)
        eatingHabitsData = try? JSONEncoder().encode(record.eatingHabits)
    }

    func toModel() -> MealRecord {
        MealRecord(
            id: id ?? UUID(),
            date: date ?? Date(),
            mealType: MealType(rawValue: mealType ?? "") ?? .lunch,
            foodTags: decoded([FoodTag].self, from: foodTagsData) ?? [],
            note: note ?? "",
            diningType: diningType.flatMap { DiningType(rawValue: $0) },
            eatingHabits: decoded([EatingHabit].self, from: eatingHabitsData) ?? [],
            symptoms: decoded([Symptom].self, from: symptomsData) ?? [],
            otherSymptom: otherSymptom,
            additionalNote: additionalNote
        )
    }

    private func decoded<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
