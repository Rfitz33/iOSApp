//
//  GameManager+Gathering.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//
import Foundation
import CoreLocation

// MARK: - Gathering Logic
extension GameManager {
    
    // Helper to activate a tool from inventory
    // This function should ONLY set durability. The check for inventory count happens before calling it.
    private func activateTool(_ toolType: ItemType) {
        guard let maxDura = toolType.maxDurability else { return }
        currentToolDurability[toolType] = maxDura
        print("Activated \(toolType.displayName) with \(maxDura) durability.")
    }
    
    // Helper to consume durability based on your tier rule
    private func consumeDurability(for tool: ItemType, resourceType: ResourceType, playerSkillLevel: Int) {
        guard let maxDura = tool.maxDurability else { return }
        
        let toolTier = tool.tier
        let resourceTier = resourceType.tier

        print("--- Durability Check ---")
        print("Tool: \(tool.displayName) (T\(toolTier)), Resource: \(resourceType.displayName) (T\(resourceTier))")
        
        if toolTier > resourceTier {
            print("Result: Over-tiered. No durability loss.")
            return
        }

        if toolTier == resourceTier {
            let requiredSkillLevel = resourceType.requiredSkillLevel
            let levelsAboveRequirement = playerSkillLevel - requiredSkillLevel
            
            print("Skill Save Check (Same Tier): Player Lvl \(playerSkillLevel), Req Lvl \(requiredSkillLevel), Levels Above: \(levelsAboveRequirement), Threshold: \(durabilitySaveLevelThreshold)")

            if levelsAboveRequirement >= durabilitySaveLevelThreshold {
                let baseChanceLevels = levelsAboveRequirement - (durabilitySaveLevelThreshold - 1)
                let chanceToSave = Double(baseChanceLevels) * durabilitySaveChancePerLevel
                print("  - Eligible for durability save. Chance: \(chanceToSave * 100)%")
                
                let randomRoll = Double.random(in: 0...1)
                if randomRoll < chanceToSave.clamped(to: 0...0.95) {
                    print("  - SUCCESS! Rolled \(randomRoll) vs chance \(chanceToSave). Durability saved.")
                    return
                } else {
                    print("  - FAILED. Rolled \(randomRoll) vs chance \(chanceToSave). Durability will be lost.")
                }
            } else {
                print("  - Not eligible for durability save (not high enough level). Durability will be lost.")
            }
        }
        
        var durabilityLoss = 1
        if toolTier < resourceTier {
            durabilityLoss = 2
        }

        print("Result: Applying durability loss of \(durabilityLoss).")
        
        // --- 4. Apply Durability Loss & Handle Breaking ---
        if var currentDur = currentToolDurability[tool] {
            currentDur -= durabilityLoss
            if currentDur < 0 { currentDur = 0 } // Prevent going below zero before check
            currentToolDurability[tool] = currentDur
            
            print("\(tool.displayName) lost \(durabilityLoss) durability. Now: \(currentDur)/\(maxDura)")
            
            if currentDur <= 0 {
                var brokeMessage = "Your \(tool.displayName) broke!"
                // The tool is now broken. Remove its durability entry to signify it's not usable.
                currentToolDurability.removeValue(forKey: tool)
                
                // Decrement the item from inventory
                sanctumItemStorage[tool, default: 0] -= 1
                if sanctumItemStorage[tool, default: 0] < 0 { sanctumItemStorage[tool] = 0 }

                // If the equipped tool just broke, the slot is now conceptually empty until re-equipped.
                // We should un-equip it from the gear slot.
                if let slot = tool.equipmentSlot, equippedGear[slot] == tool {
                    equippedGear.removeValue(forKey: slot)
                    print("Unequipped broken \(tool.displayName) from \(slot.rawValue) slot.")
                }
                
                // The player now needs to MANUALLY equip a new tool from their inventory.
                // The old "auto-equip" logic is what's causing state confusion.
                // By forcing a manual re-equip, the state is always clear.
                if (sanctumItemStorage[tool] ?? 0) > 0 {
                    brokeMessage += " You have spares in your inventory."
                }
                
                lastPotionStatusMessage = brokeMessage
            }
        } else {
            // This case should not be hit if activateTool() is working correctly,
            // because a tool being used should have a durability entry.
            print("Warning: Attempted to consume durability for \(tool.displayName), but it had no durability entry.")
        }
    }

    // --- Main Router ---
    func gatherResourceNode(_ nodeToGather: ResourceNode, playerLocation: CLLocation?) -> (outcome: GatheringOutcome, message: String?) {
        // 1. Proximity Check
        guard let currentPlayerLocation = playerLocation,
              currentPlayerLocation.distance(from: CLLocation(latitude: nodeToGather.coordinate.latitude, longitude: nodeToGather.coordinate.longitude)) <= gatherDistanceThreshold else {
            return (.invalid, "Too far.")
        }
        
        let resourceType = nodeToGather.type
        guard let associatedSkill = resourceType.associatedSkill else {
            return (.invalid, "Config Error: No skill for \(resourceType.displayName).")
        }
        
        // 2. Skill Level Check
        let playerSkillLevel = getLevel(for: associatedSkill)
        
        if playerSkillLevel < resourceType.requiredSkillLevel {
            return (.invalid, "Your \(associatedSkill.displayName) Lvl \(playerSkillLevel) is too low...")
        }
        
        // 3. Route to the correct handler
        let result = nodeToGather.type.isTrackType ? performHunt(from: nodeToGather) : gatherStandardResource(nodeToGather: nodeToGather)

       
        
        // 4. Finalize: Remove node if a conclusive action was taken
        // A node should be consumed and removed if the outcome was EITHER a success OR a failure.
        // It should NOT be removed if the action was invalid.
        if result.outcome == .success || result.outcome == .failure {
            activeResourceNodes.removeAll { $0.id == nodeToGather.id }
            print("Node \(nodeToGather.type.displayName) processed and removed (Outcome: \(result.outcome)).")
        }
        
        return result
    }
    
    // --- Specific Action Handlers ---
    
    // In GameManager+Gathering.swift

    private func performHunt(from trackNode: ResourceNode) -> (outcome: GatheringOutcome, message: String?) {
        guard let huntingSkill = trackNode.type.associatedSkill, huntingSkill == .hunting else {
            return (.invalid, "Config Error: Tracks not associated with Hunting skill.")
        }
        
        let trackTier = trackNode.type.tier
        let huntingLevel = getLevel(for: huntingSkill)

        // --- 1. CHECK AND ACTIVATE MANDATORY GEAR: KNIFE ---
        guard let knifeToUse = equippedGear[.knife] else {
            return (.invalid, "You must equip a Hunting Knife to hunt.")
        }
        guard knifeToUse.tier >= (trackTier - 1) else {
            return (.invalid, "Your equipped Knife (T\(knifeToUse.tier)) is too weak for these T\(trackTier) tracks.")
        }

        // --- 2. CHECK AND ACTIVATE OPTIONAL/HIGH-TIER GEAR: BOW & ARROWS ---
        var bowToUse: ItemType? = nil
        var arrowToUse: ItemType? = nil
        
        let equippedBow = equippedGear[.bow]
        let usableArrows = equippedGear[.arrows]
        
//        if let equippedBow = equippedGear[.bow] {
//            if equippedBow.tier >= trackTier {
//                // If the bow has 0 durability, try to activate a new one.
//                if (currentToolDurability[equippedBow] ?? 0) <= 0 {
//                    if !activateTool(equippedBow) {
//                        return (false, "Your equipped Bow is broken and you have no spares.")
//                    }
//                }
//                // If we're here, the bow is usable. Now check for arrows.
//                let requiredArrowTier = trackNode.type.toolRequirements?.requiredArrowTier ?? trackTier
//                if let usableArrow = ItemType.allCases.first(where: { $0.toolCategory == .arrows && $0.tier >= requiredArrowTier && (sanctumItemStorage[$0] ?? 0) > 0 }) {
//                    bowToUse = equippedBow
//                    arrowToUse = usableArrow
//                } else {
//                    return (false, "You have a Bow equipped but no suitable Arrows (T\(requiredArrowTier)+).")
//                }
//            }
//        }
        
        bowToUse = equippedBow
        arrowToUse = usableArrows

        // --- 3. VALIDATE GEAR FOR HIGH-TIER HUNTS ---
        if trackTier >= 5 {
            guard bowToUse != nil, arrowToUse != nil else {
                return (.invalid, "A Bow and suitable Arrows are required for this dangerous hunt.")
            }
        }

        // --- 4. Perform Hunt Chance Roll ---
        let dragonRareFindBonus = (self.activeCreature?.type == .dragon && self.activeCreature?.state == .trainedAdult) ? 0.005 : 0.0
        let gearRareFindBonus = activeStatBonuses[.rareFindChanceBonus] ?? 0.0
        let totalRareFindBonus = gearRareFindBonus + dragonRareFindBonus
        
        let baseSuccessChance = 0.50
        let skillBonus = Double(huntingLevel - trackNode.type.requiredSkillLevel) * 0.02
        
        // Calculate bonuses from the gear that will be used
        let bowBonus = bowToUse?.huntSuccessBonus ?? 0.0
        let arrowBonus = arrowToUse?.arrowSuccessBonus ?? 0.0
        let huntStatBonus = activeStatBonuses[.huntingSuccessChanceBonus] ?? 0.0
        
    // --- HAWK "Predator's Gaze" ABILITY (Part 1) ---
        var hawkBonus = 0.0
        if let activePet = self.activeCreature,
           activePet.type == .hawk,
           activePet.state == .trainedAdult {
            hawkBonus = 0.10 // +10% success chance
            print("HAWK ABILITY: Predator's Gaze active, +10% hunt success.")
        }
        
        let finalSuccessChance = (baseSuccessChance + skillBonus + bowBonus + arrowBonus + huntStatBonus + hawkBonus).clamped(to: 0.1...0.95)

        // --- 5. Consume Durability & Ammo for the ATTEMPT ---
        consumeDurability(for: knifeToUse, resourceType: trackNode.type, playerSkillLevel: huntingLevel)
        if let bow = bowToUse {
            consumeDurability(for: bow, resourceType: trackNode.type, playerSkillLevel: huntingLevel)
        }

        // --- 6. Determine Outcome ---
        if Double.random(in: 0...1) < finalSuccessChance {
            // SUCCESS!
        // --- HAWK "Predator's Gaze" ABILITY (Part 2) ---
            var arrowConsumed = true
            if let activePet = self.activeCreature,
               activePet.type == .hawk,
               activePet.state == .trainedAdult {
                if Double.random(in: 0...1) < 0.25 { // 25% chance to save
                    arrowConsumed = false
                    print("HAWK ABILITY: Arrow conserved!")
                    if let arrow = arrowToUse {
                        let feedback = FeedbackEvent(message: "Your Hawk recovered your \(arrow.displayName)!", isPositive: true)
                                        feedbackPublisher.send(feedback)
                    }
                }
            }
            
            // Consume the arrow only if it wasn't conserved.
            if let arrow = arrowToUse, arrowConsumed {
                sanctumItemStorage[arrow, default: 0] -= 1
            }
            
            // Check if the hunt was specifically for a T11 Fire Drake.
            if trackNode.type == .T11_tracks {
                let egg = ResourceType.dragonEgg
                
                // Check if the player is eligible to find the egg (using the same 3-part check).
                let isNotUnlocked = !unlockedPetTypes.contains(where: { $0.eggResourceType == egg })
                let isNotInInventory = (playerInventory[egg] ?? 0) == 0
                let isNotIncubating = !incubatingSlots.contains(where: { $0.eggType == egg })
                
                // Let's give it a 5% drop chance from this specific, difficult hunt.
                let dropChance = 0.05
                
                if isNotUnlocked && isNotInInventory && isNotIncubating &&
                   Double.random(in: 0...1) < (dropChance + totalRareFindBonus) { // Note: We need to calculate totalRareFindBonus here
                    
                    let message = "Unbelievable! You found a Fossilized Dragon Egg from the Fire Drake!"
                    // 1. Add to inventory FIRST.
                    playerInventory[egg, default: 0] += 1
                    // 2. Log the message SECOND.
                    logMessage(message, type: .rare)
                    // 3. Set the pop-up message LAST.
                    lastPotionStatusMessage = message
                    print("ULTRA RARE DROP: Found a Dragon Egg from T11 Hunt!")
                }
            }
            
            guard let huntYieldType = trackNode.type.huntYieldType else { return (.invalid, "Config Error: No yield.") }
            
            let knifeBonus = Double(knifeToUse.tier - 1) * 0.5 // e.g., T1=0, T2=0.5, T3=1.0 bonus yield
            let potentialYield = Int.random(in: 1...2) + Int(knifeBonus.rounded(.up)) // Knife tier affects yield
            let availableCapacity = maxGeneralResourceCapacity - currentGeneralResourceLoad
            let amountToAdd = min(potentialYield, availableCapacity)
            
            // ALWAYS award the XP for a successful hunt, regardless of inventory space.
            addXP(trackNode.type.baseXPYield, to: huntingSkill)

            // ALWAYS handle rare drop checks on a successful hunt.
            handleRareDrops(from: trackNode.type)

            // Now, check if the player could actually collect the items.
            if amountToAdd > 0 {
                // Player has space. This is a true SUCCESS.
                playerInventory[huntYieldType, default: 0] += amountToAdd
                
                var feedback = "Successful Hunt! +\(amountToAdd) \(huntYieldType.displayName)."
                if amountToAdd < potentialYield { feedback += " (Backpack partially full)" }
                
                // Check for quest progress.
                var questProgressWasMade = false
                if trackNode.type.tier >= 5 {
                    if updateActivePetQuestProgress(objectiveKey: "high_tier_hunts") {
                        questProgressWasMade = true
                    }
                }
                
                logMessage(feedback, type: .success)
                if !questProgressWasMade {
                    feedbackPublisher.send(FeedbackEvent(message: feedback, isPositive: true))
                }
                
                return (.success, feedback)
                 
            } else {
                // Player has NO space. This is a FAILURE from a reward standpoint.
                let fullMessage = "Successful Hunt, but your backpack is full!"
                
                // Send feedback for the failure.
                feedbackPublisher.send(FeedbackEvent(message: fullMessage, isPositive: false))
                logMessage(fullMessage, type: .failure)
                
                // Return a .failure outcome. The node will still be correctly removed
                // because the action was conclusive.
                return (.failure, fullMessage)
            }
        } else {
            // FAILURE
            // When the hunt fails, the arrow is always lost.
            if let arrow = arrowToUse {
                sanctumItemStorage[arrow, default: 0] -= 1
            }
            var feedback = "The prey eluded you!"
            // Subtle reminder if they hunted without a bow
            if bowToUse == nil && trackTier < 5 {
                feedback += " A Bow might have helped."
            }
            addXP(trackNode.type.baseXPYield / 3, to: huntingSkill)
            return (.failure, feedback)
        }
    }
    
    private func gatherStandardResource(nodeToGather: ResourceNode, bypassDistanceAndToolChecks: Bool = false) -> (outcome: GatheringOutcome, message: String?) {
        guard let associatedSkill = nodeToGather.type.associatedSkill else { return (.invalid, "Config error.") }
        let playerSkillLevel = getLevel(for: associatedSkill)
        let resourceType = nodeToGather.type
        
        var toolToUse: ItemType? = nil
        
        // An array to build our final message from different parts.
        var messageParts: [String] = []

        // --- 1. Tool Selection & Validation (RESTORED and CORRECTED) ---
        if !bypassDistanceAndToolChecks {
            if let requirements = resourceType.toolRequirements {
                let requiredCategory = requirements.primaryToolCategory
                
                let requiredSlot: EquipmentSlot
                switch requiredCategory {
                case .pickaxe: requiredSlot = .pickaxe
                case .axe:     requiredSlot = .axe
                case .knife:   requiredSlot = .knife
                case .bow:     requiredSlot = .bow
                case .arrows:  requiredSlot = .arrows
                case .none:    fatalError("Invalid tool category: \(requiredCategory)")
                }

                guard let equippedTool = equippedGear[requiredSlot] else {
                    return (.invalid, "You must equip a \(requiredCategory.rawValue) to gather this.")
                }
                
                let requiredToolTier = resourceType.tier - 1
                if equippedTool.tier < requiredToolTier {
                    return (.invalid, "Your equipped \(equippedTool.displayName) (T\(equippedTool.tier)) isn't strong enough. Requires a T\(requiredToolTier) tool or better.")
                }
                
                toolToUse = equippedTool
                
                // If using an under-tiered but valid tool, add its message part.
                if toolToUse?.tier == requiredToolTier && resourceType.tier > 0 {
                    messageParts.append("(Less effective tool)")
                }
            }
        }

        // --- 2. Determine Yield ---
        var amountToGather = 0
        var xpToAward = resourceType.baseXPYield
        
        if nodeToGather.isDiscovery {
            amountToGather = Int.random(in: 20...30)
            xpToAward = resourceType.baseXPYield * 5
            self.activeDiscoveryNodeID = nil
            messageParts.append("(Bountiful Discovery!)")
        } else {
            let skillLevelBonus = min((playerSkillLevel - 1) / 3, 3)
            let yieldMultiplier = activePotionEffects[.increasedYield] != nil && Date() < activePotionEffects[.increasedYield]! ? 1.2 : 1.0
            
            var baseYieldRange: ClosedRange<Int>
            var xpBonus = 0

            if let tool = toolToUse {
                baseYieldRange = (tool.tier * 2 + 1)...(tool.tier * 2 + 3)
                xpBonus = tool.tier * 5
                if tool.tier < resourceType.tier {
                     baseYieldRange = 1...2
                     xpBonus = 1
                }
            } else { // Hand-gathering
                baseYieldRange = 1...2
            }
            
            amountToGather = Int(Double(Int.random(in: baseYieldRange)) * yieldMultiplier) + skillLevelBonus
            amountToGather = max(1, amountToGather)
            xpToAward += xpBonus
        
            if nodeToGather.isEnriched {
                amountToGather = Int(Double(amountToGather) * 1.5)
                xpToAward = Int(Double(xpToAward) * 1.5)
                messageParts.append("(Enriched!)")
            }
        }
                
        // --- 3. Check Capacity ---
        let capacityType = resourceType.category == .herb ? maxHerbCapacity - currentHerbLoad : maxGeneralResourceCapacity - currentGeneralResourceLoad
        let amountToAdd = min(amountToGather, capacityType)
        
        if amountToAdd <= 0 {
            let fullMessage = "Inventory full for this resource type!"
            feedbackPublisher.send(FeedbackEvent(message: fullMessage, isPositive: false))
            logMessage(fullMessage, type: .failure)
            return (.invalid, fullMessage)
        }
        
        // --- 4. Add to inventory and construct the primary message ---
        playerInventory[resourceType, default: 0] += amountToAdd
        
        var primaryMessage = "Gathered \(amountToAdd) \(resourceType.displayName)!"
        if amountToAdd < amountToGather {
            primaryMessage += " (Inventory partially full)"
        }
        messageParts.insert(primaryMessage, at: 0)

        // --- 5. Check for quest progress ---
        var questProgressWasMade = false
        if isNightTime() {
            if updateActivePetQuestProgress(objectiveKey: "night_gathers", amount: amountToAdd) {
                questProgressWasMade = true
            }
        }
        if resourceType.tier >= 8 && resourceType.category == .stoneOre {
            if updateActivePetQuestProgress(objectiveKey: "t8_plus_ores", amount: amountToAdd) {
                questProgressWasMade = true
            }
        }

        // --- 6. Finalize the message and send notifications ---
        let finalConstructedMessage = messageParts.joined(separator: " ")
        logMessage(finalConstructedMessage, type: .success)

        if !questProgressWasMade {
            feedbackPublisher.send(FeedbackEvent(message: finalConstructedMessage, isPositive: true))
        }

        // --- 7. Apply Durability & XP (Corrected) ---
        // The 'toolToUse' variable is now correctly populated from Step 1.
        // The 'xpToAward' variable is correctly calculated in Step 2.
        // This logic will now work as intended.
        if let tool = toolToUse, !bypassDistanceAndToolChecks {
            consumeDurability(for: tool, resourceType: nodeToGather.type, playerSkillLevel: playerSkillLevel)
        }
        addXP(xpToAward, to: associatedSkill)
        
    // --- RAVEN "Scavenger" ABILITY ---
        // Check if the active pet is a trained Raven.
        if let activePet = self.activeCreature,
           activePet.type == .raven,
           activePet.state == .trainedAdult {
            
            // Roll for the ability proc.
            if Double.random(in: 0...1) < 0.03 { // 3% chance
                // Define the pool of possible "gifts".
                let giftPool: [ResourceType] = [.T2_stone, .T2_wood, .T2_herb, .T3_stone, .T3_wood, .T3_herb, .T4_stone, .T4_wood, .T4_herb]
                
                if let gift = giftPool.randomElement() {
                    let amount = Int.random(in: 1...3)
                    playerInventory[gift, default: 0] += amount
                    
                    // Provide feedback to the player!
                    lastPotionStatusMessage = "Your Raven brought you a gift! (+\(amount) \(gift.displayName))"
                    print("RAVEN ABILITY: Scavenger proced, found \(amount) \(gift.displayName).")
                }
            }
        }
        
        // After a successful gather where items are added to inventory:
        handleRareDrops(from: nodeToGather.type)

        return (.success, finalConstructedMessage)
    }
    
    private func handleRareDrops(from gatheredResourceType: ResourceType) {
        let miningLevel = getLevel(for: .mining)
        let woodcuttingLevel = getLevel(for: .woodcutting)
        let huntingLevel = getLevel(for: .hunting)
        
        // --- DRAGON "Hoard Instinct" ABILITY ---
        var dragonRareFindBonus = 0.0
        if let activePet = self.activeCreature,
           activePet.type == .dragon,
           activePet.state == .trainedAdult {
            dragonRareFindBonus = 0.005 // +0.5%
            print("DRAGON ABILITY: Hoard Instinct active, +0.5% rare find chance.")
        }
        // Get bonus from gear/jewelry
        let gearRareFindBonus = activeStatBonuses[.rareFindChanceBonus] ?? 0.0
        // Calculate total bonus
        let totalRareFindBonus = gearRareFindBonus + dragonRareFindBonus
        
        // --- Gem Drops from Mining (with total bonus) ---
        if gatheredResourceType.category == .stoneOre && miningLevel >= 15 {
            var gemToFind: ResourceType? = nil
            var gemChance: Double = 0.0
            
            let resourceTier = gatheredResourceType.tier
            if resourceTier >= 10 && miningLevel >= 45 { gemToFind = .T6_gemstone; gemChance = (resourceTier == 10 ? 0.01 : 0.02) }
            else if resourceTier >= 8 && miningLevel >= 39 { gemToFind = .T5_gemstone; gemChance = (resourceTier == 8 ? 0.01 : 0.02) }
            else if resourceTier >= 7 && miningLevel >= 33 { gemToFind = .T4_gemstone; gemChance = (resourceTier == 7 ? 0.01 : 0.02) }
            else if resourceTier >= 6 && miningLevel >= 27 { gemToFind = .T3_gemstone; gemChance = (resourceTier == 6 ? 0.01 : 0.02) }
            else if resourceTier >= 5 && miningLevel >= 21 { gemToFind = .T2_gemstone; gemChance = (resourceTier == 5 ? 0.01 : 0.02) }
            else if resourceTier >= 4 && miningLevel >= 15 { gemToFind = .T1_gemstone; gemChance = (resourceTier == 4 ? 0.01 : 0.02) }
            
            if let gem = gemToFind, Double.random(in: 0...1) < (gemChance + totalRareFindBonus) {
                let message = "You found a rare \(gem.displayName)!"
                playerInventory[gem, default: 0] += 1
                self.logMessage(message, type: .rare)
                
                // Check for quest progress and suppress the pop-up if progress was made.
                if !updateActivePetQuestProgress(objectiveKey: "rare_finds") {
                    lastPotionStatusMessage = message // Use the potion/rare pop-up
                }
                print("RARE DROP: Found \(gem.displayName)...")
            }
        }
        
        // --- Whetstone Drops from Mining ---
        if gatheredResourceType.category == .stoneOre && miningLevel >= 15 {
            if Double.random(in: 0...1) < (0.015 + totalRareFindBonus) {
                let message = "You found a Whetstone while mining!"
                sanctumItemStorage[.whetstone, default: 0] += 1
                self.logMessage(message, type: .rare)
                
                // Check for quest progress and suppress the pop-up
                if !updateActivePetQuestProgress(objectiveKey: "rare_finds") {
                    lastPotionStatusMessage = message
                }
                print("RARE DROP: Found Whetstone.")
            }
        }
        
        // --- Feather Drops from Foraging ---
        if gatheredResourceType.category == .herb && getLevel(for: .foraging) >= 10 {
            if Double.random(in: 0...1) < 0.05 {
                let amount = Int.random(in: 5...15)
                let message = "You found \(amount) Feathers while foraging!"
                playerInventory[.feathers, default: 0] += amount
                self.logMessage(message, type: .rare)

                // Check for quest progress and suppress the pop-up
                if !updateActivePetQuestProgress(objectiveKey: "rare_finds", amount: amount) { // Pass amount for multi-progress
                    lastPotionStatusMessage = message
                }
            }
        }
        
        // --- Seed Drop Logic ---
            // Let's say a 10% chance to find seeds
            if Double.random(in: 0...1) < (0.10 + totalRareFindBonus) {
                // Find the corresponding seed for the herb that was just gathered
                if let seedToFind = gatheredResourceType.correspondingSeed {
                    let amount = Int.random(in: 1...3)
                    playerInventory[seedToFind, default: 0] += amount
                    
                    // Send a pop-up and log the message
                    let message = "You found \(amount)x \(seedToFind.displayName)!"
                    self.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: true))
                    self.logMessage(message, type: .rare)
                }
            }
        
        // --- Egg Drops from Woodcutting ---
        if gatheredResourceType.category == .wood && woodcuttingLevel >= 15 && huntingLevel >= 15 {
            
            print("--- Egg Drop Check Started (WC Lvl: \(woodcuttingLevel), Hunt Lvl: \(huntingLevel)) ---")

                // 1. Define all possible bird eggs and their requirements.
                let allBirdEggs: [(egg: ResourceType, wcLvl: Int, huntLvl: Int)] = [
                    (egg: .ravenEgg, wcLvl: 15, huntLvl: 15),
                    (egg: .owlEgg, wcLvl: 25, huntLvl: 25),
                    (egg: .hawkEgg, wcLvl: 30, huntLvl: 30)
                    // Dragon egg is handled separately in performHunt.
                ]

                // 2. Determine which eggs the player is high enough level to find.
                let eligibleEggPool = allBirdEggs.filter { potentialEgg in
                    woodcuttingLevel >= potentialEgg.wcLvl && huntingLevel >= potentialEgg.huntLvl
                }

                // --- LOGIC FIX 1: Check for eligibility FIRST ---
                if eligibleEggPool.isEmpty {
                    print("Player is not high enough level for any bird egg drops.")
                    return // Exit silently. No need to spam the player.
                }
                
                print("Eligible Pool (based on skills): \(eligibleEggPool.map { $0.egg.displayName })")

            print("--- Starting Detailed Ownership Filter ---")
                let eggsPlayerCanStillFind = eligibleEggPool.filter { potentialEgg in
                    let egg = potentialEgg.egg
                    print("Checking ownership for: \(egg.displayName)...")
                    
                    let isNotUnlocked = !unlockedPetTypes.contains { $0.eggResourceType == egg }
                    print("... Is Not Unlocked (hatched): \(isNotUnlocked)")
                    
                    let isNotInInventory = (playerInventory[egg] ?? 0) == 0
                    print("... Is Not In Inventory: \(isNotInInventory)")
                    
                    let isNotIncubating = !incubatingSlots.contains { $0.eggType == egg }
                    print("... Is Not Incubating: \(isNotIncubating)")
                    
                    let canBeFound = isNotUnlocked && isNotInInventory && isNotIncubating
                    print("... Final decision for \(egg.displayName): Can be found = \(canBeFound)")
                    
                    return canBeFound
                }

                if eggsPlayerCanStillFind.isEmpty {
                    print("DEBUG: Player has already found/unlocked all eligible eggs.")
                    // Let's print the state of the collections to be 100% sure
                    print("DEBUG: unlockedPetTypes = \(unlockedPetTypes.map { $0.displayName })")
                    print("DEBUG: incubatingSlots = \(incubatingSlots.map { $0.eggType.displayName })")
                    print("DEBUG: eggs in inventory = \(playerInventory.filter { $0.key.tags?.contains(.egg) == true })")
                    return
                }
                
                print("DEBUG: Final Pool (eggs player can still find): \(eggsPlayerCanStillFind.map { $0.egg.displayName })")

                
                // 4. If there's an egg to find, roll the dice.
                let dropChance = 0.02 // Set back to a reasonable value
                
                print("Rolling for a drop with a \(Int(dropChance * 100))% chance...")
                
                if Double.random(in: 0...1) < (dropChance + totalRareFindBonus) {
                    
                    // 5. Success! Award a random egg from the final, filtered pool.
                    if let eggToAward = eggsPlayerCanStillFind.randomElement()?.egg {
                        let message = "Incredibly, you found a \(eggToAward.displayName)!"
                        // 1. Add to inventory FIRST.
                        playerInventory[eggToAward, default: 0] += 1
                        // 2. Log the message SECOND. This updates the bottom bar.
                        self.logMessage(message, type: .rare)
                        // 3. Set the pop-up message LAST. This updates the top of the screen.
                        lastPotionStatusMessage = message
                        print("SUCCESS! Player found a \(eggToAward.displayName)!")
                    }
                } else {
                    print("Roll failed. No egg this time.")
                }
        }
    }
    
    func petFetchResource(node: ResourceNode, playerLocation: CLLocation) -> (success: Bool, message: String) {
        // --- This part of the function remains the same ---
        guard let activePetID = self.activeCreatureID,
              let petIndex = ownedCreatures.firstIndex(where: { $0.id == activePetID }) else {
            return (false, "You need an active companion to fetch resources.")
        }
        
        let pet = ownedCreatures[petIndex]
        guard pet.state == .trainedAdult else {
            return (false, "Your companion needs to be fully trained to fetch.")
        }
        
        let dynamicFetchRange = self.resourceSpawnRadius + pet.type.visionBonus
        let nodeLocation = CLLocation(latitude: node.coordinate.latitude, longitude: node.coordinate.longitude)
        guard playerLocation.distance(from: nodeLocation) <= dynamicFetchRange else {
            return (false, "The resource is too far for your companion to fetch.")
        }
        
        var maxCharges = pet.type.maxFetchCharges
        if pet.type == .owl && isNightTime() { maxCharges += 1 }
        guard pet.fetchCharges > 0 else {
            let nextRestore = ownedCreatures[petIndex].chargeRestoreTimes.min() ?? Date()
            let minutesRemaining = Int(nextRestore.timeIntervalSinceNow / 60) + 1
            return (false, "Your companion is tired. Next fetch available in \(minutesRemaining) min.")
        }
        
        ownedCreatures[petIndex].fetchCharges -= 1
        let cooldown = ownedCreatures[petIndex].type.fetchCooldown
        ownedCreatures[petIndex].chargeRestoreTimes.append(Date().addingTimeInterval(cooldown))
        
        let result: (outcome: GatheringOutcome, message: String?)

        if node.type.isTrackType && pet.type == .dragon {
            if node.type.tier <= 10 {
                // performGuaranteedHunt needs to be updated to return the new outcome type.
                result = performGuaranteedHunt(trackNode: node)
            } else {
                result = (.invalid, "These tracks are too powerful even for your Dragon.")
            }
        } else {
            // This call now correctly matches the new return type.
            result = gatherStandardResource(nodeToGather: node, bypassDistanceAndToolChecks: true)
        }
        
        let petName = pet.name ?? pet.type.displayName
        
        // 2. Handle the outcome of the fetch.
        switch result.outcome {
        case .success:
            // The fetch was a complete success.
            activeResourceNodes.removeAll { $0.id == node.id }
            let successMessage = "\(petName) brought you: \(result.message ?? "resources!")"
            feedbackPublisher.send(FeedbackEvent(message: successMessage, isPositive: true))
            logMessage(successMessage, type: .success)
            return (true, successMessage)
            
        case .failure:
            // The fetch was attempted but failed (e.g., full inventory on a hunt).
            activeResourceNodes.removeAll { $0.id == node.id } // Still remove the node
            
            let failureMessage = result.message ?? "\(petName) failed to retrieve the items."
            feedbackPublisher.send(FeedbackEvent(message: failureMessage, isPositive: false))
            logMessage(failureMessage, type: .failure)
            
            // Refund the charge on failure.
            let maxCharges = pet.type.maxFetchCharges + (pet.type == .owl && isNightTime() ? 1 : 0)
            ownedCreatures[petIndex].fetchCharges = min(ownedCreatures[petIndex].fetchCharges + 1, maxCharges)
            _ = ownedCreatures[petIndex].chargeRestoreTimes.popLast()
            
            return (false, failureMessage)

        case .invalid:
            // The fetch was invalid (e.g., full inventory on a standard gather).
            let invalidMessage: String
            if result.message?.lowercased().contains("full") == true {
                let resourceName = node.type.huntYieldType?.displayName ?? node.type.displayName
                invalidMessage = "\(petName) tried to bring you \(resourceName), but your inventory is full."
            } else {
                invalidMessage = result.message ?? "\(petName) could not fetch the resource."
            }

            feedbackPublisher.send(FeedbackEvent(message: invalidMessage, isPositive: false))
            logMessage(invalidMessage, type: .failure)

            // Refund the charge on an invalid attempt.
            let maxCharges = pet.type.maxFetchCharges + (pet.type == .owl && isNightTime() ? 1 : 0)
            ownedCreatures[petIndex].fetchCharges = min(ownedCreatures[petIndex].fetchCharges + 1, maxCharges)
            _ = ownedCreatures[petIndex].chargeRestoreTimes.popLast()
            
            return (false, invalidMessage)
        }
    }
    
    func plantSeed(_ seedType: ResourceType, inPlotID plotID: UUID) -> (success: Bool, message: String) {
        // 1. Find the plot
        guard let plotIndex = gardenPlots.firstIndex(where: { $0.id == plotID }) else {
            return (false, "Could not find the garden plot.")
        }
        
        // 2. Make sure it's empty
        guard gardenPlots[plotIndex].isEmpty else {
            return (false, "This plot is already in use.")
        }
        
        // 3. Check if the player has the seed
        guard (playerInventory[seedType] ?? 0) > 0 else {
            return (false, "You don't have any \(seedType.displayName).")
        }
        
        // 4. Consume the seed and plant it
        playerInventory[seedType, default: 0] -= 1
        gardenPlots[plotIndex].plantedSeed = seedType
        gardenPlots[plotIndex].plantTime = Date()
        
        return (true, "Planted \(seedType.displayName)!")
    }
    
    func harvestPlot(plotID: UUID) -> (success: Bool, message: String) {
        guard let plotIndex = gardenPlots.firstIndex(where: { $0.id == plotID }) else {
            return (false, "Could not find the garden plot.")
        }
        
        guard let plantedSeed = gardenPlots[plotIndex].plantedSeed,
              let plantTime = gardenPlots[plotIndex].plantTime,
              let growthTime = plantedSeed.growthTime,
              let herbToYield = plantedSeed.correspondingHerb,
              let yieldAmount = plantedSeed.harvestYield else {
            return (false, "There is nothing ready to harvest in this plot.")
        }

        // Check if enough time has passed
        guard Date().timeIntervalSince(plantTime) >= growthTime else {
            return (false, "This plant is not yet fully grown.")
        }
        
        // Check for inventory space
        guard (maxHerbCapacity - currentHerbLoad) >= yieldAmount else {
            return (false, "Your herb satchel is too full to harvest this.")
        }
        
        // Harvest the plant!
        playerInventory[herbToYield, default: 0] += yieldAmount
        addXP(Int(Double(herbToYield.baseXPYield) * 0.5 * Double(yieldAmount)), to: .foraging) // Grant foraging XP
        
        // Reset the plot
        gardenPlots[plotIndex].plantedSeed = nil
        gardenPlots[plotIndex].plantTime = nil
        
        return (true, "Harvested \(yieldAmount)x \(herbToYield.displayName)!")
    }
}
