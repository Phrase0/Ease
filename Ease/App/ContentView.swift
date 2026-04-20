import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HistoryListView()
                .tabItem {
                    Label("紀錄", systemImage: "list.bullet")
                }

            CalendarPageView()
                .tabItem {
                    Label("日曆", systemImage: "calendar")
                }

            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }
        }
        .tint(Color.easeAccent)
    }
}

#Preview {
    ContentView()
}
