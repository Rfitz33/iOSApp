//
//  HelperViews.swift
//  LocationBasedGame
//
//  Created by Reid on 6/14/25.
//
import SwiftUI


// MARK: - Helper UI Components
struct SectionHeader: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2) // Slightly larger for section titles
                .fontWeight(.semibold)
            Divider()
        }
        .padding(.vertical, 5) // Add some vertical spacing around headers
    }
}

struct CraftingButtonView: View {
    @ObservedObject var gameManager: GameManager
    let componentType: ComponentType
    
    var body: some View {
        if let recipe = componentType.recipe {
            var costDisplayItems: [String] = [] // Use a more descriptive name
            
            // Iterate over resource ingredients (if any)
            if let resourceIngredients = recipe.ingredients {
                for (resource, amount) in resourceIngredients where amount > 0 {
                    costDisplayItems.append("\(amount) \(resource.displayName)")
                }
            }
            
            // Iterate over component ingredients (if any - your ComponentType.Recipe supports this)
            if let componentIngredients = recipe.components {
                for (component, amount) in componentIngredients where amount > 0 {
                    costDisplayItems.append("\(amount) \(component.displayName)")
                }
            }
            
            let displayCostString = costDisplayItems.isEmpty ?
            ( (recipe.ingredients?.isEmpty ?? true) && (recipe.components?.isEmpty ?? true) ? "Cost: Free" : "Recipe Error" )
            : "Cost: " + costDisplayItems.joined(separator: ", ")
            
            return AnyView( // Ensure consistent return type
                Button(action: {
                    if gameManager.canCraftComponent(componentType) {
                        _ = gameManager.craftComponent(componentType)
                    }
                }) {
                    VStack {
                        Text("Craft \(componentType.displayName)").fontWeight(.bold)
                        Text(displayCostString).font(.caption)
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    .frame(maxWidth: .infinity)
                }
                    .buttonStyle(.borderedProminent)
                    .disabled(!gameManager.canCraftComponent(componentType))
            )
        } else {
            return AnyView(Text("No recipe for \(componentType.displayName)").foregroundColor(.red))
        }
    }
}

struct ItemCraftingButtonView: View {
    @ObservedObject var gameManager: GameManager
    let itemType: ItemType
    
    var body: some View {
        guard let recipe = itemType.recipe else {
            return AnyView(Text("No recipe for \(itemType.displayName)").foregroundColor(.red))
        }
        
        var costDisplayItems: [String] = []
        
        // Iterate over resource ingredients (if any)
        if let resourceIngredients = recipe.resources {
            for (resource, amount) in resourceIngredients where amount > 0 {
                costDisplayItems.append("\(amount) \(resource.displayName)")
            }
        }
        
        // Iterate over component ingredients (if any)
        if let componentIngredients = recipe.components {
            for (component, amount) in componentIngredients where amount > 0 {
                costDisplayItems.append("\(amount) \(component.displayName)")
            }
        }
        
        let displayCostString = costDisplayItems.isEmpty ?
        ( (recipe.resources?.isEmpty ?? true) && (recipe.components?.isEmpty ?? true) ? "Cost: Free" : "Recipe Error (Check ItemRecipe)" )
        : "Cost: " + costDisplayItems.joined(separator: ", ")
        
        return AnyView(
            Button(action: {
                if gameManager.canCraftItem(itemType) {
                    _ = gameManager.craftItem(itemType)
                }
            }) {
                VStack {
                    Text("Craft \(itemType.displayName)").fontWeight(.bold)
                    Text(displayCostString).font(.caption)
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .tint(itemType == .T1_axe || itemType == .T2_pickaxe ? .orange : .accentColor) // Example tint
                .disabled(!gameManager.canCraftItem(itemType))
        )
    }
}

// A reusable, styled NavigationLink for menu lists.
struct InventoryCategoryLink: View {
    let title: String
    let systemImage: String
    let destination: any View // Use 'any View' for type erasure

    var body: some View {
        // We wrap the destination in an AnyView for type erasure.
        NavigationLink(destination: AnyView(destination)) {
            HStack(spacing: 15) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30) // Ensures text alignment is consistent
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.vertical, 8) // Add some vertical padding to make rows taller
        }
        // This makes the text color standard, not the default blue link color.
        .foregroundColor(.primary)
    }
}

struct UpgradeButtonView: View {
    let title: String
    let isActive: Bool
    let activeText: String
    let activeIcon: String
    let activeColor: Color
    let costString: String
    let canPerformAction: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) { // Changed alignment to leading for title
            // Title of the upgrade section (e.g., "Sanctum Ward")
            // Text(title).font(.headline) // Optional: if you want the title separate from button/status
            
            if isActive {
                HStack {
                    Image(systemName: activeIcon).foregroundColor(activeColor)
                    Text(activeText).foregroundColor(activeColor)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10) // Give it similar padding to a button
            } else {
                Button(action: action) {
                    VStack {
                        Text(title).fontWeight(.semibold) // Title is now part of the button
                        Text(costString).font(.caption)
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered) // Use .bordered for available upgrades
                .disabled(!canPerformAction)
            }
        }
        .padding() // Padding around the content of the "card"
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .secondarySystemBackground)))
        // .frame(maxWidth: .infinity) // Frame on the VStack if it needs to span width
    }
}
