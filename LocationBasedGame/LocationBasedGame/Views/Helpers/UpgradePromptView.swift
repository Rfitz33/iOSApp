//
//  UpgradePromptView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/8/25.
//
import SwiftUI

// MARK: - UpgradePromptView
struct UpgradePromptView: View {
    @ObservedObject var gameManager: GameManager
    let upgradeType: BaseUpgradeType
    @Environment(\.dismiss) var dismiss
    
    // Helper property to get the specific upgrade definition
    private var upgradeDef: GameManager.UpgradeDefinition? {
        gameManager.getUpgradeDefinition(for: upgradeType)
    }
    
    init(gameManager: GameManager, upgradeType: BaseUpgradeType) {
        self.gameManager = gameManager
        self.upgradeType = upgradeType
    }

    var body: some View {
        NavigationView {
            // Use a Form or List for a nicely structured layout
            Form {
                // --- HEADER SECTION ---
                Section {
                    VStack(spacing: 10) {
                        // Find a good icon for the upgrade
                        Image(systemName: upgradeType.iconForUI()) // Using helper from BaseUpgradeType
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                        
                        Text("Build \(upgradeType.displayName)?")
                            .font(.title2).bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)


                // --- REQUIREMENTS SECTION ---
                if let def = upgradeDef {
                    Section("Requirements") {
                        // Prerequisite Buildings
                        if let prereqs = def.prerequisites, !prereqs.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Prerequisite Buildings:").font(.headline)
                                ForEach(Array(prereqs), id: \.self) { prereq in
                                    let met = gameManager.activeBaseUpgrades.contains(prereq)
                                    Label(prereq.displayName, systemImage: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(met ? .green : .red)
                                }
                            }
                        }
                        
                        // Skill Levels
                        if let skillReqs = def.skillRequirements, !skillReqs.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Required Skills:").font(.headline).padding(.top, 5)
                                ForEach(skillReqs.sorted(by: { $0.key.displayName < $1.key.displayName }), id: \.key) { (skill, level) in
                                    let playerLevel = gameManager.getLevel(for: skill)
                                    let met = playerLevel >= level
                                    Label("\(skill.displayName): Lvl \(level)", systemImage: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(met ? .green : .red)
                                }
                            }
                        }
                    }

                    // --- COST SECTION (with current amount) ---
                    Section("Cost") {
                        if let resourceCosts = def.resources, !resourceCosts.isEmpty {
                            ForEach(resourceCosts.sorted(by: { $0.key.displayName < $1.key.displayName }), id: \.key) { (resource, requiredAmount) in
                                RequirementRow(name: resource.displayName,
                                               iconAssetName: resource.inventoryIconAssetName,
                                               currentAmount: gameManager.playerInventory[resource] ?? 0,
                                               requiredAmount: requiredAmount)
                            }
                        }
                        // Component Costs
                        if let componentCosts = def.components, !componentCosts.isEmpty {
                            ForEach(componentCosts.sorted(by: { $0.key.displayName < $1.key.displayName }), id: \.key) { (component, requiredAmount) in
                                RequirementRow(name: component.displayName,
                                               iconAssetName: component.iconAssetName,
                                               currentAmount: gameManager.sanctumComponentStorage[component] ?? 0,
                                               requiredAmount: requiredAmount)
                            }
                        }
                    }
                }
                
                // --- ACTION SECTION ---
                Section {
                    Button(action: {
                        if gameManager.canActivateUpgrade(upgradeType) {
                            let success = gameManager.activateUpgrade(upgradeType)
                            if success { dismiss() }
                        }
                    }) {
                        Label("Construct", systemImage: "hammer.fill")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!gameManager.canActivateUpgrade(upgradeType))
                }
            }
            .navigationTitle("Confirm Construction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }}}
        }
    }
}


// --- New Helper View for Requirement Rows ---
struct RequirementRow: View {
    let name: String
    let iconAssetName: String
    let currentAmount: Int
    let requiredAmount: Int
    
    private var isMet: Bool { currentAmount >= requiredAmount }

    var body: some View {
        HStack {
            Image(iconAssetName)
                .resizable().scaledToFit().frame(width: 24, height: 24)
            Text(name)
            Spacer()
            Text("\(currentAmount) / \(requiredAmount)")
                .foregroundColor(isMet ? .green : .red)
                .fontWeight(.medium)
        }
    }
}
