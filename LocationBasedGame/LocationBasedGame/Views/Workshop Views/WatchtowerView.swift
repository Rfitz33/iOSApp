//
//  WatchtowerView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

import SwiftUI

struct WatchtowerView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager // Needed for the scan
    @Environment(\.dismiss) var dismiss
    
    // Timer to keep the cooldown text live
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    
    // Helper to calculate if the scan is on cooldown
    private var isScanOnCooldown: Bool {
        if let lastScan = gameManager.lastHorizonScanTime {
            return Date().timeIntervalSince(lastScan) < gameManager.watchtowerScanCooldown
        }
        return false
    }
    
    // Helper to format the remaining cooldown time
    private var remainingCooldown: String {
        guard let lastScan = gameManager.lastHorizonScanTime else { return "Ready" }
        
        let remaining = gameManager.watchtowerScanCooldown - Date().timeIntervalSince(lastScan)
        if remaining <= 0 { return "Ready" }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        
        return String(format: "%02dh %02dm remaining", hours, minutes)
    }
    
    var body: some View {
        NavigationView {
            // The main layout VStack. Its body is now very simple.
            VStack(spacing: 20) {
                headerSection
                Divider()
                scanSection
                Spacer() // Pushes content to the top
            }
            .padding()
            .background(
                Image("watchtower_background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.4))
            )
            .navigationTitle("Watchtower")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onReceive(timer) { newTime in
            self.currentTime = newTime
        }
    }
    
    // --- Computed Properties to break up the body ---
    
    @ViewBuilder
    private var headerSection: some View {
        Image("watchtower_icon")
            .resizable()
            .scaledToFit()
            .frame(height: 120)
        
        Text("Watchtower")
            .font(.largeTitle.bold())
        
        Text("Survey the surrounding lands to uncover hidden bounties.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    @ViewBuilder
    private var scanSection: some View {
        VStack {
            Text("Horizon Scan")
                .font(.title2.weight(.semibold))
            
            if let discoveryID = gameManager.activeDiscoveryNodeID,
               let discoveryNode = gameManager.activeResourceNodes.first(where: { $0.id == discoveryID }) {
                
                Text("A Bountiful \(discoveryNode.type.displayName) is active on your map!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
            } else {
                Button {
                    guard let playerLocation = locationManager.userLocation else {
                        gameManager.feedbackPublisher.send(.init(message: "Cannot determine your location to scan.", isPositive: false))
                        return
                    }
                    let result = gameManager.performHorizonScan(playerLocation: playerLocation)
                    gameManager.feedbackPublisher.send(.init(message: result.message, isPositive: result.success))
                    gameManager.logMessage(result.message, type: result.success ? .success : .failure)
                    if result.success {
                        dismiss()
                    }
                } label: {
                    Text("Scan the Horizon")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(isScanOnCooldown)
                
                Text(remainingCooldown)
                    .font(.caption)
                    .foregroundColor(isScanOnCooldown ? .orange : .secondary)
            }
        }
    }
}
