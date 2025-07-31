//
//  QuestProgressBannerView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// QuestProgressBannerView.swift
import SwiftUI

struct QuestProgressBannerView: View {
    let event: QuestProgressEvent
    
    // Format the objective key for display
    private var objectiveTitle: String {
        event.objectiveKey.capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    // --- A clamped version of the progress for the UI ---
    private var clampedProgress: Int {
        min(event.currentProgress, event.requiredAmount)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Quest Progress")
                .font(.headline)
                .foregroundColor(.yellow)
            
            Text(event.questTitle)
                .font(.subheadline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(objectiveTitle): \(event.currentProgress) / \(event.requiredAmount)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                ProgressView(value: Double(event.currentProgress), total: Double(event.requiredAmount))
                    .tint(.yellow)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
