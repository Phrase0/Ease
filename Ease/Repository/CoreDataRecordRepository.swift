//
//  CoreDataRecordRepository.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import CoreData

// TODO: Implement when migrating to CoreData.
//
// Migration checklist:
//   1. Define MealRecordEntity in .xcdatamodeld with attributes matching MealRecord fields
//      (store enum rawValues as String, arrays as Transformable or related entities)
//   2. Inject NSManagedObjectContext via init
//   3. fetchAll: NSFetchRequest<MealRecordEntity> → map to [MealRecord]
//   4. add / update / delete: create/fetch entity, map fields, context.save()
//   5. Observe NSManagedObjectContextObjectsDidChange to notify RecordStore of external changes
//
// Swap in EaseApp.swift:
//   RecordStore(repository: CoreDataRecordRepository(context: persistenceController.container.viewContext))

class CoreDataRecordRepository: RecordRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> [MealRecord] {
        // TODO: NSFetchRequest<MealRecordEntity> + map to MealRecord structs
        return []
    }

    func add(_ record: MealRecord) {
        // TODO: create MealRecordEntity, map from record, context.save()
    }

    func update(_ record: MealRecord) {
        // TODO: fetch entity by record.id, update fields, context.save()
    }

    func delete(_ record: MealRecord) {
        // TODO: fetch entity by record.id, context.delete(entity), context.save()
    }
}
