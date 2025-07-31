//import SwiftUI
//import Combine
//import MapKit
//
//struct MainGameOverlayView: View {
//    @ObservedObject var gameManager: GameManager
//    @ObservedObject var locationManager: LocationManager
//    
//    @Binding var cameraTrackingMode: CameraTrackingMode 
//    @Binding var showingSetHomeBaseSheet: Bool
//    @Binding var showingHomeBaseViewAsFullScreen: Bool
//    @Binding var showingMenuView: Bool
//    
//    var onPlayerButtonTap: () -> Void
//    var onHomeButtonTap: () -> Void
//    // STATE FOR LEVEL UP NOTIFICATION
//    @State private var levelUpEventToShow: LevelUpEvent? = nil
//    @State private var levelUpTimer: Timer? = nil
//    
//    let topSafeAreaInset: CGFloat = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0
//    let bottomSafeAreaInset: CGFloat = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.bottom ?? 0
//
//    // Assumes MapControlButton.swift exists and is accessible
//    // Assumes RoundedCorner.swift exists and is accessible (or defined globally)
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) { // Main overlay container
//                // Top Bar (Map Controls)
//                HStack {
//                    Spacer()
//                    // The "Track Player" button is always visible.
//                        Button(action: onPlayerButtonTap) {
//                            Image("player_character") // Use your character's asset name
//                                .resizable() // Important for custom images
//                                .scaledToFit()
//                                .frame(width: 24, height: 24) // Adjust size as needed
//                                .foregroundColor(cameraTrackingMode == .player ? .white : .primary)
//                            }
//                            .buttonStyle(MapControlButton(isActive: cameraTrackingMode == .player))
//
//                        // The "Go to Home" button is only visible if a base exists.
//                        if gameManager.homeBase != nil {
//                            Button(action: onHomeButtonTap) {
//                                Image("starterHome") // Use your Sanctum's asset name
//                                    .resizable() // Important for custom images
//                                    .scaledToFit()
//                                    .frame(width: 24, height: 24) // Adjust size as needed
//                                    .foregroundColor(cameraTrackingMode == .homeBase ? .white : .primary)
//                            }
//                            .buttonStyle(MapControlButton(isActive: cameraTrackingMode == .homeBase))
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, topSafeAreaInset + 5)
//                    
//                    Spacer()
//                
//                // Bottom Bar
//                VStack(spacing: 15) {
//                    // Action Buttons
//                    HStack(spacing: 20) {
//                        Spacer()
//                        if gameManager.homeBase == nil && !showingSetHomeBaseSheet {
//                            Button("Establish Sanctum") { showingSetHomeBaseSheet = true }
//                                .buttonStyle(.borderedProminent).controlSize(.large)
//                        } else if gameManager.isPlayerNearHomeBase {
//                            Button { showingHomeBaseViewAsFullScreen = true } label: {
//                                Label("Enter Sanctum", systemImage: "figure.walk.arrival")
//                            }
//                            .buttonStyle(.borderedProminent).tint(.green).controlSize(.large)
//                        }
//                        
//                        let menuButtonLabel = Label("Menu", systemImage: "list.bullet")
//                        let useBorderedStyleForMenu = (gameManager.homeBase == nil && !showingSetHomeBaseSheet) || gameManager.isPlayerNearHomeBase
//                        if useBorderedStyleForMenu {
//                            Button { showingMenuView = true } label: { menuButtonLabel }
//                                .buttonStyle(.bordered).controlSize(.large)
//                        } else {
//                            Button { showingMenuView = true } label: { menuButtonLabel }
//                                .buttonStyle(.borderedProminent).controlSize(.large)
//                        }
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, bottomSafeAreaInset + 10)
//                .background(.ultraThinMaterial.opacity(0.85))
//                .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
//                }
//                .allowsHitTesting(true) // Ensure the main UI is tappable
//                // --- LEVEL UP NOTIFICATION OVERLAY ---
//                if let event = levelUpEventToShow {
//                    LevelUpView(event: event)
//                        .allowsHitTesting(false) // The level up notification itself should not be tappable
//                        // The LevelUpView will handle its own appear animation.
//                        // This ZStack ensures it's centered.
//                    }
//                }
//                .onReceive(gameManager.levelUpPublisher) { event in
//                    // When a level up event is received...
//                    levelUpTimer?.invalidate() // Invalidate any previous timer
//                    levelUpEventToShow = event // Set the event to show the view
//                    // ALSO construct a message and send it to the history log (NEW logic)
//                    let message = "Leveled up! \(event.skill.displayName) is now level \(event.newLevel)."
//                    gameManager.logMessage(message, type: .rare) // Level ups are exciting!
//                    // Start a new timer to hide the view after a few seconds
//                    levelUpTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
//                        withAnimation(.easeOut(duration: 0.5)) {
//                            levelUpEventToShow = nil
//                        }
//                    }
//                }
//                .onDisappear {
//                    // Also invalidate timer if this view disappears
//                    levelUpTimer?.invalidate()
//                    levelUpTimer = nil
//                }
//                
//            }
//        private func toggleCameraMode() {
//            // This function defines the explicit cycle: Player -> HomeBase -> Player
//            switch cameraTrackingMode {
//            case .player:
//                cameraTrackingMode = .homeBase
//            case .homeBase, .none:
//                cameraTrackingMode = .player
//            }
//        }
//
//        private func getButtonIconName() -> String {
//            // This function now returns the icon representing the CURRENT state.
//            switch cameraTrackingMode {
//            case .player:
//                return "location.fill" // We are tracking the player
//            case .homeBase:
//                return "house.fill" // We are tracking the house
//            case .none:
//                return "hand.draw.fill" // The user is in manual control
//            }
//        }
//    }
