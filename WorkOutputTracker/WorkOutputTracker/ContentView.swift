import SwiftUI

enum AppTab: Hashable {
    case workouts
    case history
    case progress
}

struct ContentView: View {
    
    @State private var selectedTab: AppTab = .workouts
    @State private var showDetailForLogID: UUID?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutsView(
                onViewResults: { logID in
                    showDetailForLogID = logID
                    selectedTab = .history
                }
            )
            .tabItem { Label("Workouts", systemImage: "flame") }
            .tag(AppTab.workouts)

            HistoryView(showDetailForLogID: $showDetailForLogID)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(AppTab.history)
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

// Placeholder views for each tab
struct ProgressView: View { var body: some View { Text("Progress Tab") } }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
