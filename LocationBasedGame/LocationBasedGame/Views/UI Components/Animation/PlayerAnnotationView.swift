//
//  PlayerAnnotationView.swift
//  LocationBasedGame
//
//  Created by Reid on 10/30/25.
//

import MapKit
import SpriteKit

class PlayerAnnotationView: MKAnnotationView {
    static let reuseID = "PlayerAnnotationView"
    
    private enum PlayerState {
        case idleFacingAway
        case idleFacingPlayer
        case playingTurn
        case playingExtendedIdle
        case walking
    }
    
    private let desiredSize = CGSize(width: 64, height: 64)
    
    private var skView: SKView!
    private var skScene: SKScene! // This was missing from the class properties
    private var playerNode: SKSpriteNode!
    
    // Pre-loaded actions
    private var idleAwayAction: SKAction!
    private var idleFacingPlayerAction: SKAction!
    private var walkingAction: SKAction!
    private var turnAction: SKAction!
    private var extendedIdleActions: [SKAction] = []
    
    private var idleLoopTimer: Timer?
    private var lastPlayedIdleIndex: Int?
    private var currentState: PlayerState = .idleFacingPlayer

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame.size = desiredSize
        self.canShowCallout = false
        self.backgroundColor = .clear
        self.collisionMode = .rectangle
        
        // This tells the touch system to completely ignore this view.
        self.isUserInteractionEnabled = false
        
        setupSpriteKit()
        setupActions()
        
        // The scene is now presented from within setupSpriteKit,
        // so the problematic call is no longer here.
        
        setToIdle() // Start in the final idle state
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupSpriteKit() {
        skView = SKView(frame: CGRect(origin: .zero, size: desiredSize))
        skView.backgroundColor = .clear
        skView.allowsTransparency = true
        self.addSubview(skView)
        
        // We now assign to the class property `self.skScene` instead of creating a local variable.
        self.skScene = SKScene(size: desiredSize)
        self.skScene.backgroundColor = .clear
        self.skScene.scaleMode = .aspectFit
        
        playerNode = SKSpriteNode(texture: SKTexture(imageNamed: "player_image"))
        playerNode.size = desiredSize
        playerNode.position = CGPoint(x: self.skScene.size.width / 2, y: self.skScene.size.height / 2)
        self.skScene.addChild(playerNode)
        
        // --- CLEANUP: Present the scene as the final step of its setup ---
        skView.presentScene(self.skScene)
    }

    private func setupActions() {
        self.idleAwayAction = .setTexture(SKTexture(imageNamed: "player_idle_north"))
        self.idleFacingPlayerAction = .setTexture(SKTexture(imageNamed: "player_image"))
        
        let atlas = SKTextureAtlas(named: "Player")
        
        let walkFrames = atlas.textureNames.filter { $0.hasPrefix("walk_") }.sorted()
            .map { atlas.textureNamed($0) }
        if !walkFrames.isEmpty {
            self.walkingAction = .repeatForever(.animate(with: walkFrames, timePerFrame: 1.0 / 10.0))
        }
        
        let turnFrames = atlas.textureNames.filter { $0.hasPrefix("turn_") }.sorted()
            .map { atlas.textureNamed($0) }
        if !turnFrames.isEmpty {
            let animateTurn = SKAction.animate(with: turnFrames, timePerFrame: 1.0 / 24.0)
            self.turnAction = .sequence([animateTurn, .run { [weak self] in self?.transitionToIdleFacingPlayer() }])
        }
        
        let idle1Frames = atlas.textureNames.filter { $0.hasPrefix("idle_extended_") }.sorted()
            .map { atlas.textureNamed($0) }
        if !idle1Frames.isEmpty {
            let animate1 = SKAction.animate(with: idle1Frames, timePerFrame: 1.0 / 8.0)
            self.extendedIdleActions.append(.sequence([animate1, .run { [weak self] in self?.transitionToIdleFacingPlayer() }]))
        }
        
        let idle2Frames = atlas.textureNames.filter { $0.hasPrefix("idle_2_") }.sorted()
            .map { atlas.textureNamed($0) }
        if !idle2Frames.isEmpty {
            let animate2 = SKAction.animate(with: idle2Frames, timePerFrame: 1.0 / 8.0)
            self.extendedIdleActions.append(.sequence([animate2, .run { [weak self] in self?.transitionToIdleFacingPlayer() }]))
        }
    }

    // --- Public State Transition Functions ---
    func setToIdle() {
        // We only want to perform this transition if the character is currently walking.
        // If they are already in ANY idle state (.idleFacingAway, .idleFacingPlayer, etc.),
        // we do nothing and let the timers continue as they are.
        guard currentState == .walking else {
            return
        }
        
        // If we were walking, transition to the first idle phase.
        currentState = .idleFacingAway
        playerNode.removeAllActions()
        playerNode.run(self.idleAwayAction) // Show the "facing away" idle pose.
        
        // Invalidate any old timer and start the new one for the turn.
        idleLoopTimer?.invalidate()
        idleLoopTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.playTurnAnimation()
        }
    }

    func startWalkingAnimation() {
        // This function's logic is correct and does not need to change.
        guard currentState != .walking else { return }
        
        idleLoopTimer?.invalidate()
        idleLoopTimer = nil
        
        currentState = .walking
        playerNode.removeAllActions()
        playerNode.alpha = 1.0
        if let action = self.walkingAction {
            playerNode.run(action, withKey: "walk")
        }
    }
    
    // --- Internal State Management (Unchanged) ---
    private func playTurnAnimation() {
        guard currentState == .idleFacingAway, let turnAction = self.turnAction else { return }
        currentState = .playingTurn
        playerNode.run(turnAction, withKey: "turn")
    }
    
    private func transitionToIdleFacingPlayer() {
        guard currentState != .walking else { return }
        currentState = .idleFacingPlayer
        playerNode.run(self.idleFacingPlayerAction)
        
        idleLoopTimer?.invalidate()
        idleLoopTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.playNextExtendedIdleAnimation()
        }
    }
    
    private func playNextExtendedIdleAnimation() {
        guard currentState == .idleFacingPlayer, !extendedIdleActions.isEmpty else { return }
        currentState = .playingExtendedIdle
        
        var nextIndex: Int
        if extendedIdleActions.count == 1 {
            nextIndex = 0
        } else {
            nextIndex = Int.random(in: 0..<extendedIdleActions.count)
            while nextIndex == self.lastPlayedIdleIndex {
                nextIndex = Int.random(in: 0..<extendedIdleActions.count)
            }
        }
        
        self.lastPlayedIdleIndex = nextIndex
        let nextAnimation = extendedIdleActions[nextIndex]
        playerNode.run(nextAnimation, withKey: "extended_idle")
    }
}
