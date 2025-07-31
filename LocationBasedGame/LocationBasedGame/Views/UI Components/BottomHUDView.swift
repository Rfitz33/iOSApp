//
//  to.swift
//  LocationBasedGame
//
//  Created by Reid on 7/26/25.
//


// BottomHUDView.swift
import SwiftUI

//enum ActiveSheet: Identifiable {
//    case player, stats, skills, sanctum, companions, settings
//    var id: Self { self }
//}

struct BottomHUDView: View {
    @ObservedObject var gameManager: GameManager
    
    @State private var sheetToPresent: ActiveSheet?

    var body: some View {
        // Use a GeometryReader to get the available width for our columns.
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                // --- Left Column: Tab Buttons (approx 30% of width) ---
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        TabButton(iconAssetName: ActiveSheet.player.iconName, sheet: .player, sheetToPresent: $sheetToPresent)
                        TabButton(iconAssetName: ActiveSheet.stats.iconName, sheet: .stats, sheetToPresent: $sheetToPresent)
                    }
                    HStack(spacing: 8) {
                        TabButton(iconAssetName: ActiveSheet.skills.iconName, sheet: .skills, sheetToPresent: $sheetToPresent)
                        TabButton(iconAssetName: ActiveSheet.sanctum.iconName, sheet: .sanctum, sheetToPresent: $sheetToPresent)
                    }
                    HStack(spacing: 8) {
                        TabButton(iconAssetName: ActiveSheet.companions.iconName, sheet: .companions, sheetToPresent: $sheetToPresent)
                        TabButton(iconAssetName: ActiveSheet.settings.iconName, sheet: .settings, sheetToPresent: $sheetToPresent)
                    }
                }
                .frame(width: geometry.size.width * 0.30) // Assign a percentage of the width
                .padding(.leading, 8)

                // --- Divider ---
                Rectangle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 2)
                    .padding(.vertical, 2)

                // --- Right Column: Message Log (fills the rest of the space) ---
                MessageLogView(gameManager: gameManager)
                    .padding(.trailing, 8)
                    .padding(.leading, 8)
                    .padding(.bottom, 5)
                    .padding(.top, 5)

            }
            .fullScreenCover(item: $sheetToPresent) { sheet in
                // When a button is tapped, this presents the MenuView,
                // telling it which tab to open to.
                MenuView(gameManager: gameManager, startingTab: sheet)
            }
            .padding(.top, 10)
            // Add padding at the bottom to push content up from the home indicator
            .padding(.bottom, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.bottom)
        }
        .frame(height: 170) // A fixed height for the entire bottom bar
        .background(.ultraThinMaterial)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .allowsHitTesting(true)
        .sheet(item: $sheetToPresent) { sheet in
            // To get title bars, each presented view must be in a NavigationView
            switch sheet {
            case .player: NavigationView { PlayerTabView(gameManager: gameManager) }
            case .stats: NavigationView { StatsTabView(gameManager: gameManager) }
            case .skills: NavigationView { SkillsTabView(gameManager: gameManager) }
            case .sanctum: NavigationView { SanctumTabView(gameManager: gameManager) }
            case .companions: NavigationView { CompanionsTabView(gameManager: gameManager) }
            case .settings: NavigationView { SettingsView(gameManager: gameManager) }
            }
        }
    }
}

// --- Helper for the Tab Buttons ---
struct TabButton: View {
    // The properties are unchanged
    let iconAssetName: String // Changed the name for clarity
    let sheet: ActiveSheet
    @Binding var sheetToPresent: ActiveSheet?
    
    var body: some View {
        Button {
            sheetToPresent = sheet
        } label: {
            // Use the standard Image initializer for your custom assets
            Image(iconAssetName)
                .resizable()
                .scaledToFit()
                // Add padding inside the button to control the icon's size relative to the button frame
//                .padding(1) // You can adjust this number (e.g., 6, 10) to make the icon larger or smaller
                .foregroundColor(.primary) // .renderingMode(.template) might be needed in Assets
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.opacity(0.15))
        .cornerRadius(10)
        .aspectRatio(1, contentMode: .fit) // This forces the button to be a perfect square
    }
}

struct BottomHUDView_Previews: PreviewProvider {

    // A simple mock GameManager is all we need.
    class MockHUDGameManager: GameManager {
        override init() {
            super.init()
            // Add a few log messages to see the log view.
            logMessage("Preview: Game Started", type: .standard)
            logMessage("Preview: Found 10 Stone", type: .success)
        }
    }
    
    // A wrapper to provide the @State variable for the preview.
    struct PreviewWrapper: View {
        @State private var mockSheet: ActiveSheet? = nil
        
        var body: some View {
            // We put the BottomHUDView inside a VStack and add a background
            // to simulate how it looks in the actual game.
            VStack {
                Spacer() // Pushes the HUD to the bottom
                BottomHUDView(
                    gameManager: MockHUDGameManager()
                    // The 'activeSheet' binding is now managed by the wrapper.
                )
            }
            .background(Color.gray) // A neutral background for context
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("Bottom HUD Preview")
    }
}



//struct TabButton: View {
//    let icon: String
//    let sheet: ActiveSheet
//    @Binding var sheetToPresent: ActiveSheet?
//    
//    var body: some View {
//        Button {
//            sheetToPresent = sheet
//        } label: {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(.primary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the button fill the space
//        }
//        .background(Color.black.opacity(0.15))
//        .cornerRadius(10)
//        .aspectRatio(1, contentMode: .fit) // Ensure buttons are square
//    }
//}
