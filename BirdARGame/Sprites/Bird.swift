//
//  Bird.swift
//  LyndaARGame
//
//  Created by Brian Advent on 24.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import SpriteKit
import GameplayKit

class Bird : SKSpriteNode {
 
    var mainSprite = SKSpriteNode()
    
    func setup(){
        
        mainSprite = SKSpriteNode(imageNamed: "bird1")
        self.addChild(mainSprite)
        
        let textureAtals = SKTextureAtlas(named: "bird")
        let frames = ["coin01", "coin02", "coin03", "coin04", "coin05", "coin06", "coin07","coin08","coin09","coin10"].map{textureAtals.textureNamed($0)}
        
        let atlasAnimation = SKAction.animate(with: frames, timePerFrame: 1/10, resize: true, restore: false)
        
        let animationAction = SKAction.repeatForever(atlasAnimation)
        mainSprite.run(animationAction)
        
        
        let left = GKRandomSource.sharedRandom().nextBool()
        if left {
            mainSprite.xScale = -1
        }
        
        let duration = randomNumber(lowerBound: 10, upperBound: 15)
        
        let fade = SKAction.fadeOut(withDuration: TimeInterval(duration))
        let removeBird = SKAction.run {
            NotificationCenter.default.post(name: Notification.Name("Spawn"), object: nil)
            self.removeFromParent()
        }
        
        let flySeqence = SKAction.sequence([fade, removeBird])
        
        mainSprite.run(flySeqence)
        
    }
    
}


