//
//  EaseApp.swift
//  Ease
//
//  Created by Peiyun on 2026/4/17.
//

import SwiftUI
import CoreData

@main
struct EaseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
