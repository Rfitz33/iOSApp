//
//  HomeBaseView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/16/25.
//
import SwiftUI

// Helper struct for grid positions to be dictionary keys
struct GridPosition: Hashable, Equatable {
    let row: Int
    let col: Int
}

// MARK: - HomeBaseView
struct HomeBaseView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss

    // --- Sheet Presentation States ---
    @State private var showingSanctumActionsSheet: Bool = false      // For Sanctum's basic crafting
    @State private var structureToShowActionsFor: BaseUpgradeType? = nil // For built structures' actions
    @State private var upgradeToBuild: BaseUpgradeType? = nil          // For building unbuilt structures

    // --- Grid Configuration ---
    private let gridRows = 5
    private let gridColumns = 3
    // Calculate TILE_SIZE based on screen width and number of columns, allowing for small inter-tile spacing visually
    private var TILE_SIZE: CGFloat {
        let availableWidth = UIScreen.main.bounds.width // - (CGFloat(gridColumns + 1) * 1) // 5pt spacing between/around tiles
        return availableWidth / CGFloat(gridColumns)
    }
    private let gridCellSpacing: CGFloat = 0


    // --- Helper Functions specific to HomeBaseView ---
    private func getCostString(for upgradeType: BaseUpgradeType) -> String {
        guard let upgradeDef = gameManager.getUpgradeDefinition(for: upgradeType) else { return "Cost: N/A" }
        var items: [String] = []
        upgradeDef.resources?.forEach { (resource, amount) in if amount > 0 { items.append("\(amount) \(resource.displayName)") } }
        upgradeDef.components?.forEach { (component, amount) in if amount > 0 { items.append("\(amount) \(component.displayName)") } }
        return items.isEmpty ? "Cost: Free" : "Cost: " + items.joined(separator: ", ")
    }
    
    // Asset names for SINGLE-TILE built structures OR BASE PARTS of multi-tile
    private func assetNameForBuiltStructurePart(_ upgradeType: BaseUpgradeType, isBasePart: Bool = true) -> String {
        // isBasePart helps if a multi-tile structure has different assets for its main vs other parts
        switch upgradeType {
        case .basicForge: return "forge_tile_built"
        case .woodworkingShop: return "woodworking_shop_tile_built"
        case .tanningRack: return "tanning_rack_tile_built"
        case .apothecaryStand: return "apothecary_tile_built"
        case .scoutsQuarters: return "scouts_quarters_tile_built"
        case .basicStorehouse: return "storehouse_tile_built"
        case .alchemyLab: return "alchemy_lab_tile_built"
        case .aviary: return "aviary_tile_built"
        case .jewelCraftingWorkshop: return "jewelcrafting_workshop_tile_built"
        case .fletchingWorkshop: return "fletching_workshop_tile_built"
        case .garden: return isBasePart ? "garden_south" : "garden_north"
        case .watchtower: return isBasePart ? "watchtower_base" : "watchtower_top"
        }
    }
    
    // This defines the "anchor" or primary buildable slot for each upgrade type.
    // The key is the (row, col) tuple, value is the BaseUpgradeType.
    private let baseLayout: [GridPosition: BaseUpgradeType] = [
        GridPosition(row: 0, col: 0): .aviary,
        GridPosition(row: 1, col: 0): .jewelCraftingWorkshop,
        GridPosition(row: 1, col: 1): .garden,      // This is the "base" of the garden
        GridPosition(row: 1, col: 2): .watchtower,  // This is the "base" of the watchtower
        GridPosition(row: 2, col: 0): .fletchingWorkshop,
        GridPosition(row: 2, col: 1): .scoutsQuarters,
        GridPosition(row: 2, col: 2): .alchemyLab,
        GridPosition(row: 3, col: 0): .tanningRack,
        GridPosition(row: 3, col: 1): .basicStorehouse,
        GridPosition(row: 3, col: 2): .apothecaryStand,
        GridPosition(row: 4, col: 0): .basicForge,
        // (4,1) is Central Sanctum
        GridPosition(row: 4, col: 2): .woodworkingShop
    ]
    
    // NEW - Defining as a GridPosition instance
    private let centralSanctumGridPos = GridPosition(row: 4, col: 1)
    
    // Helper method to determine tile content
    private func determineTileContent(row: Int, col: Int) -> (imageName: String, isPlotPlaceholder: Bool, associatedUpgrade: BaseUpgradeType?, isActuallyBuilt: Bool) {
        let currentPos = GridPosition(row: row, col: col)
        var imageName = "grass_tile" // Default base tile for empty, non-buildable land
        var isPlotPlaceholder = false // Is it an empty_plot_tile or a specific building?
        var associatedUpgradeForTap: BaseUpgradeType? = nil
        var currentTileIsBuilt = false

        if currentPos == centralSanctumGridPos {
            return ("sanctum_tile", false, nil, true) // Sanctum isn't "built" via upgrades, it just is. Tap action special.
        }

        // Check for "top" parts of multi-tile structures that overlay other cells
        // Garden Plants (assumes garden base is at row+1, col, meaning garden plants are visually "above" its base)
        if let gardenAnchorPos = baseLayout.first(where: { $0.value == .garden })?.key,
           gameManager.activeBaseUpgrades.contains(.garden) &&
           gardenAnchorPos.row == row + 1 && gardenAnchorPos.col == col {
            return ("garden_north", false, .garden, true)
        }
        // Watchtower Top
        if let watchtowerAnchorPos = baseLayout.first(where: { $0.value == .watchtower })?.key,
           gameManager.activeBaseUpgrades.contains(.watchtower) &&
           watchtowerAnchorPos.row == row + 1 && watchtowerAnchorPos.col == col {
            return ("watchtower_top", false, .watchtower, true)
        }

        // Check for defined upgrade anchor slots from baseLayout
        if let upgradeTypeInSlot = baseLayout[currentPos] {
            associatedUpgradeForTap = upgradeTypeInSlot
            if gameManager.activeBaseUpgrades.contains(upgradeTypeInSlot) {
                currentTileIsBuilt = true
                switch upgradeTypeInSlot {
                case .garden: imageName = "garden_south"
                case .watchtower: imageName = "watchtower_base"
                default: imageName = assetNameForBuiltStructurePart(upgradeTypeInSlot)
                }
            } else {
                imageName = "unbuilt" // This is a buildable, unbuilt plot
                isPlotPlaceholder = true
                currentTileIsBuilt = false
            }
            return (imageName, isPlotPlaceholder, associatedUpgradeForTap, currentTileIsBuilt)
        }
        
        // If no specific structure or plot, it's just a grass tile
        return (imageName, false, nil, false)
    }
    
    private func handleTileTap(row: Int, col: Int) {
        let tappedPosition = GridPosition(row: row, col: col)

        if tappedPosition == centralSanctumGridPos {
            print("Central Sanctum (Basic Workshop) Tapped")
            showingSanctumActionsSheet = true // Show basic crafting (Tier 1 tools)
            return
        }

        let (_, _, associatedUpgrade, isActuallyBuilt) = determineTileContent(row: row, col: col)

        guard let type = associatedUpgrade else {
            print("Tapped an empty decorative grass tile at (\(row),\(col))")
            return
        }

        if isActuallyBuilt {
            print("Tapped built: \(type.displayName)")
            self.structureToShowActionsFor = type // Set this to trigger the unified action sheet
        } else {
            // Not built, but it's a defined buildable plot
            print("Tapped unbuilt slot for: \(type.displayName)")
            self.upgradeToBuild = type // Set this to trigger the UpgradePromptView
        }
    }
    
    // --- Body ---
        var body: some View {
            let _ = print("HBV Rendering - Active Upgrades: \(gameManager.activeBaseUpgrades.map { $0.displayName })")
            NavigationView { // Keep NavigationView for sheet presentation context & potential title bar
                ZStack {
                    Image("standard_tile").resizable(resizingMode: .tile).edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("Your Sanctum")
                            .font(.largeTitle).bold().foregroundColor(.white).shadow(radius: 2)
                            .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + 10)
                            .padding(.bottom, 15)

                        Grid(horizontalSpacing: gridCellSpacing, verticalSpacing: gridCellSpacing) {
                            ForEach(0..<gridRows, id: \.self) { rowIndex in
                                GridRow {
                                    ForEach(0..<gridColumns, id: \.self) { colIndex in
                                        let tileInfo = determineTileContent(row: rowIndex, col: colIndex)
                                        
                                        Image(tileInfo.imageName)
                                            .resizable().scaledToFit()
                                            .frame(width: TILE_SIZE, height: TILE_SIZE)
                                            .opacity(tileInfo.isPlotPlaceholder && !tileInfo.isActuallyBuilt ? 0.6 : 1.0)
                                            .onTapGesture {
                                                handleTileTap(row: rowIndex, col: colIndex)
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, gridCellSpacing) // Overall padding for the grid

                        Spacer() // Pushes Exit button to bottom

                        Button("Exit Sanctum") { dismiss() }
                            .padding().buttonStyle(.borderedProminent)
                            .padding(.bottom, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.bottom ?? 0 + 10)
                    }
                }
                .navigationBarHidden(true) // For a truly immersive full-screen base, hide the NavigationView bar
                // --- Sheet for Building an UNBUILT Upgrade ---
                .sheet(item: $upgradeToBuild) { upgradeTypeToBuild in // BaseUpgradeType must be Identifiable
                    UpgradePromptView(
                        gameManager: gameManager,
                        upgradeType: upgradeTypeToBuild
                    )
                }
                // --- Sheet for actions of BUILT Structures ---
                .fullScreenCover(item: $structureToShowActionsFor) { structureType in // BaseUpgradeType must be Identifiable
                    // Determine which view to show based on structureType
                    switch structureType {
                    case .basicForge: ForgeActionsView(gameManager: gameManager)
                    case .woodworkingShop: WoodworkingShopActionsView(gameManager: gameManager)
                    case .tanningRack: TanningActionsView(gameManager: gameManager)
                    case .apothecaryStand: ApothecaryActionsView(gameManager: gameManager)
                    case .scoutsQuarters: ScoutsQuartersView(gameManager: gameManager)
                    case .garden: GardenView(gameManager: gameManager) // Placeholder View
                    case .watchtower: WatchtowerView(gameManager: gameManager, locationManager: locationManager)
                    case .aviary: AviaryView(gameManager: gameManager)
                    case .jewelCraftingWorkshop: JewelCraftingView(gameManager: gameManager)
                    case .fletchingWorkshop: FletchingView(gameManager: gameManager)
                    case .alchemyLab: AlchemyLabActionsView(gameManager: gameManager)
                    case .basicStorehouse: StorehouseView(gameManager: gameManager)
                    // No default needed if all BaseUpgradeType cases are handled or have placeholders
                    }
                }
                // --- Sheet for Sanctum's own basic crafting actions ---
                .sheet(isPresented: $showingSanctumActionsSheet) {
                    SanctumActionsView(gameManager: gameManager) // The view for T1 tool crafting
                }
            } // End of NavigationView
        }
    }

