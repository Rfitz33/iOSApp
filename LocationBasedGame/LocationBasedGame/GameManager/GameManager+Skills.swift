//
//  GameManager+Skills.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//

import Foundation

// A simple struct to hold the level-up event data
struct LevelUpEvent {
    let skill: SkillType
    let newLevel: Int
}

struct QuestProgressEvent {
    let questTitle: String
    let objectiveKey: String
    let currentProgress: Int
    let requiredAmount: Int
}

// MARK: - Skills Logic
extension GameManager {
    // MARK: - Total Level and XP Calculation
        
        /// The player's total combined level from all skills.
        var totalPlayerLevel: Int {
            // We sum up all the values in the playerSkillLevels dictionary.
            // Since each skill starts at level 1, a brand new player's total level
            // will be the number of skills in the game.
            // Or, you could calculate it as (sum of levels) - (number of skills) + 1
            // to have a new player start at "Total Level 1". Let's go with the simple sum for now.
            playerSkillLevels.values.reduce(0, +)
        }
        
        /// The player's total combined experience points from all skills.
        var totalPlayerXP: Int {
            // We sum up all the XP values in the playerSkillsXP dictionary.
            playerSkillsXP.values.reduce(0, +)
        }
    
    func getXP(for skill: SkillType) -> Int {
        return playerSkillsXP[skill] ?? 0
    }

    func getLevel(for skill: SkillType) -> Int {
        return playerSkillLevels[skill] ?? 1 // Default to level 1
    }
    
    // Returns a tuple: (xpProgressInCurrentLevel, xpNeededForThisLevelBar)
    // Returns nil for the second value if level is maxed.
    func xpInfo(for skill: SkillType) -> (progress: Int, total: Int?) {
        let currentLevel = getLevel(for: skill)
        
        if currentLevel >= self.skillLevelCap {
            // Player is at max level, there is no "next level" bar.
            // We can return the total XP they have.
            return (getXP(for: skill), nil)
        }

        // XP needed to have started this current level
        let xpForCurrentLevelBase = (currentLevel - 1) * self.baseXpPerLevel
        // How much XP the player has accumulated *within* this level bar
        let xpProgressInCurrentLevel = getXP(for: skill) - xpForCurrentLevelBase
        // How much XP this entire level bar represents (from start of level to start of next)
        let xpNeededForThisLevelBar = self.baseXpPerLevel // In a simple linear system.
        // For a more complex exponential system, this would be: xpForLevel(currentLevel + 1) - xpForLevel(currentLevel)

        return (xpProgressInCurrentLevel, xpNeededForThisLevelBar)
    }

    func addXP(_ amount: Int, to skill: SkillType) {
        var finalXPAmount = Double(amount)

        // --- 1. Apply Specific Skill Bonus (e.g., from a ring) ---
        var specificBonus = 0.0
        switch skill {
        case .mining: specificBonus = activeStatBonuses[.miningXpBonus] ?? 0.0
        case .woodcutting: specificBonus = activeStatBonuses[.woodcuttingXpBonus] ?? 0.0
        case .foraging: specificBonus = activeStatBonuses[.foragingXpBonus] ?? 0.0
        // ... add cases for all other specific XP bonuses ...
        default: break
        }
        finalXPAmount *= (1.0 + specificBonus)
        
        // --- 2. Apply Global Bonus (e.g., from a necklace) ---
        let globalBonus = activeStatBonuses[.globalXpBonus] ?? 0.0
        finalXPAmount *= (1.0 + globalBonus)

        // --- 3. Apply DRAGON "Aura of Power" ABILITY ---
        if let activePet = self.activeCreature,
           activePet.type == .dragon,
           activePet.state == .trainedAdult {
            finalXPAmount *= 1.05 // Apply 5% bonus after all others
            print("DRAGON ABILITY: Aura of Power active, +5% XP.")
        }
        
        let currentXP = getXP(for: skill)
        let newXP = currentXP + Int(finalXPAmount.rounded())
        playerSkillsXP[skill] = newXP
        
        print("Gained \(Int(finalXPAmount.rounded())) XP for \(skill.displayName) (base: \(amount)). Total: \(newXP)")
        updateSkillLevel(for: skill)
    }

    private func updateSkillLevel(for skill: SkillType) {
        let currentXP = getXP(for: skill)
        let oldLevel = getLevel(for: skill) // Get level before calculation
        
        // Simple level calculation
        var newLevel = 1 + (currentXP / self.baseXpPerLevel)
        
        // APPLY LEVEL CAP
        if newLevel > self.skillLevelCap {
            newLevel = self.skillLevelCap
        }
        
        if oldLevel != newLevel {
            playerSkillLevels[skill] = newLevel
            let levelUpMessage = "\(skill.displayName) leveled up to Level \(newLevel)!"
            print(levelUpMessage)
            
            // Publish the level-up event
            let event = LevelUpEvent(skill: skill, newLevel: newLevel)
            levelUpPublisher.send(event) // Send the event to any subscribers
        }
    }
    
    func updateAllSkillLevelsFromXP() {
        for skill in SkillType.allCases {
            updateSkillLevel(for: skill)
        }
    }
}
