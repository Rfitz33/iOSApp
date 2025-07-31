import SwiftUI
import SwiftData

@main
struct RestaurantChooserApp: App {
    // Define the shared model container
    var sharedModelContainer: ModelContainer = {
        // Define the schema including all your @Model classes
        let schema = Schema([
            FavoriteRestaurant.self,
            // Add other @Model classes here if you have more
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // Use false for persistent storage

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }() // This initializes the container once

    var body: some Scene {
        WindowGroup {
            // Inject the LocationManager as an EnvironmentObject if needed across tabs
             //ContentView() // Your starting view
            MainTabView() // We will create this TabView next
        }
        .modelContainer(sharedModelContainer) // Apply the container to the scene
    }
}
