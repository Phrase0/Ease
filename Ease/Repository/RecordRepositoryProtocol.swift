//
//  RecordRepositoryProtocol.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation

protocol RecordRepositoryProtocol {
    func fetchAll() -> [MealRecord]
    func add(_ record: MealRecord)
    func update(_ record: MealRecord)
    func delete(_ record: MealRecord)
}
