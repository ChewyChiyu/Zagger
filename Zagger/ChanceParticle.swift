//
//  ChanceParticle.swift
//  Zagger
//
//  Created by Evan Chen on 7/14/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit

class ChanceParticle: SKSpriteNode{
    
    //MARK: Class that gives out a random particle which gives a good or bad effect when contacted
    
    var alreadyContacted: Bool = false
    var gameScene : GameScene!
    init(gameScene: GameScene){
        //based off circle texture for core
        super.init(texture: SKTexture(imageNamed: "Square"), color: UIColor.clear, size: SKTexture(imageNamed: "Square").size())
        
        //setting base scene
        self.gameScene = gameScene
        
        //setting scale to small
        super.setScale(0.5)
        
        //setting name
        super.name = "ChanceParticle"
        
        //setting z position
        super.zPosition = 2
        
        //add physicsBody, collisions enabled so it doesnt get stuck in a obstacle
        super.physicsBody = SKPhysicsBody(circleOfRadius: (self.texture?.size().width)!/2)
        super.physicsBody?.affectedByGravity = false
        super.physicsBody?.contactTestBitMask = UINT32_MAX
        super.physicsBody?.collisionBitMask = 0 // no collisions
        
        //setting position based on scene gamePlay
        let positionX = (arc4random_uniform(2)==1) ? -Int(arc4random_uniform(UInt32(gameScene.view!.bounds.width/2))) : Int(arc4random_uniform(UInt32(gameScene.view!.bounds.width/2)))
        //9500 is the formation constant
        let positionYMax = gameScene.numberOfFormation * 9500
        let positionY = Int(gameScene.gameCamera.position.y + CGFloat(arc4random_uniform(UInt32(positionYMax))))
        
        //setting master position
        self.position = CGPoint(x:positionX,y:positionY)
        
        //attaching particle
        let particle = SKEmitterNode(fileNamed: "ChanceParticle.sks")
        self.addChild(particle!)
    }
    
    func contactedWithSnake(){
        if(!alreadyContacted){
            alreadyContacted = true
            
            //explode
            explode()
            
            //give chance to snake
            chanceToSnake()
        }
    }
    
    func explode(){
        self.removeAllChildren() // removing orgional particle node
        
        self.texture = nil // nil texture , bold square no longer needed
        
        let particleAfterEffect = SKEmitterNode(fileNamed: "ChanceParticleExploding.sks")
        particleAfterEffect?.targetNode = gameScene
        self.addChild(particleAfterEffect!)
        
        //removal after animation effect
        self.run(SKAction.wait(forDuration: 1), completion: { // 5 sec animation fade effect
            self.removeFromParent() // self removal
        })
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func chanceToSnake(){
     //MARK: Where the magic happens
        
        
        
        
        
    }
    
}
