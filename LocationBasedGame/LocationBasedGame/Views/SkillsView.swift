//
//  SkillsView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/10/25.
//
//
//
//import SwiftUI
//
//// MARK: - SkillsView
//struct SkillsView: View {
//    @ObservedObject var gameManager: GameManager
//
//    var body: some View {
//        List {
//            ForEach(SkillType.allCases.sorted(by: { $0.displayName < $1.displayName }), id: \.self) { skill in
//                Section(header:
//                    HStack {
//                        Image(skill.iconAssetName) // Your custom skill icon
//                            .resizable().scaledToFit().frame(width: 40, height: 40)
//                        Text(skill.displayName).font(.title2)
//                    }
//                ) {
//                    SkillDisplayView(gameManager: gameManager, skillType: skill) // Existing XP bar
//
//                    // --- Unlocks Display ---
//                    let currentLevel = gameManager.getLevel(for: skill)
//                    let unlocks = skill.levelUnlocks.sorted(by: { $0.levelRequired < $1.levelRequired })
//                    
//                    // Unlocked at Current Level (or below)
//                    let achievedUnlocks = unlocks.filter { $0.levelRequired <= currentLevel }
//                    if !achievedUnlocks.isEmpty {
//                        Text("Current Level \(currentLevel) Benefits & Recent Unlocks:")
//                            .font(.subheadline.weight(.semibold))
//                            .padding(.top, 5)
//                        ForEach(achievedUnlocks.filter { $0.levelRequired == currentLevel || $0.isMajorUnlock && $0.levelRequired < currentLevel }.suffix(3).reversed()) { unlock in // Show last 3 major or current level
//                            UnlockRowView(unlock: unlock, isAchieved: true)
//                        }
//                    }
//
//                    // Upcoming Unlocks
//                    if let nextMajorUnlock = unlocks.first(where: { $0.levelRequired > currentLevel && $0.isMajorUnlock }) {
//                        Text("Next Major Unlock at Level \(nextMajorUnlock.levelRequired):")
//                            .font(.subheadline.weight(.semibold))
//                            .padding(.top, 8)
//                        UnlockRowView(unlock: nextMajorUnlock, isAchieved: false)
//                    } else if let nextUnlock = unlocks.first(where: { $0.levelRequired > currentLevel }) {
//                         Text("Next Unlock at Level \(nextUnlock.levelRequired):")
//                            .font(.subheadline.weight(.semibold))
//                            .padding(.top, 8)
//                        UnlockRowView(unlock: nextUnlock, isAchieved: false)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Player Skills")
//        // .listStyle(GroupedListStyle()) // Or InsetGroupedListStyle
//    }
//}
//
//// Ensure SkillDisplayView is accessible (e.g., defined globally or in a common helper file)
//
//// Preview for SkillsView
//struct SkillsView_Previews: PreviewProvider {
//    class MockSkillsGameManager: GameManager {
//        override init() {
//            super.init()
//            self.playerSkillsXP = [.mining: 250, .woodcutting: 80, .foraging: 120, .hunting: 10, .leatherworking: 5]
//            self.updateAllSkillLevelsFromXP()
//        }
//    }
//    static var previews: some View {
//        NavigationView {
//            SkillsView(gameManager: MockSkillsGameManager())
//        }
//    }
//}
