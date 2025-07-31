//
//  InventoryHelperViews.swift
//  LocationBasedGame
//
//  Created by Reid on 7/11/25.
//

import SwiftUI

// MARK: - Helper View for Equipped Items
struct EquippedItemRow: View {
    @ObservedObject var gameManager: GameManager
    let item: ItemType?
    let placeholder: String
    let slot: EquipmentSlot
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                if let equippedItem = item {
                    // You'll need a way to get the icon for an ItemType directly
                    Image(equippedItem.iconAssetName)
                        .resizable().scaledToFit().frame(width: 28, height: 28)
                    
                    VStack(alignment: .leading) {
                        Text(equippedItem.displayName).fontWeight(.semibold)
                        if let maxDura = equippedItem.maxDurability {
                            let currentDura = gameManager.currentToolDurability[equippedItem] ?? maxDura
                            Text("Dura: \(currentDura)/\(maxDura)").font(.caption).foregroundColor(.secondary)
                        }
                    }
                } else {
                    Image(slot.iconName)
                    .resizable()
                    .renderingMode(.template) // Allows you to change its color
                    .foregroundColor(.secondary.opacity(0.6)) // Gray tint
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    Text(placeholder).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "info.circle").foregroundColor(item != nil ? .blue : .clear)
            }
            .contentShape(Rectangle()) // Make the whole row tappable
            // Add .onTapGesture here if you want tapping the row to open the detail view
        }
        .buttonStyle(.plain) // Make it look like a list row
    }
}

struct StorageOverviewSection: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        MenuSection(title: "Carry Capacity") {
            // --- Herb Satchel ---
            VStack {
                HStack {
                    Image(systemName: "leaf.fill").foregroundColor(.green)
                    Text("Herb Satchel:")
                    Spacer()
                    Text("\(gameManager.currentHerbLoad) / \(gameManager.maxHerbCapacity)")
                        .fontWeight(.semibold)
                }
                ProgressView(value: Float(gameManager.currentHerbLoad), total: max(1, Float(gameManager.maxHerbCapacity)))
                    .tint(gameManager.currentHerbLoad >= gameManager.maxHerbCapacity ? .red : .green)
            }
            
            Divider().padding(.vertical, 4)
            
            // --- General Backpack ---
            VStack {
                HStack {
                    Image(systemName: "shippingbox.fill").foregroundColor(.brown)
                    Text("Backpack:")
                    Spacer()
                    Text("\(gameManager.currentGeneralResourceLoad) / \(gameManager.maxGeneralResourceCapacity)")
                        .fontWeight(.semibold)
                }
                ProgressView(value: Float(gameManager.currentGeneralResourceLoad), total: max(1, Float(gameManager.maxGeneralResourceCapacity)))
                    .tint(gameManager.currentGeneralResourceLoad >= gameManager.maxGeneralResourceCapacity ? .red : .blue)
            }
        }
    }
}

struct ResourceRowView: View {
    let resource: ResourceType
    let count: Int

    var body: some View {
        HStack {
            Image(resource.inventoryIconAssetName).resizable().scaledToFit().frame(width: 28, height: 28).padding(2)
            Text(resource.displayName)
            Spacer()
            Text("\(count)").foregroundColor(.secondary)
        }
    }
}

struct ComponentRowView: View {
    let component: ComponentType
    let count: Int

    var body: some View {
        HStack {
            Image(component.iconAssetName)
                .resizable().scaledToFit().frame(width: 28, height: 28)
                .padding(2)
            Text(component.displayName)
            Spacer()
            Text("\(count)").foregroundColor(.secondary)
        }
    }
}

struct JewelryRowView: View {
    let jewelryItem: ItemType
    let count: Int

    var body: some View {
        HStack {
            Image(jewelryItem.iconAssetName)
                .resizable().scaledToFit().frame(width: 28, height: 28)
                .padding(2)
            Text(jewelryItem.displayName)
            Spacer()
            Text("x\(count)").foregroundColor(.secondary)
        }
    }
}

struct PotionRowView: View {
    let potionItem: ItemType
    let count: Int

    var body: some View {
        HStack {
            Image(potionItem.iconAssetName)
                .resizable().scaledToFit().frame(width: 28, height: 28)
                .padding(2)
            Text(potionItem.displayName)
            Spacer()
            Text("x\(count)").foregroundColor(.secondary)
        }
    }
}

struct ToolRowView: View {
    @ObservedObject var gameManager: GameManager
    let item: ItemType

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(item.iconAssetName).resizable().scaledToFit().frame(width: 28, height: 28).padding(2)
                Text(item.displayName)
                Spacer()
                if (gameManager.sanctumItemStorage[item] ?? 0) > 0 {
                    Text("x\(gameManager.sanctumItemStorage[item] ?? 0)").foregroundColor(.secondary)
                }
            }
            if let maxDura = item.maxDurability {
                let currentDura = gameManager.currentToolDurability[item] ?? ((gameManager.sanctumItemStorage[item] ?? 0 > 0) ? maxDura : 0)
                HStack(spacing: 4) {
                    Image(systemName: "wrench.and.screwdriver").font(.caption).foregroundColor(.secondary)
                    ProgressView(value: Float(currentDura), total: max(1, Float(maxDura)))
                        .tint(currentDura > maxDura / 2 ? .green : (currentDura > maxDura / 4 ? .orange : .red))
                    Text("\(currentDura)/\(maxDura)").font(.caption.monospacedDigit()).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EquippedGearSection: View {
    @ObservedObject var gameManager: GameManager
    
    @Binding var selectedInspectableItem: ItemDetailView.InspectableItem?
    @Binding var slotToEquip: EquipmentSlot?
    
    // List of all slots we want to display in order
    private let displaySlots: [EquipmentSlot] = [
        .ring, .necklace,
        .pickaxe, .axe, .knife, .bow, .arrows,
        .backpack, .satchel
    ]
    
    // Helper to get placeholder text for a slot
    private func placeholder(for slot: EquipmentSlot) -> String {
        switch slot {
        case .ring: return "Ring Slot"
        case .necklace: return "Amulet Slot"
        case .pickaxe: return "No Pickaxe Equipped"
        case .axe: return "No Axe Equipped"
        case .knife: return "No Knife Equipped"
        case .bow: return "No Bow Equipped"
        case .arrows: return "No Arrows Equipped"
        case .backpack: return "No Backpack Equipped"
        case .satchel: return "No Satchel Equipped"
        }
    }
    
    var body: some View {
        Section("Active & Equipped Gear") {
            // Loop through the defined slots for a clean, data-driven list
            ForEach(displaySlots, id: \.self) { slot in
                let equippedItem = gameManager.equippedGear[slot]
                
                EquippedItemRow(
                    gameManager: gameManager,
                    item: equippedItem,
                    placeholder: placeholder(for: slot),
                    slot: slot
                ) {
                    if let item = equippedItem {
                        // If an item is equipped, show its details
                        selectedInspectableItem = .item(item)
                    } else {
                        // If the slot is empty, show the equipment picker for that slot
                        slotToEquip = slot
                    }
                }
            }
        }
    }
}
