//
//  LocationBasedGameApp.swift
//  LocationBasedGame
//
//  Created by Reid on 5/30/25.
//

import SwiftUI

@main
struct LocationBasedGameApp: App {
    @StateObject private var gameManager = GameManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // --- 2. ADD THE .onAppear MODIFIER HERE ---
                .onAppear {
                    // This is the correct, safe place to perform the setup.
                    NotificationManager.shared.setup(with: gameManager)
                }
            }
        }
    }

//@main
//struct LocationBasedGameApp: App {
//    // We can observe the GameManager here to listen for events.
//    @StateObject private var gameManager = GameManager.shared
//    
//    // State for the banner now lives at the top level of the app.
//    @State private var questProgressEvent: QuestProgressEvent? = nil
//    @State private var questBannerTimer: Timer? = nil
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                // --- NEW: Global Overlay for the banner ---
//                .overlay(alignment: .top) {
//                    if let event = questProgressEvent {
//                        QuestProgressBannerView(event: event)
//                            .padding(.top, 60)
//                            .onTapGesture {
//                                withAnimation {
//                                    questProgressEvent = nil
//                                    questBannerTimer?.invalidate()
//                                }
//                            }
//                            .transition(.move(edge: .top).combined(with: .opacity))
//                    }
//                }
//                // --- NEW: The listener now lives here ---
//                .onReceive(gameManager.questProgressPublisher) { event in
//                    questBannerTimer?.invalidate()
//                    withAnimation(.spring()) {
//                        questProgressEvent = event
//                    }
//                    questBannerTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
//                        withAnimation(.easeInOut) {
//                            questProgressEvent = nil
//                        }
//                    }
//                }
//        }
//    }
//}
