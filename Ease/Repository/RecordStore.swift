//
//  RecordStore.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation
import Combine

class RecordStore: ObservableObject {
    @Published private(set) var records: [MealRecord] = []

    private let repository: RecordRepositoryProtocol

    init(repository: RecordRepositoryProtocol = MockRecordRepository()) {
        self.repository = repository
        self.records = repository.fetchAll()
    }

    func add(_ record: MealRecord) {
        repository.add(record)
        records = repository.fetchAll()
    }

    func update(_ record: MealRecord) {
        repository.update(record)
        records = repository.fetchAll()
    }

    func delete(_ record: MealRecord) {
        repository.delete(record)
        records = repository.fetchAll()
    }
}
