//
//  Untitled.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//

import SwiftUI

// --- New Helper View for Displaying a Single Unlock ---
struct UnlockRowView: View {
    let unlock: SkillUnlock
    let isAchieved: Bool

    var body: some View {
        HStack(alignment: .top) {
            if let iconName = unlock.iconName {
                // Determine if it's an asset or system image based on your convention
                // For now, assume SF Symbol if it contains ".", else asset. Needs refinement.
                if iconName.contains(".") || iconName == "leaf.fill" || iconName == "hammer.fill" || iconName == "flame.fill" || iconName == "testtube.2" || iconName == "person.2.fill" || iconName == "archivebox.fill" || iconName == "sparkle" || iconName == "scope" || iconName == "atom" || iconName == "binoculars.fill" || iconName == "bird.fill" { // Simple check
                     Image(systemName: iconName)
                        .frame(width: 20, height: 20)
                        .foregroundColor(isAchieved ? (unlock.isMajorUnlock ? .yellow : .accentColor) : .gray)
                } else {
                    Image(iconName) // Assumes custom asset
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                }
            } else {
                Image(systemName: "circle.fill") // Default placeholder icon
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .foregroundColor(isAchieved ? (unlock.isMajorUnlock ? .yellow : .accentColor) : .gray)
            }
            VStack(alignment: .leading) {
                Text(unlock.description)
                    .font(.caption)
                    .fontWeight(unlock.isMajorUnlock && isAchieved ? .semibold : .regular)
                    .foregroundColor(isAchieved ? .primary : .secondary)
                if !isAchieved {
                    Text("(Requires Level \(unlock.levelRequired))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .opacity(isAchieved ? 1.0 : 0.7)
    }
}

struct SkillDisplayView: View {
    @ObservedObject var gameManager: GameManager
    let skillType: SkillType

    var body: some View {
        let currentLevel: Int = gameManager.getLevel(for: skillType)
                let levelCap: Int = gameManager.skillLevelCap
                let isAtMaxLevel: Bool = currentLevel >= levelCap
                let totalXP = gameManager.getXP(for: skillType)
                let xpInfo = gameManager.xpInfo(for: skillType)

                VStack(alignment: .leading) {
                    // --- Level Display ---
                    HStack {
                        Text("\(skillType.displayName) - Level \(currentLevel)")
                            .font(.headline)
                        
                        // Now use the pre-calculated boolean
                        if isAtMaxLevel {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .padding(.leading, -5)
                    Text("(MAX)")
                        .font(.caption.bold())
                        .foregroundColor(.yellow)
                }
            }

            // --- XP Display ---
            if let totalForBar = xpInfo.total { // Only show progress bar if not max level
                ProgressView(value: Float(xpInfo.progress), total: Float(totalForBar))
                    .tint(skillType.progressColor) // <<< USE THE PROGRESS COLOR
                    .padding(.top, 1)
                Text("XP: \(xpInfo.progress) / \(totalForBar)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else { // At max level, show total accumulated XP
                Text("Total XP: \(totalXP.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

// Optional: Add a progressColor to SkillType for visual differentiation
extension SkillType {
    var progressColor: Color {
        switch self {
        case .mining: return .gray
        case .smithing: return .init(white: 0.4)
        case .woodcutting: return .brown
        case .carpentry: return .init(hue: 0.12, saturation: 0.6, brightness: 0.5) // Woodish
        case .foraging: return .green
        case .herblore: return .init(hue: 0.2, saturation: 0.5, brightness: 0.6)
        case .hunting: return .orange
        case .leatherworking: return .init(hue: 0.1, saturation: 0.5, brightness: 0.6) // Earthy
        case .fletching: return .init(hue: 0.3, saturation: 0.5, brightness: 0.5)
        case .alchemy: return .init(hue: 0.33, saturation: 0.5, brightness: 0.5)
        case .jewelcrafting: return .init(hue: 0.28, saturation: 0.5, brightness: 0.5)
        // default: return .blue // For future skills
        }
    }
}
