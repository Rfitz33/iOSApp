//
//  CompanionsView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/21/25.
//


// CompanionsView.swift
import SwiftUI

struct CompanionsView: View {
    @ObservedObject var gameManager: GameManager
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    
    var body: some View {
        // We will use a List for better performance and styling control
        List {
            activeCompanionSection
            allCompanionsSection
        }
        .navigationTitle("Companions")
        .onReceive(timer) { newTime in
            self.currentTime = newTime
        }
    }
    
    // MARK: - Computed Properties for UI Sections
    
    @ViewBuilder
    private var activeCompanionSection: some View {
        // This logic is simple enough for one computed property.
        if let activeCreature = gameManager.activeCreature {
            Section("Active Companion") {
                // We use a helper view to isolate the complex 'switch'
                CompanionRow(creature: activeCreature, currentTime: currentTime, gameManager: gameManager)
            }
        }
    }
    
    @ViewBuilder
    private var allCompanionsSection: some View {
        Section("All Companions") {
            if gameManager.ownedCreatures.isEmpty {
                Text("No companions yet. Find eggs by chopping trees!").foregroundColor(.secondary)
            } else {
                ForEach(gameManager.ownedCreatures) { creature in
                    // We use the same helper view here.
                    CompanionRow(creature: creature, currentTime: currentTime, gameManager: gameManager)
                }
            }
        }
    }
}

private struct CompanionRow: View {
    let creature: Creature
    let currentTime: Date
    @ObservedObject var gameManager: GameManager

    var body: some View {
        switch creature.state {
        case .hatchling:
            HatchlingRowView(gameManager: gameManager, creature: creature, currentTime: currentTime)
        case .untrainedAdult:
            QuestRowView(gameManager: gameManager, creature: creature)
        case .trainedAdult:
            CreatureRowView(gameManager: gameManager, creature: creature, currentTime: currentTime)
        }
    }
}

// MARK: - Subviews

// --- HATCHLING VIEW ---
struct HatchlingRowView: View {
    @ObservedObject var gameManager: GameManager
    let creature: Creature
    let currentTime: Date
    
    private var isActive: Bool { gameManager.activeCreatureID == creature.id }
    
    // --- We will keep the calculations as private computed properties ---
    private var growthProgress: Double {
        guard let growthStartTime = creature.growthStartTime else { return 0 }
        let totalDuration = creature.type.growthDuration
        let timeSinceHatched = currentTime.timeIntervalSince(growthStartTime)
        let earnedReduction = gameManager.petGrowthReductions[creature.id] ?? 0
        let effectiveTimeElapsed = timeSinceHatched + earnedReduction
        return min(effectiveTimeElapsed / totalDuration, 1.0)
    }

    private var timeToAdult: String {
        guard let growthStartTime = creature.growthStartTime else { return "Calculating..." }
        let totalDuration = creature.type.growthDuration
        let timeSinceHatched = currentTime.timeIntervalSince(growthStartTime)
        let earnedReduction = gameManager.petGrowthReductions[creature.id] ?? 0
        let remaining = totalDuration - (timeSinceHatched + earnedReduction)
        if remaining <= 0 { return "Ready to Grow!" }
        let days = Int(remaining) / 86400
        let hours = (Int(remaining) % 86400) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if days > 0 { return String(format: "%dd %dh %dm", days, hours, minutes) }
        else if hours > 0 { return String(format: "%dh %dm", hours, minutes) }
        else { return String(format: "%dm", minutes) }
    }
    
    // --- NEW: A helper to format the time reduction from walking ---
    private var walkingBonusTime: String {
        let reductionSeconds = gameManager.petGrowthReductions[creature.id] ?? 0
        guard reductionSeconds > 0 else { return "" }
        
        let hours = Int(reductionSeconds) / 3600
        let minutes = (Int(reductionSeconds) % 3600) / 60
        
        if hours > 0 {
            return " (-\(hours)h \(minutes)m from walking)"
        } else {
            return " (-\(minutes)m from walking)"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("\(creature.type.rawValue)_chick_icon")
                    .resizable().scaledToFit().frame(width: 40, height: 40)
                    .padding(4).background(Color.gray.opacity(0.1)).cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text("\(creature.name ?? creature.type.displayName) (Hatchling)")
                        .font(.headline)
                    
                    // --- MODIFIED: Show the walking bonus next to the main timer ---
                    Text("Time to Grow: ")
                        .font(.caption).foregroundColor(.secondary)
                    + Text(timeToAdult)
                        .font(.caption).foregroundColor(.secondary).fontWeight(.bold)
                    + Text(walkingBonusTime) // <-- Displays the "-Xh Ym from walking" text
                        .font(.caption).foregroundColor(.green).fontWeight(.bold)
                }
                
                Spacer()
                
                if isActive {
                    Text("Active")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                } else {
                    Button("Set Active") {
                        gameManager.setActiveCreature(creatureID: creature.id)
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // --- Progress bar ---
            ProgressView(value: growthProgress).tint(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("How to help it grow:")
                    .font(.caption.weight(.bold))
                
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk.circle.fill")
                        .foregroundColor(.blue)
                    Text("Set as active companion and walk. (1km ≈ 30min reduction)")
                }
                .font(.caption2)
                
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife.circle.fill")
                        .foregroundColor(.orange)
                    Text("Feed it special treats.")
                }
                .font(.caption2)
            }
            .foregroundColor(.secondary)
            .padding(.leading, 5) // Indent it slightly
        }
        .padding(.vertical, 4)
    }
}

// --- QUEST VIEW (FOR UNTRAINED ADULTS) ---
struct QuestRowView: View {
    @ObservedObject var gameManager: GameManager
    let creature: Creature
    
    private var isActive: Bool { gameManager.activeCreatureID == creature.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image("\(creature.type.rawValue)_icon")
                    .resizable().scaledToFit().frame(width: 40, height: 40)
                    .padding(4).background(Color.gray.opacity(0.1)).cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(creature.name ?? creature.type.displayName)
                        .font(.headline)
                    // --- NEW: Added the active vision bonus ---
                    Text("Vision Bonus: +\(Int(creature.type.visionBonus))m")
                        .font(.subheadline).foregroundColor(.secondary)
                }
            }
            
            Spacer()
                
            if isActive {
                Text("Active")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(10)
            } else {
                Button("Set Active") {
                    gameManager.setActiveCreature(creatureID: creature.id)
                }
            .buttonStyle(.bordered)
            }
            
            // Quest Details
            VStack(alignment: .leading, spacing: 5) {
                Text(creature.type.trainingQuest.title)
                    .font(.subheadline.weight(.bold))
                Text(creature.type.trainingQuest.description)
                    .font(.caption).foregroundColor(.secondary)
                
                // --- Display the reward description ---
                VStack(alignment: .leading) {
                    Text("Reward: Unlocks Special Ability")
                        .font(.caption.weight(.bold)).foregroundColor(.green)
                    // This tells the player exactly what they will get.
                    Text(creature.type.specialAbilityDescription)
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(.top, 4)
                
                // Progress Bars
                ForEach(creature.type.trainingQuest.objectives.keys.sorted(), id: \.self) { key in
                    let progress = creature.questProgress[key, default: 0]
                    let required = creature.type.trainingQuest.objectives[key, default: 1]
                    
                    // --- NEW: A clamped version for the UI ---
                    let clampedProgress = min(progress, required)
                    
                    VStack(alignment: .leading) {
                        Text("\(key.capitalized.replacingOccurrences(of: "_", with: " ")): \(clampedProgress) / \(required)")
                            .font(.caption)
                        ProgressView(value: Double(clampedProgress), total: Double(required))
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.leading, 5)

        }
        .padding(.vertical, 4)
    }
}

// --- CREATURE VIEW (FOR TRAINED ADULTS) ---
struct CreatureRowView: View {
    @ObservedObject var gameManager: GameManager
    let creature: Creature
    let currentTime: Date
    
    private var isActive: Bool {
        gameManager.activeCreatureID == creature.id
    }
    
    var body: some View {
        HStack {
            Image("\(creature.type.rawValue)_icon")
                .resizable().scaledToFit().frame(width: 40, height: 40)
                .padding(4)
                .background(Color.gray.opacity(0.1))
            // --- MODIFIED: The glowing border now correctly indicates "Trained" status ---
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(creature.state == .trainedAdult ? Color.yellow : Color.clear, lineWidth: 2)
                        .shadow(color: .yellow, radius: creature.state == .trainedAdult ? 3 : 0)
                )
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(creature.name ?? creature.type.displayName).font(.headline)
                Text("Vision Bonus: +\(Int(creature.type.visionBonus))m").font(.caption).foregroundColor(.secondary)
                
                if creature.state == .trainedAdult {
                    Text(creature.type.specialAbilityDescription).font(.caption).foregroundColor(.blue)
                    
                    // --- Fetch Charge Display ---
                    HStack(spacing: 4) {
                        Image(systemName: "paperplane.circle.fill")
                            .foregroundColor(.accentColor)
                        
                        // Show the night bonus for the Owl
                        let maxCharges = (creature.type == .owl && gameManager.isNightTime()) ? creature.type.maxFetchCharges + 1 : creature.type.maxFetchCharges
                        
                        Text("Fetch Charges: \(creature.fetchCharges)/\(maxCharges)")
                        
                        // Show the cooldown timer if a charge is regenerating
                        if creature.fetchCharges < maxCharges, let nextChargeTime = creature.chargeRestoreTimes.min() {
                            Text("(Next in: \(nextChargeTime, style: .timer))")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
            
            Spacer()
            
            if isActive {
                Text("Active")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(10)
            } else {
                Button("Set Active") {
                    gameManager.setActiveCreature(creatureID: creature.id)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
        
        // --- Context menu to allow deactivation ---
        .contextMenu {
            if isActive {
                Button(role: .destructive) {
                    gameManager.setActiveCreature(creatureID: nil)
                } label: {
                    Label("Deactivate Companion", systemImage: "xmark.circle")
                }
            }
        }
    }
}
