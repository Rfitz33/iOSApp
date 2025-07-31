import SwiftUI

// MARK: - InventoryView
struct InventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil
    @State private var slotToEquip: EquipmentSlot? = nil
    
    var body: some View {
        List {
            StorageOverviewSection(gameManager: gameManager)
            EquippedGearSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem,
                slotToEquip: $slotToEquip)
            AllToolsSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
            BagsSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
            ResourcesSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
            ComponentsSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
            JewelrySection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
            PotionsSection(gameManager: gameManager, selectedInspectableItem: $selectedInspectableItem)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Inventory")
        .sheet(item: $selectedInspectableItem) { inspectableItem in
            ItemDetailView(gameManager: gameManager, inspectableItem: inspectableItem)
        }
        // SHEET for equipment picke
        .sheet(item: $slotToEquip) { slot in
            EquipmentPickerView(gameManager: gameManager, slot: slot)
        }
    }
}


// MARK: - Inventory Section Views (These can be in this file or moved to their own)

//struct StorageOverviewSection: View {
//    @ObservedObject var gameManager: GameManager
//    var body: some View {
//        Section("Storage Overview") {
//            HStack {
//                Image(systemName: "leaf.fill").foregroundColor(.green)
//                Text("Herb Satchel Capacity:").font(.callout)
//                Spacer()
//                Text("\(gameManager.currentHerbLoad) / \(gameManager.maxHerbCapacity)")
//            }
//            ProgressView(value: Float(gameManager.currentHerbLoad), total: max(1, Float(gameManager.maxHerbCapacity)))
//                .tint(gameManager.currentHerbLoad >= gameManager.maxHerbCapacity ? .red : .green)
//
//            HStack {
//                Image(systemName: "shippingbox.fill").foregroundColor(.brown)
//                Text("General Storage:").font(.callout)
//                Spacer()
//                Text("\(gameManager.currentGeneralResourceLoad) / \(gameManager.maxGeneralResourceCapacity)")
//            }
//            ProgressView(value: Float(gameManager.currentGeneralResourceLoad), total: max(1, Float(gameManager.maxGeneralResourceCapacity)))
//                .tint(gameManager.currentGeneralResourceLoad >= gameManager.maxGeneralResourceCapacity ? .red : .blue)
//        }
//    }
//}
//
//struct EquippedGearSection: View {
//    @ObservedObject var gameManager: GameManager
//    
//    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?
//    @Binding var slotToEquip: EquipmentSlot?
//    
//    // List of all slots we want to display in order
//    private let displaySlots: [EquipmentSlot] = [
//        .ring, .necklace,
//        .pickaxe, .axe, .knife, .bow, .arrows,
//        .backpack, .satchel
//    ]
//    
//    // Helper to get placeholder text for a slot
//    private func placeholder(for slot: EquipmentSlot) -> String {
//        switch slot {
//        case .ring: return "Ring Slot"
//        case .necklace: return "Amulet Slot"
//        case .pickaxe: return "No Pickaxe Equipped"
//        case .axe: return "No Axe Equipped"
//        case .knife: return "No Knife Equipped"
//        case .bow: return "No Bow Equipped"
//        case .arrows: return "No Arrows Equipped"
//        case .backpack: return "No Backpack Equipped"
//        case .satchel: return "No Satchel Equipped"
//        }
//    }
//    
//    var body: some View {
//        Section("Active & Equipped Gear") {
//            // Loop through the defined slots for a clean, data-driven list
//            ForEach(displaySlots, id: \.self) { slot in
//                let equippedItem = gameManager.equippedGear[slot]
//                
//                EquippedItemRow(
//                    gameManager: gameManager,
//                    item: equippedItem,
//                    placeholder: placeholder(for: slot),
//                    slot: slot
//                ) {
//                    if let item = equippedItem {
//                        // If an item is equipped, show its details
//                        selectedInspectableItem = .item(item)
//                    } else {
//                        // If the slot is empty, show the equipment picker for that slot
//                        slotToEquip = slot
//                    }
//                }
//            }
//        }
//    }
//}

// MARK: - AllToolsSection
struct AllToolsSection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?
    
    private let toolCategories: [ToolCategory] = ToolCategory.allCases.filter { $0 != .none }
    
    // --- 1. NEW: Data structure to hold the organized tools ---
    struct ToolCategorySection: Identifiable {
        let id: ToolCategory // The category itself (e.g., .pickaxe)
        let categoryName: String
        let tools: [ItemType]
    }

    // --- 2. NEW: Computed property to prepare ALL data beforehand ---
    private var organizedToolData: [ToolCategorySection] {
        let toolCategories: [ToolCategory] = [.pickaxe, .axe, .knife, .bow]
        var sections: [ToolCategorySection] = []

        for category in toolCategories {
            let ownedToolsInCategory = ItemType.allCases
                .filter {
                    $0.toolCategory == category &&
                    (gameManager.sanctumItemStorage[$0] ?? 0) > 0
                }
                .sorted { $0.tier < $1.tier }

            if !ownedToolsInCategory.isEmpty {
                let section = ToolCategorySection(
                    id: category,
                    categoryName: category.rawValue.capitalized + "s",
                    tools: ownedToolsInCategory
                )
                sections.append(section)
            }
        }
        return sections
    }

    // --- 3. SIMPLIFIED Body ---
    var body: some View {
        // The body now just iterates over the pre-computed data.
        // There is no complex filtering or sorting logic here.
        ForEach(organizedToolData) { sectionData in
            Section(header: Text(sectionData.categoryName)) {
                ForEach(sectionData.tools) { item in
                    Button(action: { selectedInspectableItem = .item(item) }) {
                        ToolRowView(gameManager: gameManager, item: item)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}


// MARK: - Bags Section View
struct BagsSection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?

    // Filter for all unequipped bags/satchels in the player's inventory
    private var sortedBagsInInventory: [ItemType] {
        ItemType.allCases
            .filter { item in
                let slot = item.equipmentSlot
                // Is it a bag or satchel AND does the player have at least one in their inventory?
                return (slot == .backpack || slot == .satchel) && (gameManager.sanctumItemStorage[item] ?? 0) > 0
            }
            .sorted { $0.tier < $1.tier }
    }

    var body: some View {
        Section("Bags & Satchels") {
            if sortedBagsInInventory.isEmpty {
                Text("No spare bags or satchels.").foregroundColor(.secondary)
            } else {
                ForEach(sortedBagsInInventory) { bag in
                    Button(action: { selectedInspectableItem = .item(bag) }) {
                        // Create a simple row view for bags, can be a new helper struct if it gets complex
                        HStack {
                            Image(bag.iconAssetName) // Assumes custom assets
                                .resizable().scaledToFit().frame(width: 28, height: 28)
                            VStack(alignment: .leading) {
                                Text(bag.displayName)
                                // Display its capacity bonus for clarity
                                if bag.herbCapacityBonus > 0 {
                                    Text("+\(bag.herbCapacityBonus) Herb Capacity").font(.caption).foregroundColor(.green)
                                }
                                if bag.generalResourceCapacityBonus > 0 {
                                    Text("+\(bag.generalResourceCapacityBonus) General Capacity").font(.caption).foregroundColor(.blue)
                                }
                            }
                            Spacer()
                            Text("x\(gameManager.sanctumItemStorage[bag] ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ResourcesSection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?

    private var groupedResources: [(category: ResourceCategory, items: [ResourceType])] {
        let owned = ResourceType.allCases.filter { gameManager.playerInventory[$0] ?? 0 > 0 }
        let grouped = Dictionary(grouping: owned, by: { $0.category })
        return grouped.map { ($0.key, $0.value.sorted { $0.tier < $1.tier }) }.sorted { $0.0.displayOrder < $1.0.displayOrder }
    }
    
    var body: some View {
        Section("Resources") {
            if groupedResources.isEmpty {
                Text("No resources gathered.").foregroundColor(.secondary)
            } else {
                ForEach(groupedResources, id: \.category) { categoryGroup in
                    DisclosureGroup(categoryGroup.category.rawValue.capitalized) {
                        ForEach(categoryGroup.items) { resource in
                            Button(action: { selectedInspectableItem = .resource(resource) }) {
                                ResourceRowView(resource: resource, count: gameManager.playerInventory[resource] ?? 0)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}


struct ComponentsSection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?

    private var sortedComponents: [ComponentType] {
        ComponentType.allCases.filter { gameManager.sanctumComponentStorage[$0] ?? 0 > 0 }.sorted { $0.tier < $1.tier }
    }
    
    var body: some View {
        Section("Components") {
            if sortedComponents.isEmpty {
                Text("No components crafted.").foregroundColor(.secondary)
            } else {
                ForEach(sortedComponents) { component in
                    Button(action: { selectedInspectableItem = .component(component) }) {
                        ComponentRowView(component: component, count: gameManager.sanctumComponentStorage[component] ?? 0)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}


struct JewelrySection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?

    private var sortedJewelry: [ItemType] {
        ItemType.allCases.filter {
            let slot = $0.equipmentSlot
            return (slot == .ring || slot == .necklace) && (gameManager.sanctumItemStorage[$0] ?? 0 > 0)
        }.sorted { $0.tier < $1.tier }
    }

    var body: some View {
        Section("Jewelry & Trinkets") {
            if sortedJewelry.isEmpty {
                Text("No jewelry crafted.").foregroundColor(.secondary)
            } else {
                ForEach(sortedJewelry) { jewelry in
                    Button(action: { selectedInspectableItem = .item(jewelry) }) {
                        JewelryRowView(jewelryItem: jewelry, count: gameManager.sanctumItemStorage[jewelry] ?? 0)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}


struct PotionsSection: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?

    private var sortedPotions: [ItemType] {
        ItemType.allCases.filter { $0.potionEffect != nil && (gameManager.sanctumItemStorage[$0] ?? 0 > 0) }.sorted { $0.tier < $1.tier }
    }
    
    var body: some View {
        Section("Potions") {
            if sortedPotions.isEmpty {
                Text("No potions crafted yet.").foregroundColor(.secondary)
            } else {
                ForEach(sortedPotions) { potion in
                    Button(action: { selectedInspectableItem = .item(potion) }) {
                        PotionRowView(potionItem: potion, count: gameManager.sanctumItemStorage[potion] ?? 0)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}
