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
    
    private let desiredSize = CGSize(width: 64, height: 64)
    
    // The SpriteKit components
    private var skView: SKView!
    private var skScene: SKScene!
    private var playerNode: SKSpriteNode!
    
    // Pre-loaded actions for performance
    private var idleAction: SKAction!
    private var walkingAction: SKAction!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame.size = desiredSize
        self.canShowCallout = false
        self.backgroundColor = .clear
        self.collisionMode = .rectangle
        
        // --- Setup SKView (the SpriteKit renderer) ---
        skView = SKView(frame: CGRect(origin: .zero, size: desiredSize))
        skView.backgroundColor = .clear
        skView.allowsTransparency = true
        self.addSubview(skView)
        
        // --- Setup SKScene (the "world") ---
        skScene = SKScene(size: desiredSize)
        skScene.backgroundColor = .clear
        skScene.scaleMode = .aspectFit
        
        // --- Setup SKSpriteNode (our character) ---
        // Start with the idle texture
        let idleTexture = SKTexture(imageNamed: "player_image")
        playerNode = SKSpriteNode(texture: idleTexture)
        playerNode.size = desiredSize
        // Position the node in the center of the scene
        playerNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)
        skScene.addChild(playerNode)
        
        // --- Pre-load and create Animation Actions ---
        setupActions()
        
        // --- Present the scene ---
        skView.presentScene(skScene)
        
        // Set initial state
        setToIdle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActions() {
        // --- Idle Action ---
        // This simply shows the single idle texture.
        let idleTexture = SKTexture(imageNamed: "player_image")
        self.idleAction = .setTexture(idleTexture)
        
        // --- Walking Action ---
        var walkingTextures: [SKTexture] = []
        // Load frames from the texture atlas. The "walk_" prefix is from our naming convention.
        let atlas = SKTextureAtlas(named: "Player")
        let frameNames = atlas.textureNames.sorted() // e.g., ["walk_00", "walk_01", ...]
        
        for name in frameNames {
            walkingTextures.append(atlas.textureNamed(name))
        }
        
        if !walkingTextures.isEmpty {
            // Create an action that animates through the textures and repeats forever.
            let animate = SKAction.animate(with: walkingTextures, timePerFrame: 1.0 / 15.0) // 10 FPS
            self.walkingAction = .repeatForever(animate)
        } else {
            // Failsafe: if walking frames fail to load, the walking action does nothing.
            self.walkingAction = .wait(forDuration: 1.0)
        }
    }

    // --- State Transition Functions ---
    // These now simply tell the player node which action to run.

    func setToIdle() {
        playerNode.removeAllActions()
        playerNode.run(self.idleAction)
    }

    func startWalkingAnimation() {
        // Prevent running the same action multiple times
        if playerNode.action(forKey: "walk") == nil {
            playerNode.removeAllActions()
            playerNode.run(self.walkingAction, withKey: "walk")
        }
    }
}
