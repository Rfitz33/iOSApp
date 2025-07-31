//
//  ItemDetailView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/15/25.
//


import SwiftUI

// MARK: - ItemDetailView
struct ItemDetailView: View {
    @ObservedObject var gameManager: GameManager // To use potions
    let inspectableItem: InspectableItem
    @Environment(\.dismiss) var dismiss
    
    // STATE FOR DROP AMOUNT
    @State private var showDropConfirmation = false
    @State private var dropAmountString: String = "1" // For text field
    
    // Use an enum to pass different types of inventory items
    enum InspectableItem {
        case resource(ResourceType)
        case component(ComponentType)
        case item(ItemType)
        
        var displayName: String {
            switch self {
            case .resource(let type): return type.displayName
            case .component(let type): return type.displayName
            case .item(let type): return type.displayName
            }
        }
        
        var icon: Image { // Handles both asset names and system names
            switch self {
            case .resource(let type):
                return Image(type.inventoryIconAssetName)
            case .component(let type):
                return Image(type.iconAssetName)
            case .item(let type):
                return Image(type.iconAssetName)
            }
        }
        
        var description: String {
            switch self {
            case .resource(let type): return type.description
            case .component(let type): return type.description
            case .item(let type): return type.description
            }
        }
    }
    
    private var isItemDroppable: Bool {
            // Check if the item is an egg resource.
            if case .resource(let resourceType) = inspectableItem,
               resourceType.tags?.contains(.egg) == true {
                return false // Eggs are not droppable.
            }
            
            // You can add other rules here in the future for other undroppable items.
            
            return true // By default, all other items are droppable.
        }
    
    // --- Main Body ---
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        headerSection
                        descriptionSection
                        typeSpecificDetailsSection
                        dropActionSection // Only shown if item exists
                        Spacer() // To push content up if it's short
                    }
                    .padding()
                }
                .navigationTitle(inspectableItem.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() }}}
                .alert("Confirm Drop", isPresented: $showDropConfirmation) {
                    Button("Drop \(clampedDropAmount())", role: .destructive) { performDrop(); dismiss() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to drop \(clampedDropAmount()) of \(inspectableItem.displayName)? This cannot be undone.")
                }
                .onAppear { resetDropAmount() }
                .onChange(of: currentItemCount) { _, _ in resetDropAmountIfNecessary() } // Simplified onChange trigger
            }
        }
    
    // Helper to get the current count of the inspected item
        private var currentItemCount: Int {
            switch inspectableItem {
            case .resource(let type): return gameManager.playerInventory[type] ?? 0
            case .component(let type): return gameManager.sanctumComponentStorage[type] ?? 0
            case .item(let type): return gameManager.sanctumItemStorage[type] ?? 0
            }
        }

        // --- Helper Computed Properties for View Sections ---

        @ViewBuilder
        private var headerSection: some View {
            HStack(spacing: 15) {
                inspectableItem.icon
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60)
                    .padding(5).background(Color.gray.opacity(0.1)).cornerRadius(8)
                Text(inspectableItem.displayName).font(.largeTitle).fontWeight(.bold)
            }
            .padding(.bottom)
        }

        @ViewBuilder
        private var descriptionSection: some View {
            Text("Description").font(.headline)
            Text(inspectableItem.description).font(.body).foregroundColor(.secondary).padding(.bottom)
        }

        @ViewBuilder
        private var typeSpecificDetailsSection: some View {
            // This switch contains the varying details for resource, component, item
            switch inspectableItem {
            case .resource(let resourceType):
                Text("Type: Raw Resource")
                Text("Count: \(gameManager.playerInventory[resourceType] ?? 0)")
                // TODO: "Used in Crafting..."

            case .component(let componentType):
                Text("Type: Crafted Component")
                Text("Count: \(gameManager.sanctumComponentStorage[componentType] ?? 0)")
                // TODO: "Used in Crafting..."

            case .item(let itemType):
                Text("Type: \(itemType.potionEffect != nil ? "Potion" : (itemType.maxDurability != nil ? "Tool/Equipment" : "Utility"))")
                Text("Count: \(gameManager.sanctumItemStorage[itemType] ?? 0)")
                
                if let maxDura = itemType.maxDurability {
                    let currentDura = gameManager.currentToolDurability[itemType] ?? ((gameManager.sanctumItemStorage[itemType] ?? 0 > 0) ? maxDura : 0)
                    Text("Durability: \(currentDura > 0 ? currentDura : ((gameManager.sanctumItemStorage[itemType] ?? 0 > 0) ? maxDura : 0)) / \(maxDura)")
                        .foregroundColor(currentDura > maxDura / 2 ? .primary : (currentDura > maxDura / 4 ? .orange : .red))
                }
                if itemType.maxDurability != nil &&
                   (gameManager.currentToolDurability[itemType] ?? 0) < itemType.maxDurability! &&
                   (gameManager.sanctumItemStorage[.whetstone] ?? 0) > 0 {
                    
                    Button("Repair with Whetstone (+10 Durability)") {
                        let success = gameManager.repairTool(tool: itemType, repairItem: .whetstone)
                        if success {
                            // The view will update automatically due to @ObservedObject,
                            // and the GameManager will post a toast message.
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
                if let slot = itemType.equipmentSlot {
                    Divider().padding(.top)
                    
                    if let bonuses = itemType.statBonuses {
                        Text("Equipment Bonuses:").font(.headline)
                        ForEach(bonuses.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { stat in
                            Text(stat.displayName) // Example: Show what stats it has
                                .font(.subheadline)
                        }
                    }
                    
                    if gameManager.equippedGear[slot] == itemType {
                        Button("Unequip", role: .destructive) {
                            gameManager.unequipItem(from: slot)
                        }
                        .buttonStyle(.bordered).padding(.top)
                    } else {
                        Button("Equip") {
                            gameManager.equipItem(itemType);
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent).padding(.top)
                    }
                }
                
                if let potionFx = itemType.potionEffect {
                    Text("Effect: \(potionFx.type.displayNameFromType())")
                    Text("Duration: \(Int(potionFx.duration / 60)) min")
                    // Text("Magnitude: ...") // More detailed magnitude description
                    
                    Button("Use \(itemType.displayName)") {
                        if gameManager.usePotion(itemType: itemType) { dismiss() }
                    }
                    .buttonStyle(.borderedProminent).padding(.top)
                    .disabled((gameManager.sanctumItemStorage[itemType] ?? 0) == 0)
                }
            }
        }

    @ViewBuilder
    private var dropActionSection: some View {
        // The body now only contains a simple check using our pre-calculated property.
        if currentItemCount > 0 && isItemDroppable {
            Divider().padding(.top)
            SectionHeader(title: "Actions")
            
            HStack {
                Text("Drop Amount:")
                TextField("Amount", text: $dropAmountString, onCommit: { validateAndClampDropAmount() })
                    .keyboardType(.numberPad).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 60)
                    .onChange(of: dropAmountString) { _, _ in validateAndClampDropAmount() }

                Stepper("", value: Binding(
                    get: { Int(dropAmountString) ?? 1 },
                    set: {
                        let maxAmount = currentItemCount
                        dropAmountString = "\(min(max($0, 1), maxAmount == 0 ? 1 : maxAmount))"
                    }
                ), in: 1...(max(1, currentItemCount)))
            }
            .padding(.bottom, 5)

            Button(role: .destructive) { showDropConfirmation = true } label: {
                Label("Drop \(clampedDropAmount()) \(inspectableItem.displayName)", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(clampedDropAmount() <= 0)
        }
    }

    // Helper to get a valid drop amount (clamped)
    private func clampedDropAmount() -> Int {
        let desiredAmount = Int(dropAmountString) ?? 1
        return min(max(desiredAmount, 1), currentItemCount) // Ensure it's at least 1 and not more than available
    }
    
    // Validate and clamp the dropAmountString based on current inventory
    private func validateAndClampDropAmount() {
        let maxAmount = currentItemCount
        if maxAmount == 0 { // If nothing to drop, reset to "0" or "1" and disable controls
            dropAmountString = "0" // Or handle UI to hide drop controls
            return
        }
        if let enteredAmount = Int(dropAmountString) {
            if enteredAmount > maxAmount {
                dropAmountString = "\(maxAmount)"
            } else if enteredAmount < 1 {
                dropAmountString = "1"
            }
        } else if !dropAmountString.isEmpty { // Handle non-integer input
            dropAmountString = "1"
        }
    }
    
    // Reset drop amount when item count changes (e.g., after a drop)
    private func resetDropAmountIfNecessary() {
        let currentMax = currentItemCount
        let currentDrop = Int(dropAmountString) ?? 1
        if currentDrop > currentMax || currentMax == 0 {
            dropAmountString = "\(max(1, currentMax))"
            if currentMax == 0 { dropAmountString = "0" } // Or hide UI
        }
    }
    
    private func resetDropAmount() {
        let maxAmount = currentItemCount
        if maxAmount > 0 {
            dropAmountString = "1"
        } else {
            dropAmountString = "0" // Or handle UI differently if nothing to drop
        }
    }
    
    private func performDrop() {
        guard let amountToDrop = Int(dropAmountString), amountToDrop > 0 else { return }
        
        var success = false
        switch inspectableItem {
        case .resource(let type):
            success = gameManager.dropResource(resourceType: type, amount: amountToDrop)
        case .component(let type):
            success = gameManager.dropComponent(componentType: type, amount: amountToDrop)
        case .item(let type):
            success = gameManager.dropItem(itemType: type, amount: amountToDrop)
        }
        if success {
            // Optionally, provide feedback via a toast message system if you have one for ItemDetailView
            print("Successfully dropped items.")
        } else {
            print("Failed to drop items (e.g., not enough).")
        }
    }
}

// Make ItemDetailView.InspectableItem Identifiable for .sheet(item: ...)
extension ItemDetailView.InspectableItem: Identifiable {
    var id: String {
        switch self {
        case .resource(let type): return "res_\(type.rawValue)"
        case .component(let type): return "comp_\(type.rawValue)"
        case .item(let type): return "item_\(type.rawValue)"
        }
    }
}

// Preview for ItemDetailView
struct ItemDetailView_Previews: PreviewProvider {
    class MockDetailGameManager: GameManager { /* ... populate with relevant data ... */ }
    
    static var previews: some View {
        let gm = MockDetailGameManager()
        gm.playerInventory[.T1_herb] = 10
        gm.sanctumItemStorage[.T1_potion] = 1
        
        return Group {
            ItemDetailView(gameManager: gm, inspectableItem: .resource(.T1_herb))
                .previewDisplayName("Resource Detail")
            ItemDetailView(gameManager: gm, inspectableItem: .item(.T1_potion))
                .previewDisplayName("Potion Detail")
        }
    }
}
