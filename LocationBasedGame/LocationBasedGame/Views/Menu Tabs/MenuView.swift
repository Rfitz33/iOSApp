import SwiftUI

// MARK: - MenuView
struct MenuView: View {
    @ObservedObject var gameManager: GameManager // To display inventory and other game states
    @Environment(\.dismiss) var dismiss // To close the sheet
    
    let startingTab: ActiveSheet
    @State private var selectedTab: ActiveSheet
    
    init(gameManager: GameManager, startingTab: ActiveSheet) {
        self.gameManager = gameManager
        self.startingTab = startingTab
        _selectedTab = State(initialValue: startingTab)
    }
    
    var body: some View {
            ZStack {
                // Shared background for all tabs
                Image("menu_background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                Rectangle().fill(.ultraThinMaterial).edgesIgnoringSafeArea(.all)

                TabView(selection: $selectedTab) {
                    // Each tab now hosts its respective view
                    PlayerTabView(gameManager: gameManager)
                        .tag(ActiveSheet.player)
                        .tabItem { Label("Player", systemImage: "person.fill") }
                    
                    StatsTabView(gameManager: gameManager)
                        .tag(ActiveSheet.stats)
                        .tabItem { Label("Stats", systemImage: "chart.bar.xaxis") }

                    SkillsTabView(gameManager: gameManager)
                        .tag(ActiveSheet.skills)
                        .tabItem { Label("Skills", systemImage: "sparkles") }
                    
                    SanctumTabView(gameManager: gameManager)
                        .tag(ActiveSheet.sanctum)
                        .tabItem { Label("Sanctum", systemImage: "house.fill") }
                    
                    CompanionsTabView(gameManager: gameManager)
                        .tag(ActiveSheet.companions)
                        .tabItem { Label("Companions", systemImage: "hare.fill") }
                    
                    SettingsView(gameManager: gameManager)
                        .tag(ActiveSheet.settings)
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                }
                .onAppear {
                    // Style the tab bar
                    let appearance = UITabBarAppearance()
                    appearance.configureWithDefaultBackground()
                    appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
    }

// MARK: - Helper View for Menu Sections
    // This helper view is kept as it provides the nice styling for each section.
        struct MenuSection<Content: View>: View {
            let title: String
            @ViewBuilder let content: Content

            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.leading)

                    VStack(alignment: .leading) { // Add alignment for content
                        content
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .buttonStyle(.plain) // Ensures entire rows are tappable for NavigationLinks
                }
            }
        }

struct MenuView_Previews: PreviewProvider {
    
    // 1. Create a Mock GameManager specifically for previews.
    class MockGameManager: GameManager {
        // We override the init to populate it with sample data.
        override init() {
            super.init() // Call the parent initializer first
            
            // --- Populate with sample data to make the preview look real ---
            
            // Give the player some levels and XP
            self.playerSkillsXP[.mining] = 1250 // Should be level 13
            self.playerSkillsXP[.smithing] = 340 // Should be level 4
            self.updateAllSkillLevelsFromXP() // Calculate levels from XP
            
            // Equip some gear
            //                self.equippedGear[.pickaxe] = .T2_pickaxe
            //                self.equippedGear[.necklace] = .T1_necklace
            
            // Pretend some base upgrades are built
            self.activeBaseUpgrades.insert(.basicForge)
            self.activeBaseUpgrades.insert(.aviary)
            
            // Add a companion to the list
            var raven = Creature(type: .raven)
            raven.state = .trainedAdult // Make it a trained adult for the preview
            self.ownedCreatures.append(raven)
            
            // Set an active pet
            self.activeCreatureID = raven.id
            
            // Add some resources to the inventory
            self.playerInventory[.T1_stone] = 50
            self.playerInventory[.T2_stone] = 25
        }
    }
    
    // 2. This is the required 'previews' property.
    static var previews: some View {
        // Create an instance of our mock manager.
        let mockGameManager = MockGameManager()
        
        // Wrap the MenuView in a NavigationView so the links work in the preview.
        NavigationView {
            // Pass the mock manager to the MenuView.
            MenuView(gameManager: mockGameManager, startingTab: .player)
            // Add previews for different states, like dark mode or different devices.
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // Example for a smaller device
            NavigationView {
                MenuView(gameManager: mockGameManager, startingTab: .player)
            }
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE")
        }
    }
}
