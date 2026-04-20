//
//  EaseApp.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/17.
//

import SwiftUI

@main
struct EaseApp: App {
    @StateObject private var store = RecordStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
