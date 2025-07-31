//
//  NotificationManager.swift
//  LocationBasedGame
//
//  Created by Reid on 7/30/25.
//


// In NotificationManager.swift
import SwiftUI
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var questProgressEvent: QuestProgressEvent? = nil
    @Published var feedbackEvent: FeedbackEvent? = nil
    
    private var notificationWindow: UIWindow?
    private var timer: Timer?
    
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func setup(with gameManager: GameManager) {
        gameManager.feedbackPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in self?.showNotification(feedback: event, quest: nil) }
            .store(in: &cancellables)
            
        gameManager.questProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in self?.showNotification(feedback: nil, quest: event) }
            .store(in: &cancellables)
    }
    
    private func showNotification(feedback: FeedbackEvent?, quest: QuestProgressEvent?) {
        // --- TIMER FIX: Invalidate any existing timer immediately ---
        timer?.invalidate()
        
        // If a window already exists, just update its content
        if notificationWindow != nil {
            self.feedbackEvent = feedback
            self.questProgressEvent = quest
        } else {
            // Otherwise, create the window
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            let notificationView = GlobalNotificationView { [weak self] in
                self?.dismissNotification()
            }
            
            let hostingController = UIHostingController(rootView: notificationView)
            hostingController.view.backgroundColor = .clear
            
            let window = PassthroughWindow(windowScene: scene)
            window.rootViewController = hostingController
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            window.makeKeyAndVisible()
            self.notificationWindow = window
            
            // Set the content *after* the window is created
            self.feedbackEvent = feedback
            self.questProgressEvent = quest
        }
        
        // --- TIMER FIX: Schedule the new timer AFTER showing the notification ---
        self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            self?.dismissNotification()
        }
    }
    
    func dismissNotification() {
        guard notificationWindow != nil else { return }
        
        timer?.invalidate()
        timer = nil

        // --- ANIMATION FIX ---
        // Animate the content disappearing first
        withAnimation(.easeOut(duration: 0.3)) {
            self.feedbackEvent = nil
            self.questProgressEvent = nil
        }
        
        // After the content has faded out, remove the window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.notificationWindow?.isHidden = true
            self.notificationWindow = nil
        }
    }
}

/// A custom UIWindow that allows touches to pass through its empty areas.
private class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Perform the standard hit test to find the view at the touch point.
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        
        // If the view that was hit is the window's root view (our transparent background),
        // then ignore the touch and let it pass through to the window below (the main game).
        // Otherwise, if a real view (like a button or text) was hit, handle the touch.
        return rootViewController?.view == hitView ? nil : hitView
    }
}
