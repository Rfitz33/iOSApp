//
//  TopHUDView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/26/25.
//


// TopHUDView.swift
import SwiftUI

struct TopHUDView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var cameraTrackingMode: CameraTrackingMode
    var onPlayerButtonTap: () -> Void
    var onHomeButtonTap: () -> Void
    
    var body: some View {
        HStack {
            // --- Left Section (takes up 1/3 of the space) ---
            VStack(alignment: .leading) {
                Text("Total Level: \(gameManager.totalPlayerLevel)")
                Text("Total XP: \(gameManager.totalPlayerXP.formatted())")
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            
            Spacer()
            
            // --- Center Section (takes up 1/3 of the space) ---
            // We only show this if a pet is active.
            if let pet = gameManager.activeCreature {
                Image("\(pet.type.rawValue)_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40) // Make it a bit larger for emphasis
                    .shadow(radius: 3)
            }
            
            Spacer()
            
            // --- Right Section (takes up 1/3 of the space) ---
            HStack(spacing: 12) {
                // We use an empty spacer as a placeholder if the home base doesn't exist yet,
                // to keep the player button aligned correctly.
                if gameManager.homeBase == nil {
                    Spacer().frame(width: 44) // Match the button size
                }
                
                Button(action: onPlayerButtonTap) {
                    Image("player_character")
                        .resizable().scaledToFit().frame(width: 32, height: 32)
                }
                .buttonStyle(MapControlButton(isActive: cameraTrackingMode == .player))
                
                if gameManager.homeBase != nil {
                    Button(action: onHomeButtonTap) {
                        Image("starterHome")
                            .resizable().scaledToFit().frame(width: 32, height: 32)
                    }
                    .buttonStyle(MapControlButton(isActive: cameraTrackingMode == .homeBase))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .allowsHitTesting(true)
    }
}
