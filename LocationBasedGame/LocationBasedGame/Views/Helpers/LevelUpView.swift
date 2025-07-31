//
//  LevelUpView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/15/25.
//


import SwiftUI

// MARK: - LevelUpView
struct LevelUpView: View {
    let event: LevelUpEvent // The data for which skill leveled up

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack(spacing: 10) {
            Text("LEVEL UP!")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.yellow)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 3)

            HStack(spacing: 10) {
                // Assume SkillType has an icon property, or use a placeholder
                // Let's add one for this purpose.
                Image(event.skill.iconAssetName) // Use the custom asset name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40) // Adjust size as needed for the LevelUpView
                
                Text("\(event.skill.displayName) reached Level \(event.newLevel)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial) // or custom background asset
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow, lineWidth: 3)
        )
        .shadow(radius: 10)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            // Optional: Haptic feedback for level up
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// Add an icon property to SkillType for this view
// Add this inside the SkillType enum in GameSkills.swift
/*
    var iconSystemName: String {
        switch self {
        case .mining: return "pickaxe.fill"
        case .woodcutting: return "axe" // Using SF Symbol "figure.fishing" or a placeholder
        case .foraging: return "leaf.fill"
        case .hunting: return "pawprint.fill"
        case .leatherworking: return "scissors" // Or a placeholder
        // Add icons for other skills
        }
    }
*/

// Preview for LevelUpView
struct LevelUpView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock event for the preview
        let mockEvent = LevelUpEvent(skill: .mining, newLevel: 5)
        
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all) // Background for context
            LevelUpView(event: mockEvent)
        }
    }
}
