//
//  MockRecordRepository.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation

class MockRecordRepository: RecordRepositoryProtocol {
    private var records: [MealRecord] = mockRecords

    func fetchAll() -> [MealRecord] { records }

    func add(_ record: MealRecord) {
        records.append(record)
    }

    func update(_ record: MealRecord) {
        guard let idx = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[idx] = record
    }

    func delete(_ record: MealRecord) {
        records.removeAll { $0.id == record.id }
    }
}
