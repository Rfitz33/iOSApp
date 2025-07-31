//
//  EquipmentPickerView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/11/25.
//


import SwiftUI

struct EquipmentPickerView: View {
    @ObservedObject var gameManager: GameManager
    let slot: EquipmentSlot // The slot we are equipping to
    @Environment(\.dismiss) var dismiss

    // Filter the player's inventory for items that match the given slot
    private var availableItems: [ItemType] {
        ItemType.allCases.filter { item in
            item.equipmentSlot == slot && (gameManager.sanctumItemStorage[item] ?? 0) > 0
        }.sorted { $0.tier < $1.tier }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if availableItems.isEmpty {
                    Text("No available items to equip for the \(slot.rawValue.capitalized) slot.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(availableItems) { item in
                            Button(action: {
                                // Equip the selected item and dismiss the sheet
                                gameManager.equipItem(item)
                                dismiss()
                            }) {
                                // Use ToolRowView or a similar helper to display the item
                                ToolRowView(gameManager: gameManager, item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Equip \(slot.rawValue.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct EquipmentPickerView_Previews: PreviewProvider {
    // ... setup a mock with some items in inventory for preview ...
    static var previews: some View {
        let gm = GameManager.shared
        gm.sanctumItemStorage[.T0_pickaxe] = 1
        gm.sanctumItemStorage[.T1_pickaxe] = 2
        return EquipmentPickerView(gameManager: gm, slot: .pickaxe)
    }
}
