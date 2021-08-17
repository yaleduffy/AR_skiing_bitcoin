//
//  GameScene.swift
//  LyndaARGame
//
//  Created by Brian Advent on 22.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class GameScene: SKScene {
    
    var numberOfBirds = 10
    var timerLabel:SKLabelNode!
    var counterLabel:SKLabelNode!
    // x is the left right position of the coin (phone camera on right side orientation)
    var x:Float = 0
    // y is the height of the coin (phone camera on right side orientation)
    var y:Float = 0
    // z is how far away the coin is from the device  (phone camera on right side orientation)
    var z:Float = -4
    
    var remainingTime:Int = 90 {
        didSet{
            timerLabel.text = "\(remainingTime) sec"
        }
    }
    
    var score:Int = 0{
        didSet{
            counterLabel.text = "\(score) Bitcoins"
        }
    }
    

    static var gameState:GameState = .none
    
    
    //set up the timer label and counterlabels and their positions
    func setupHUD() {
        timerLabel = self.childNode(withName: "timerLabel") as! SKLabelNode
        counterLabel = self.childNode(withName: "counterLabel") as! SKLabelNode
        
        timerLabel.position = CGPoint(x: (self.size.width / 2) - 70, y: (self.size.height / 2) - 90 )
        counterLabel.position = CGPoint(x: -(self.size.width / 2) + 70, y: (self.size.height / 2) - 90 )
        
        let wait = SKAction.wait(forDuration:1)
        let action = SKAction.run {
            self.remainingTime -= 1
        }
        
        let timerAction = SKAction.sequence([wait,action])
        self.run(SKAction.repeatForever(timerAction))
        
        
    }
    
    
    /*<-----------------------------Gameover function---------------------------->*/
    func gameOver(){
        let reveal = SKTransition.crossFade(withDuration: 0.9)
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let mainMenu = MainMenuScene(fileNamed: "MainMenuScene") {
            
            sceneView.presentScene(mainMenu,
                                   transition: reveal)
        }
    }
    /*<--------------------------------------------------------------------------->*/
    
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.spwanski), name: Notification.Name("Spawn"), object: nil)
        
        setupHUD()
        
        let waitAction = SKAction.wait(forDuration: 0.5)
        let spwanAction = SKAction.run {
            self.performInitialSpwan()
        }
        
        self.run(SKAction.sequence([waitAction, spwanAction]))
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        
        //when remaining game time hits 0
        if remainingTime == 0 {
            
            //all actions stops
            self.removeAllActions()
            
            //execute game over function
            gameOver()
        }
        
        //create wait 1 second action
        let wait = SKAction.wait(forDuration: 1)
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        if let cameraZ = sceneView.session.currentFrame?.camera.transform.columns.3.z {
            for node in nodes(at: CGPoint.zero) {
                if let bird = node as? Bird {
                    
                    guard let anchors = sceneView.session.currentFrame?.anchors else {return}
                    
                    //check anchor's position relates to camera
                    for anchor in anchors {
                        if abs(cameraZ - anchor.transform.columns.3.z) < 0.3 {
                            if let potentialTargetBird = sceneView.node(for: anchor) {
                                if bird == potentialTargetBird {
                                    bird.removeFromParent()
                                    for _ in 1 ... 3{
                                    spwanski(x: x, y: y, z: z)
                                    score += 1
                                    // y is the height of the coin
                                    y-=0.1
                                    // z is how far away the coin is from the phone
                                    z-=1
                                    // x is how far left or right the coin is from device
                                    if(x<3){
                                        x+=1.5
                                    }else{
                                        x-=1.5
                                    }
                                    }
                                }
                            }
                        }
                        
                    }
                
                }
            }
        }
        
    }
    
    /*<--------------------------Bird initial spwan function------------------------->*/
    func performInitialSpwan() {
        var x:Float = 0, y:Float=0, z:Float=0;
        GameScene.gameState = .spwanBirds
        
        for _ in 1 ... 3{
            z-=1.5
            spwanski(x: x, y: y, z: z)
            
            if(x<3){
                x+=0.3
            }else{
                x-=0.3
            }
        }
    }
    /*<------------------------------------------------------------------------------->*/
    
    /*<--------------------------------bird spwan function---------------------------->*/
    //positions of where the bird will spawn
    @objc func spwanBird() {
        
        
        var x_p = 0, y_p = 0, z_p = 0;
        
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            
            //translation.columns.3.x = randomPosition(lowerBound: -0.2, upperBound:0.2)
            translation.columns.3.x = randomPosition(lowerBound: -0.2, upperBound:0.2)
            translation.columns.3.y = Float(y_p)+0.05
            //translation.columns.3.z = Float(y_p)+0.1
            //translation.columns.3.z = randomPosition(lowerBound: -0.7, upperBound: 0.7)
            translation.columns.3.z = Float(z_p)-randomPosition(lowerBound: 1, upperBound: 2)
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
        }
        
    }
    /*<------------------------------------------------------------------------------->*/
    @objc func spwanski(x:Float,y:Float,z:Float) {
        
        
       
        
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            
            //translation.columns.3.x = randomPosition(lowerBound: -0.2, upperBound:0.2)
            translation.columns.3.x = x
            translation.columns.3.y = y
            //translation.columns.3.z = Float(y_p)+0.1
            //translation.columns.3.z = randomPosition(lowerBound: -0.7, upperBound: 0.7)
            translation.columns.3.z = z
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
        }
        
    }
}


