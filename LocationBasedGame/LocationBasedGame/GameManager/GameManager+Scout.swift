
//  GameManager+Scout.swift
//  LocationBasedGame

//  Created by Reid on 6/13/25.

import Foundation

extension GameManager {
    
    // --- HELPER PROPERTIES for the new scout logic ---
    // We define the resource pools here to keep the main function clean.
    private var t1_3_Stones: [ResourceType] { [.T1_stone, .T2_stone, .T3_stone] }
    private var t4_5_Stones: [ResourceType] { [.T4_stone, .T5_stone] }
    private var t6_7_Stones: [ResourceType] { [.T6_stone, .T7_stone] }
    private var t8_9_Stones: [ResourceType] { [.T8_stone, .T9_stone] }
    
    private var t1_3_Woods: [ResourceType] { [.T1_wood, .T2_wood, .T3_wood] }
    private var t4_5_Woods: [ResourceType] { [.T4_wood, .T5_wood] }
    private var t6_7_Woods: [ResourceType] { [.T6_wood, .T7_wood] }
    private var t8_9_Woods: [ResourceType] { [.T8_wood, .T9_wood] }
    
    private var t1_3_Herbs: [ResourceType] { [.T1_herb, .T2_herb, .T3_herb] }
    private var t4_5_Herbs: [ResourceType] { [.T4_herb, .T5_herb] }
    private var t6_7_Herbs: [ResourceType] { [.T6_herb, .T7_herb] }
    private var t8_9_Herbs: [ResourceType] { [.T8_herb, .T9_herb] }

    // --- TIMER MANAGEMENT (Unchanged) ---
    func startScoutsGatherTimer() {
        guard activeBaseUpgrades.contains(.scoutsQuarters) else { return }
        stopScoutsGatherTimer()
        scoutsGatherTimer = Timer.scheduledTimer(
            timeInterval: scoutsGatherInterval,
            target: self,
            selector: #selector(performScoutGather), // Note the selector name change
            userInfo: nil,
            repeats: true
        )
        print("Scouts gather timer started (interval: \(scoutsGatherInterval)s).")
    }

    func stopScoutsGatherTimer() {
        scoutsGatherTimer?.invalidate()
        scoutsGatherTimer = nil
        print("Scouts gather timer stopped.")
    }
    
    // --- THE NEW, IMPROVED GATHERING LOGIC ---
    @objc private func performScoutGather() {
        guard activeBaseUpgrades.contains(.scoutsQuarters) else {
            stopScoutsGatherTimer()
            return
        }

        // 1. Determine the relevant player skill level for the loot table.
        var relevantSkillLevel: Int
        let targetCategory = assignedScoutTask?.category
        
        if let task = assignedScoutTask, let skill = task.associatedSkill {
            relevantSkillLevel = getLevel(for: skill)
        } else {
            // If "Random", take an average of the main gathering skills.
            let totalLevel = getLevel(for: .mining) + getLevel(for: .woodcutting) + getLevel(for: .foraging)
            relevantSkillLevel = max(1, totalLevel / 3) // Ensure it's at least 1
        }
        
        // 2. Determine the max tier the scout can find based on the player's skill.
        // Formula: A player needs to be Level 5 to unlock T1 finds, 10 for T2, etc.
        let maxTierScoutCanFind = max(0, (relevantSkillLevel / 5))

        // 3. The Tiered Loot Roll
        var gatheredBundle: [ResourceType: Int] = [:]
        let roll = Double.random(in: 0...1)
        
        // --- Tier 1-3 (Common) ---
        let baseAmount = Int.random(in: 5...10)
        if let target = assignedScoutTask {
            gatheredBundle[target, default: 0] += baseAmount
        } else {
            if let randomBasic = [ResourceType.T1_stone, .T1_wood, .T1_herb].randomElement() {
                gatheredBundle[randomBasic, default: 0] += baseAmount
            }
        }

        // --- Tier 4-5 (Uncommon) ---
        if maxTierScoutCanFind >= 4 && roll < 0.30 { // 30% chance if eligible
            let amount = Int.random(in: 2...4)
            var pool: [ResourceType] = []
            if targetCategory == .stoneOre || targetCategory == nil { pool += t4_5_Stones.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .wood || targetCategory == nil { pool += t4_5_Woods.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .herb || targetCategory == nil { pool += t4_5_Herbs.filter { $0.tier <= maxTierScoutCanFind } }
            if let resource = pool.randomElement() { gatheredBundle[resource, default: 0] += amount }
        }
        
        // --- Tier 6-7 (Rare) ---
        if maxTierScoutCanFind >= 6 && roll < 0.10 { // 10% chance if eligible
            let amount = Int.random(in: 1...2)
            var pool: [ResourceType] = []
            if targetCategory == .stoneOre || targetCategory == nil { pool += t6_7_Stones.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .wood || targetCategory == nil { pool += t6_7_Woods.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .herb || targetCategory == nil { pool += t6_7_Herbs.filter { $0.tier <= maxTierScoutCanFind } }
            if let resource = pool.randomElement() { gatheredBundle[resource, default: 0] += amount }
        }
        
        // --- Tier 8-9 (Epic) ---
        if maxTierScoutCanFind >= 8 && roll < 0.02 { // 2% chance if eligible
            var pool: [ResourceType] = []
            if targetCategory == .stoneOre || targetCategory == nil { pool += t8_9_Stones.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .wood || targetCategory == nil { pool += t8_9_Woods.filter { $0.tier <= maxTierScoutCanFind } }
            if targetCategory == .herb || targetCategory == nil { pool += t8_9_Herbs.filter { $0.tier <= maxTierScoutCanFind } }
            if let resource = pool.randomElement() { gatheredBundle[resource, default: 0] += 1 }
        }

        // 4. Add the gathered bundle to inventory, checking capacity.
        var messages: [String] = []
        for (resource, amount) in gatheredBundle.sorted(by: { $0.key.tier > $1.key.tier }) { // Show best items first
            let capacity = resource.category == .herb ? maxHerbCapacity - currentHerbLoad : maxGeneralResourceCapacity - currentGeneralResourceLoad
            let amountToAdd = min(amount, capacity)
            
            if amountToAdd > 0 {
                playerInventory[resource, default: 0] += amountToAdd
                messages.append("\(amountToAdd)x \(resource.displayName)")
            }
        }
        
        // 5. Formulate and send the feedback message.
        var finalMessage: String
        if messages.isEmpty {
            finalMessage = "Your scout returned, but your inventory was full."
            // --- NEW: Use the publisher ---
            feedbackPublisher.send(FeedbackEvent(message: finalMessage, isPositive: false))
            logMessage(finalMessage, type: .failure)
        } else {
            finalMessage = "Your scout returned with: \(messages.joined(separator: ", "))."
            // --- NEW: Use the publisher ---
            feedbackPublisher.send(FeedbackEvent(message: finalMessage, isPositive: true))
            logMessage(finalMessage, type: .success)
        }
        print(finalMessage)
    }
    
    // --- ASSIGNMENT LOGIC (Unchanged) ---
    public func assignAndDeployScout(selection: ResourceType?) {
        self.assignedScoutTask = selection
        
        if let resource = selection {
            print("Scout assigned to gather \(resource.displayName).")
        } else {
            print("Scout assigned to gather RANDOM resources.")
        }
        
        if activeBaseUpgrades.contains(.scoutsQuarters) {
            startScoutsGatherTimer()
        }
    }
}
