//
//  SkillsTabView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// SkillsTabView.swift
import SwiftUI

struct SkillsTabView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            // --- We are now using the List directly from SkillsView ---
            List {
                ForEach(SkillType.allCases.sorted(by: { $0.displayName < $1.displayName }), id: \.self) { skill in
                    Section(header:
                        HStack {
                            Image(skill.iconAssetName)
                                .resizable().scaledToFit().frame(width: 40, height: 40)
                            Text(skill.displayName).font(.title2)
                        }
                    ) {
                        SkillDisplayView(gameManager: gameManager, skillType: skill)

                        // --- Unlocks Display ---
                        let currentLevel = gameManager.getLevel(for: skill)
                        let unlocks = skill.levelUnlocks.sorted(by: { $0.levelRequired < $1.levelRequired })
                        
                        let achievedUnlocks = unlocks.filter { $0.levelRequired <= currentLevel }
                        if !achievedUnlocks.isEmpty {
                            Text("Current Level \(currentLevel) Benefits & Recent Unlocks:")
                                .font(.subheadline.weight(.semibold))
                                .padding(.top, 5)
                            ForEach(achievedUnlocks.filter { $0.levelRequired == currentLevel || $0.isMajorUnlock && $0.levelRequired < currentLevel }.suffix(3).reversed()) { unlock in
                                UnlockRowView(unlock: unlock, isAchieved: true)
                            }
                        }

                        if let nextMajorUnlock = unlocks.first(where: { $0.levelRequired > currentLevel && $0.isMajorUnlock }) {
                            Text("Next Major Unlock at Level \(nextMajorUnlock.levelRequired):")
                                .font(.subheadline.weight(.semibold))
                                .padding(.top, 8)
                            UnlockRowView(unlock: nextMajorUnlock, isAchieved: false)
                        } else if let nextUnlock = unlocks.first(where: { $0.levelRequired > currentLevel }) {
                             Text("Next Unlock at Level \(nextUnlock.levelRequired):")
                                .font(.subheadline.weight(.semibold))
                                .padding(.top, 8)
                            UnlockRowView(unlock: nextUnlock, isAchieved: false)
                        }
                    }
                }
            }
            // --- We still need the NavigationView modifiers ---
            .navigationTitle("Skills")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            // Making the list transparent so the menu background shows through
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationViewStyle(.stack)
    }
}
