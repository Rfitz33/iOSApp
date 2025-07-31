//
//  Untitled.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//
import Foundation
import CoreLocation

// MARK: - World Logic
extension GameManager {
    // All world methods will go inside this block.
    
    // MARK: - World Update Timer and Logic
    func startWorldUpdateTimer() {
        stopWorldUpdateTimer() // Ensure no existing timer is running
        worldUpdateTimer = Timer.scheduledTimer(
            timeInterval: worldUpdateInterval,
            target: self,
            selector: #selector(updateWorldState), // Call the @objc method
            userInfo: nil,
            repeats: true
        )
        print("World update timer started (interval: \(worldUpdateInterval)s).")
    }
    
    func stopWorldUpdateTimer() {
        worldUpdateTimer?.invalidate()
        worldUpdateTimer = nil
        print("World update timer stopped.")
    }
    
    @objc private func updateWorldState() { // Must be @objc for Timer selector
        // print("World state update tick...") // Can be noisy, enable for debugging
        let now = Date()
        var nodesChanged = false
        
        // 1. Despawn old nodes
        let initialNodeCount = activeResourceNodes.count
        activeResourceNodes.removeAll { node in
            if now >= node.despawnTime {
                // print("Despawning \(node.type.displayName) (ID: \(node.id))")
                nodesChanged = true
                return true // Remove if despawnTime is reached
            }
            return false
        }
        if initialNodeCount > activeResourceNodes.count {
            print("Despawned \(initialNodeCount - activeResourceNodes.count) nodes.")
        }
        // 2. Check potion effects expiry
        checkActivePotionEffects()
        // --- Check on pet growth ---
        updatePetGrowthStates()
        // --- Check on incubating eggs ---
        checkForFinishedIncubations()
        
        updatePassiveFeatherGeneration()
        
        updatePetFetchCharges()
        
        // 3. Check conditions for periodic spawning
        var shouldAttemptSpawn = false
        // We need a valid player location to spawn around
        guard let playerLocationForSpawning = self.currentLatestPlayerLocation else {
            // print("GM: Cannot perform periodic spawn: currentLatestPlayerLocation unknown.")
            if nodesChanged { self.objectWillChange.send() }
            return
        }
        
        
        if lastPeriodicSpawnTime == nil { // First time check
            shouldAttemptSpawn = true
        } else if let lastSpawn = lastPeriodicSpawnTime, now.timeIntervalSince(lastSpawn) >= periodicSpawnTimeThreshold {
            // Time-based spawn trigger (if player is stationary)
            shouldAttemptSpawn = true
            print("Periodic spawn triggered by time.")
        } else if let lastPlayerLoc = lastPlayerLocationForSpawnTrigger,
                  playerLocationForSpawning.distance(from: lastPlayerLoc) >= periodicSpawnMovementThreshold {
            shouldAttemptSpawn = true
            print("GM: Periodic spawn triggered by movement.")
        }
        
        if shouldAttemptSpawn {
            if activeResourceNodes.count < maxResourceNodes {
                print("GM: Attempting periodic spawn around player.")
                spawnResources(around: playerLocationForSpawning.coordinate)
                nodesChanged = true
            }
            lastPeriodicSpawnTime = now
            lastPlayerLocationForSpawnTrigger = playerLocationForSpawning
        }
        
        if nodesChanged {
            self.objectWillChange.send() // Notify views if any nodes were added or removed
        }
    }
    
    func spawnResources(around centerCoordinate: CLLocationCoordinate2D) {
        // 1. Determine Radii and Max Nodes
        let baseRadius = self.resourceSpawnRadius // e.g., 150.0
        let petBonus = self.activeCreature?.type.visionBonus ?? 0.0
        let effectiveRadius = baseRadius + petBonus

        // We can increase the max nodes on the map when a pet is active.
        // Example: +5 nodes for every 100m of bonus radius.
        let bonusNodeCapacity = Int(petBonus / 100.0) * 5
        let effectiveMaxNodes = self.maxResourceNodes + bonusNodeCapacity

        // Exit if the map is already full
        guard activeResourceNodes.count < effectiveMaxNodes else { return }

        // 2. Perform INNER RING Spawn (Guaranteed Density)
        // Attempt to spawn up to the original max node count in the base radius.
        let innerSpawnAttempts = maxResourceNodes - activeResourceNodes.count
        if innerSpawnAttempts > 0 {
            print("Spawning in INNER ring (radius: \(baseRadius)m)")
            spawnNodes(
                count: innerSpawnAttempts,
                inRadius: baseRadius,
                minDistance: 0, // No minimum distance for the inner ring
                center: centerCoordinate,
                maxNodeCap: maxResourceNodes // Inner ring has its own cap
            )
        }

        // 3. Perform OUTER RING Spawn (Pet Bonus)
        // Only run if a pet is active and we still have capacity for bonus nodes.
        if petBonus > 0 && activeResourceNodes.count < effectiveMaxNodes {
            let outerSpawnAttempts = effectiveMaxNodes - activeResourceNodes.count
            if outerSpawnAttempts > 0 {
                print("Spawning in OUTER ring (from \(baseRadius)m to \(effectiveRadius)m)")
                spawnNodes(
                    count: outerSpawnAttempts,
                    inRadius: effectiveRadius,
                    minDistance: baseRadius, // CRITICAL: This creates the "donut" shape
                    center: centerCoordinate,
                    maxNodeCap: effectiveMaxNodes // Use the full new capacity
                )
            }
        }
    }
    
    private func spawnNodes(count: Int, inRadius: Double, minDistance: Double, center: CLLocationCoordinate2D, maxNodeCap: Int) {
        var spawnedCount = 0
        var attempts = 0
        let maxAttempts = count * 5

        let miningLevel = getLevel(for: .mining)
        let woodcuttingLevel = getLevel(for: .woodcutting)
        let foragingLevel = getLevel(for: .foraging)
        let huntingLevel = getLevel(for: .hunting)
        
        let possibleSpawns = masterResourceSpawnList.filter { spawnInfo in
            let playerSkillLevelForThisResource: Int
            if let associatedSkill = spawnInfo.type.associatedSkill {
                switch associatedSkill {
                case .mining: playerSkillLevelForThisResource = miningLevel
                case .woodcutting: playerSkillLevelForThisResource = woodcuttingLevel
                case .foraging: playerSkillLevelForThisResource = foragingLevel
                case .hunting: playerSkillLevelForThisResource = huntingLevel
                default: playerSkillLevelForThisResource = 0
                }
            } else {
                playerSkillLevelForThisResource = 1
            }
            guard playerSkillLevelForThisResource >= spawnInfo.minSkillLevelToSee else {
                return false
            }
            if let maxLevel = spawnInfo.maxSkillLevelToConsiderSpawning {
                if playerSkillLevelForThisResource > maxLevel {
                    return false
                }
            }
            return true
        }
        
        guard !possibleSpawns.isEmpty else {
            print("Spawn check: No resources are eligible to spawn for the player's current skill levels.")
            return
        }

        while spawnedCount < count && attempts < maxAttempts && activeResourceNodes.count < maxNodeCap {
            attempts += 1
            
            let totalWeight = possibleSpawns.reduce(0) { $0 + $1.weight }
            guard totalWeight > 0 else { continue }
            let randomNumber = Int.random(in: 1...totalWeight)
            var cumulativeWeight = 0
            var selectedSpawnInfo: ResourceSpawnInfo? = nil
            for spawnInfo in possibleSpawns.shuffled() {
                cumulativeWeight += spawnInfo.weight
                if randomNumber <= cumulativeWeight {
                    selectedSpawnInfo = spawnInfo
                    break
                }
            }
            guard let resourceToSpawnOriginal = selectedSpawnInfo?.type else { continue }
            // 1. Declare 'resourceToSpawn' in the outer scope of the loop.
            var resourceToSpawn = resourceToSpawnOriginal
            
            // --- DRAGON "World Weaver" ABILITY ---
            if let activePet = self.activeCreature,
               activePet.type == .dragon,
               activePet.state == .trainedAdult,
               Double.random(in: 0...1) < 0.10 {
                
                var procSucceeded = false
                let targetTier = resourceToSpawn.tier + 1
                if let upgradedResource = ResourceType.allCases.first(where: { $0.tier == targetTier && $0.category == resourceToSpawn.category }) {
                    if let skill = upgradedResource.associatedSkill, getLevel(for: skill) >= upgradedResource.requiredSkillLevel {
                        print("DRAGON ABILITY: World Weaver proc! Upgrading \(resourceToSpawn.displayName) to \(upgradedResource.displayName).")
                        resourceToSpawn = upgradedResource
                        procSucceeded = true
                    }
                }
                if !procSucceeded {
                    for _ in 0..<5 {
                        if let newOriginalInfo = possibleSpawns.randomElement(), newOriginalInfo.type != resourceToSpawnOriginal {
                            let newTargetTier = newOriginalInfo.type.tier + 1
                            if let newUpgraded = ResourceType.allCases.first(where: { $0.tier == newTargetTier && $0.category == newOriginalInfo.type.category }) {
                                if let skill = newUpgraded.associatedSkill, getLevel(for: skill) >= newUpgraded.requiredSkillLevel {
                                    print("DRAGON ABILITY: World Weaver re-roll success! Spawning \(newUpgraded.displayName) instead.")
                                    resourceToSpawn = newUpgraded
                                    procSucceeded = true
                                    break
                                }
                            }
                        }
                    }
                }
                if !procSucceeded {
                    print("DRAGON ABILITY: World Weaver proced but no valid upgrade found. Spawning original.")
                }
            }
            
            let randomAngle = Double.random(in: 0...(2 * .pi))
            let randomDistance = Double.random(in: minDistance...inRadius)
            
            let latOffset = (randomDistance * cos(randomAngle)) / 111000.0
            let lonOffset = (randomDistance * sin(randomAngle)) / (111000.0 * cos(center.latitude * .pi / 180.0))
            let potentialCoordinate = CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude + lonOffset)
            let potentialLocation = CLLocation(latitude: potentialCoordinate.latitude, longitude: potentialCoordinate.longitude)
            
            var isTooClose = activeResourceNodes.contains { existingNode in
                let existingLoc = CLLocation(latitude: existingNode.coordinate.latitude, longitude: existingNode.coordinate.longitude)
                return potentialLocation.distance(from: existingLoc) < self.minDistanceBetweenNodes
            }
            if let homeBaseCoord = homeBase?.coordinate {
                let homeBaseLocation = CLLocation(latitude: homeBaseCoord.latitude, longitude: homeBaseCoord.longitude)
                if potentialLocation.distance(from: homeBaseLocation) < self.minDistanceFromBase {
                    isTooClose = true
                }
            }
            if isTooClose { continue }
            
            // --- "Aura of Abundance" Logic ---
            var shouldBeEnriched = false
            if activeBaseUpgrades.contains(.watchtower), let homeBaseLocation = self.homeBase?.location {
                let distanceFromBase = potentialLocation.distance(from: homeBaseLocation)
                
                // Check if the node is within the Watchtower's influence radius.
                if distanceFromBase <= watchtowerInfluenceRadius {
                    // 15% chance to become enriched.
                    if Double.random(in: 0...1) < 0.15 {
                        shouldBeEnriched = true
                        print("WATCHTOWER ABILITY: Node at \(potentialCoordinate) became Enriched.")
                    }
                }
            }

            // All checks passed, create and add the node.
            // Pass the new 'isEnriched' flag to the initializer.
            let newNode = ResourceNode(type: resourceToSpawn, coordinate: potentialCoordinate, isEnriched: shouldBeEnriched)
            activeResourceNodes.append(newNode)
            spawnedCount += 1
        }
    }
    
    // Gets the currently active creature object, if any.
    var activeCreature: Creature? {
        guard let activeID = activeCreatureID else { return nil }
        return ownedCreatures.first { $0.id == activeID }
    }

    // Called from the AviaryView to place an egg in an incubator.
    func startIncubation(eggType: ResourceType) -> (success: Bool, message: String) {
        // 1. Check if the passed type is actually an egg.
        guard eggType.tags?.contains(.egg) == true else {
            return (false, "This item cannot be incubated.")
        }

        // 2. Check if there's a free incubation slot.
        guard incubatingSlots.count < aviaryIncubationSlots else {
            return (false, "All incubation slots are full.")
        }
        
        // 3. Check if the player has the egg resource.
        guard (playerInventory[eggType] ?? 0) > 0 else {
            return (false, "You do not have a \(eggType.displayName).")
        }
        
        // 4. Consume the egg and start incubation.
        playerInventory[eggType, default: 0] -= 1
        let newSlot = IncubationSlot(eggType: eggType)
        incubatingSlots.append(newSlot)
        
        print("Started incubating \(eggType.displayName).")
        return (true, "\(eggType.displayName) placed in incubator.")
    }

    // Called when the user taps a "Hatch" button in the UI.
    func hatchEgg(slotID: UUID) -> (success: Bool, message: String) {
        // 1. Find the slot.
        guard let slotIndex = incubatingSlots.firstIndex(where: { $0.id == slotID }) else {
            return (false, "Could not find the egg slot.")
        }
        let slot = incubatingSlots[slotIndex]
        
        // 2. Check if it's ready to hatch.
        guard let creatureType = slot.creatureType else {
            return (false, "Invalid egg type.")
        }
        let timeElapsed = Date().timeIntervalSince(slot.incubationStartTime)
        guard timeElapsed >= creatureType.incubationTime else {
            return (false, "This egg is not ready to hatch yet.")
        }
        
        // 3. Hatch it!
        let newCreature = Creature(type: creatureType)
        ownedCreatures.append(newCreature)
        incubatingSlots.remove(at: slotIndex)
        
        unlockedPetTypes.insert(newCreature.type)
        
        // Set as active pet if it's the first one.
        if activeCreatureID == nil {
            setActiveCreature(creatureID: newCreature.id)
        }
        
        print("Hatched a new \(creatureType.displayName)!")
        return (true, "Your egg hatched into a \(creatureType.displayName)!")
    }

    // Called periodically by the world update timer.
    func checkForFinishedIncubations() {
        // This function is for future use (like local notifications).
        // The hatching is manually triggered by the user in the AviaryView, so this is fine.
    }
    
    // Called from the AviaryView to set the active companion.
    func setActiveCreature(creatureID: UUID?) {
        // Setting to nil is valid (no active pet).
        guard let id = creatureID else {
            self.activeCreatureID = nil
            print("No pet is active.")
            return
        }
        
        // Ensure the creature is actually owned by the player.
        if ownedCreatures.contains(where: { $0.id == id }) {
            self.activeCreatureID = id
            print("Set active pet to \(activeCreature?.type.displayName ?? "Unknown").")
        } else {
             self.activeCreatureID = nil // Safety check in case of a bug
        }
    }
    
    /// Checks all hatchlings and promotes them to Untrained Adult if their growth timer is complete.
    func updatePetGrowthStates() {
        var hasStateChanged = false
        for i in 0..<ownedCreatures.count {
            // We only care about hatchlings.
            guard ownedCreatures[i].state == .hatchling else { continue }
            
            // Safely unwrap the required dates and durations.
            guard let growthStartTime = ownedCreatures[i].growthStartTime else { continue }
            let creatureType = ownedCreatures[i].type
            
            // Calculate total time elapsed.
            let timeSinceHatched = Date().timeIntervalSince(growthStartTime)
            
            // Get any earned time reductions from walking, feeding, etc.
            let earnedReduction = petGrowthReductions[ownedCreatures[i].id] ?? 0
            
            // Check if effective time has passed the required duration.
            if (timeSinceHatched + earnedReduction) >= creatureType.growthDuration {
                // Promote the pet!
                ownedCreatures[i].state = .untrainedAdult
                ownedCreatures[i].growthStartTime = nil // Clear the start time, it's no longer needed
                hasStateChanged = true
                
                // 1. Construct the new, improved message string.
                let petName = ownedCreatures[i].name ?? creatureType.displayName
                let growthMessage = "Your \(petName) has grown! It's ready for training."
                
                // 2. Send the message to the pop-up publisher as a "rare" event.
                // This will create the yellow pop-up you want to keep.
                feedbackPublisher.send(FeedbackEvent(message: growthMessage, isPositive: true))
                
                // 3. Send the same message to the history log.
                logMessage(growthMessage, type: .rare)
                print("Pet Promotion: \(petName) is now an Untrained Adult.")
            }
        }
        
        if hasStateChanged {
            // Trigger a UI update if a pet was promoted.
            objectWillChange.send()
        }
    }
    
    func updatePassiveFeatherGeneration() {
        guard activeBaseUpgrades.contains(.aviary) else { return }
        
        let featherCap = 50
        guard accumulatedFeathers < featherCap else { return }
        
        let now = Date()
        // If we've never collected, the "last time" is when the aviary was built, or now for simplicity.
        let lastCollection = lastFeatherCollectionTime ?? now
        
        let secondsPassed = now.timeIntervalSince(lastCollection)
        let hoursPassed = secondsPassed / 3600
        
        // Generate 1 feather per hour
        let feathersToGenerate = Int(hoursPassed)
        
        if feathersToGenerate > 0 {
            let newTotal = min(accumulatedFeathers + feathersToGenerate, featherCap)
            self.accumulatedFeathers = newTotal
            self.lastFeatherCollectionTime = lastCollection.addingTimeInterval(TimeInterval(feathersToGenerate * 3600))
        }
    }

    func collectFeathers() -> Int {
        let amount = self.accumulatedFeathers
        guard amount > 0 else { return 0 }
        
        playerInventory[.feathers, default: 0] += amount
        self.accumulatedFeathers = 0
        self.lastFeatherCollectionTime = Date()
        
        lastPotionStatusMessage = "Collected \(amount) feathers from the Aviary."
        return amount
    }
    
    // --- Quest System Logic ---

    /// Call this after any action that could contribute to a pet's training quest.
    /// It checks the active pet and updates its progress.
    /// - Parameter objectiveKey: The specific objective to increment, e.g., "high_tier_hunts".
    /// - Parameter amount: The amount to add to the progress, usually 1.
    func updateActivePetQuestProgress(objectiveKey: String, amount: Int = 1) -> Bool {
        // 1. Ensure there is an active pet.
        guard let activePetID = self.activeCreatureID,
              let petIndex = ownedCreatures.firstIndex(where: { $0.id == activePetID }) else {
            return false
        }
        
        // 2. Ensure the pet is in the correct state for training.
        guard ownedCreatures[petIndex].state == .untrainedAdult else {
            return false
        }
        
        let creatureType = ownedCreatures[petIndex].type
        
        // 3. Check if the objective key is valid for this pet's quest.
        guard let requiredAmount = creatureType.trainingQuest.objectives[objectiveKey] else {
            return false// Not a valid objective for this quest.
        }
        
        let currentProgress = ownedCreatures[petIndex].questProgress[objectiveKey, default: 0]
        
        // --- NEW: If progress is already complete, do nothing. ---
        guard currentProgress < requiredAmount else {
            return false// Already done, no need to update or send an event.
        }
        
        // 4. Update the progress, clamping it to the required amount.
        let newProgress = min(currentProgress + amount, requiredAmount) // <-- CRITICAL CHANGE
        ownedCreatures[petIndex].questProgress[objectiveKey] = newProgress
        
        print("Quest Progress for \(creatureType.displayName): '\(objectiveKey)' is now \(newProgress) / \(requiredAmount)")

        // 5. Send the event to the UI
        let event = QuestProgressEvent(
            questTitle: creatureType.trainingQuest.title,
            objectiveKey: objectiveKey,
            currentProgress: newProgress, // Send the clamped value
            requiredAmount: requiredAmount
        )
        questProgressPublisher.send(event)

        // 6. Check if the entire quest is complete.
        checkQuestCompletion(forPetAtIndex: petIndex)
        
        return true
    }

    /// Checks if all objectives for a pet's quest are met and promotes it if they are.
    private func checkQuestCompletion(forPetAtIndex index: Int) {
        guard ownedCreatures[index].state == .untrainedAdult else { return }
        
        let pet = ownedCreatures[index]
        let quest = pet.type.trainingQuest
        var allObjectivesMet = true
        
        for (key, requiredAmount) in quest.objectives {
            let currentProgress = pet.questProgress[key, default: 0]
            if currentProgress < requiredAmount {
                allObjectivesMet = false
                break // Found an incomplete objective, no need to check further.
            }
        }
        
        if allObjectivesMet {
            // Promote the pet to a fully trained adult!
            ownedCreatures[index].state = .trainedAdult
            // We can clear the quest progress dictionary as it's no longer needed.
            ownedCreatures[index].questProgress = [:]
            
            let pet = ownedCreatures[index]
            let petName = pet.name ?? pet.type.displayName
            let message = "Training Complete! \(petName) has learned the \"Fetch\" ability!"

            // --- Use the publisher ---
            feedbackPublisher.send(FeedbackEvent(message: message, isPositive: true))
            logMessage(message, type: .rare)
            print("QUEST COMPLETE: \(pet.type.displayName) is now a Trained Adult.")
            
            // Trigger a UI update.
            objectWillChange.send()
        }
    }
    
    func feedTreat(to creature: Creature, with treat: ItemType) -> (success: Bool, message: String) {
        // 1. Validate that the item is a treat and the creature is a hatchling.
        guard let reduction = treat.growthTimeReduction else { return (false, "This is not a treat.") }
        guard creature.state == .hatchling else { return (false, "Only hatchlings can be fed treats.") }
        
        // 2. Check if the player has the treat.
        guard (sanctumItemStorage[treat] ?? 0) > 0 else { return (false, "You don't have any \(treat.displayName).") }
        
        // 3. Consume the treat and apply the reduction.
        sanctumItemStorage[treat, default: 0] -= 1
        petGrowthReductions[creature.id, default: 0] += reduction
        
        let hours = Int(reduction / 3600)
        let message = "You fed \(creature.name ?? "your pet") a treat! Growth time reduced by \(hours) hours."
        print(message)
        return (true, message)
    }
    
    func updatePetFetchCharges() {
        var hasChanges = false
        for i in 0..<ownedCreatures.count {
            guard ownedCreatures[i].state == .trainedAdult else { continue }
            
            let creatureType = ownedCreatures[i].type
            var maxCharges = creatureType.maxFetchCharges
            // Owl's night bonus for charges
            if creatureType == .owl && isNightTime() {
                maxCharges += 1
            }
            
            // If already at max, nothing to do.
            guard ownedCreatures[i].fetchCharges < maxCharges else { continue }
            
            var chargesToAdd = 0
            ownedCreatures[i].chargeRestoreTimes.removeAll { restoreTime in
                if Date() >= restoreTime {
                    chargesToAdd += 1
                    return true // Remove from list
                }
                return false
            }
            
            if chargesToAdd > 0 {
                ownedCreatures[i].fetchCharges = min(ownedCreatures[i].fetchCharges + chargesToAdd, maxCharges)
                hasChanges = true
            }
        }
        if hasChanges { objectWillChange.send() } // Notify UI if charges were restored
    }
    
    /// Simulates a successful hunt, awarding the appropriate hide. Used by the Dragon's fetch ability.
    func performGuaranteedHunt(trackNode: ResourceNode) -> (outcome: GatheringOutcome, message: String?) {
        guard let huntYieldType = trackNode.type.huntYieldType else {
            return (.invalid, "Configuration Error: This track has no yield.")
        }
        
        // Dragons are powerful, let's give them a good yield.
        // You can customize this yield calculation.
        let potentialYield = Int.random(in: 2...4)
        
        let availableCapacity = maxGeneralResourceCapacity - currentGeneralResourceLoad
        let amountToAdd = min(potentialYield, availableCapacity)
        
        if amountToAdd > 0 {
            playerInventory[huntYieldType, default: 0] += amountToAdd
            
            // Give the player Hunting XP for the successful fetch!
            addXP(trackNode.type.baseXPYield, to: .hunting)
            
            // We can also give a chance for rare hunting drops here if desired.
            // handleRareDrops(from: trackNode.type)
            
            var feedback = "\(amountToAdd) \(huntYieldType.displayName)"
            if amountToAdd < potentialYield { feedback += " (Backpack partially full)" }
            return (.success, feedback)
        } else {
            return (.failure, "Backpack is full!")
        }
    }

    func performHorizonScan(playerLocation: CLLocation) -> (success: Bool, message: String) {
        // 1. Check for prerequisites (Watchtower built, cooldown elapsed)
        guard activeBaseUpgrades.contains(.watchtower) else {
            return (false, "You must build a Watchtower first.")
        }
        if let lastScan = lastHorizonScanTime, Date().timeIntervalSince(lastScan) < watchtowerScanCooldown {
            // Calculate remaining time for the message
            let remaining = watchtowerScanCooldown - Date().timeIntervalSince(lastScan)
            let hours = Int(remaining) / 3600
            return (false, "The scouts are still surveying. Next scan available in \(hours + 1) hours.")
        }
        
        // 2. Remove any old, ungathered discovery node from the map.
        if let oldID = activeDiscoveryNodeID {
            activeResourceNodes.removeAll { $0.id == oldID }
        }

        // 3. DYNAMICALLY CHOOSE A RELEVANT RESOURCE TIER
        // First, find the player's highest gathering skill level.
        let highestGatheringLevel = [
            getLevel(for: .mining),
            getLevel(for: .woodcutting),
            getLevel(for: .foraging),
            getLevel(for: .hunting)
        ].max() ?? 1
        
        // Then, map that level to the highest resource tier they can gather.
        // This formula matches your progression: Level 20 -> T5, Level 25 -> T6, etc.
        // We add 1 because the formula (level/5) gives us the tier *requirement*, not the tier itself.
        let targetTier = (highestGatheringLevel / 5) + 1
        // Cap the tier at the max available in the game (T11)
        let finalTargetTier = min(targetTier, 11)

        // Create a pool of all non-track resources at that tier.
        let possibleDiscoveries = ResourceType.allCases.filter {
            $0.tier == finalTargetTier && !$0.isTrackType
        }
        
        guard let resourceToDiscover = possibleDiscoveries.randomElement() else {
            // This will now only fail if there are no resources defined for a given tier.
            print("WATCHTOWER ERROR: Could not find any resources of Tier \(finalTargetTier) to discover.")
            return (false, "The scouts couldn't find anything of interest today.")
        }
        
        // 4. Find a suitable spawn location (far away, to encourage a journey).
        let randomAngle = Double.random(in: 0...(2 * .pi))
        let randomDistance = Double.random(in: 1000...2000) // 1-2 km away
        
        // Latitude is the North/South (Y) axis, which corresponds to sin.
        let latOffset = (randomDistance * sin(randomAngle)) / 111000.0
        // Longitude is the East/West (X) axis, which corresponds to cos.
        let lonOffset = (randomDistance * cos(randomAngle)) / (111000.0 * cos(playerLocation.coordinate.latitude * .pi / 180.0))
        let discoveryCoordinate = CLLocationCoordinate2D(
            latitude: playerLocation.coordinate.latitude + latOffset,
            longitude: playerLocation.coordinate.longitude + lonOffset
        )
        
        // 5. Create and spawn the special "Discovery" node.
        let discoveryNode = ResourceNode(type: resourceToDiscover, coordinate: discoveryCoordinate, isDiscovery: true)
        activeResourceNodes.append(discoveryNode)
        
        // 6. Update the game state.
        self.lastHorizonScanTime = Date()
        self.activeDiscoveryNodeID = discoveryNode.id
        
        // First, get the direction string from our new helper function.
        let directionString = direction(from: randomAngle)
        
        // Then, use that string in the final success message.
        return (true, "The Watchtower has spotted a Bountiful \(resourceToDiscover.displayName) to the \(directionString)!")
    }
    
    /// Converts a mathematical angle in radians into a user-friendly cardinal/intercardinal direction.
    /// Assumes 0 radians is East, PI/2 is North, etc.
    /// - Parameter angleInRadians: The angle to convert.
    /// - Returns: A string like "North", "South-West", etc.
    private func direction(from angleInRadians: Double) -> String {
        // 1. Convert radians to degrees (0-360)
        let degrees = angleInRadians * 180 / .pi
        let normalizedDegrees = (degrees + 360).truncatingRemainder(dividingBy: 360)

        // 2. Define the 8 directions and their slices (each slice is 45 degrees wide)
        // We add 22.5 degrees to the angle to shift the segments so that "East" is centered around 0.
        let directions = ["East", "North-East", "North", "North-West", "West", "South-West", "South", "South-East"]
        let index = Int((normalizedDegrees + 22.5) / 45) % 8
        
        return directions[index]
    }
}
