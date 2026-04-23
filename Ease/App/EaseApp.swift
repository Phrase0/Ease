//
//  EaseApp.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/17.
//

import SwiftUI
import CoreData

@main
struct EaseApp: App {
    @StateObject private var store: RecordStore

    init() {
        let context = PersistenceController.shared.container.viewContext
        // 目前：CoreData
        _store = StateObject(wrappedValue: RecordStore(
            repository: CoreDataRecordRepository(context: context)
        ))
                                                                  
        // 切回 Mock：
//        _store = StateObject(wrappedValue: RecordStore(
//            repository: MockRecordRepository()
//        ))

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
