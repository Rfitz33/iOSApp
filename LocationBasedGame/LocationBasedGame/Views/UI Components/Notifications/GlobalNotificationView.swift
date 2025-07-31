//
//  GlobalNotificationView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/30/25.
//


// GlobalNotificationView.swift
import SwiftUI

struct GlobalNotificationView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var onDismiss: () -> Void
    
    var body: some View {
        // We only want the view to exist if there's something to show
        if notificationManager.feedbackEvent != nil || notificationManager.questProgressEvent != nil {
            // --- THIS VSTACK IS THE KEY TO TOP ALIGNMENT ---
            VStack {
                // This is the container for the actual banner content
                ZStack(alignment: .top) {
                    // Feedback Toast
                    if let event = notificationManager.feedbackEvent {
                        // --- APPLY THE CORRECT STYLING HERE ---
                        Text(event.message)
                            .font(.callout.weight(.medium))
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(event.isPositive ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                            .foregroundColor(.white).cornerRadius(10)
                            .shadow(radius: 5)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Quest Progress Banner
                    if let event = notificationManager.questProgressEvent {
                        QuestProgressBannerView(event: event)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                // Add padding to push it down from the notch/island
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top)
                
                Spacer() // This pushes the ZStack to the top of the screen
            }
            .onTapGesture {
                onDismiss()
            }
        }
    }
}
