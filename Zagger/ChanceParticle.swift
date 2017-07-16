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
    var goodChance : Bool = true
    var particle: SKEmitterNode!
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
        
        //add physicsBody, collisions enabled so it doesnt get stuck in a obstacle
        super.physicsBody = SKPhysicsBody(circleOfRadius: (self.texture?.size().width)!/2)
        super.physicsBody?.affectedByGravity = false
        super.physicsBody?.contactTestBitMask = UINT32_MAX
        super.physicsBody?.collisionBitMask = 0 // no collisions
        
        if(Information.info.mainColorWhite){
            self.color = UIColor.white
        }else{
            self.color = UIColor.black
        }
        
        self.colorBlendFactor = 1
        
        
        //setting position based on scene gamePlay
        let positionX = (arc4random_uniform(2)==1) ? -Int(arc4random_uniform(UInt32(gameScene.view!.bounds.width/2))) : Int(arc4random_uniform(UInt32(gameScene.view!.bounds.width/2)))
        //9500 is the formation constant
        let positionYMax = gameScene.numberOfFormation * 9500
        let positionY = Int(gameScene.gameCamera.position.y + CGFloat(arc4random_uniform(UInt32(positionYMax))))
        
        //setting master position
        self.position = CGPoint(x:positionX,y:positionY)
        
        //attaching particle
        particle = SKEmitterNode(fileNamed: "ChanceParticle.sks")
        self.addChild(particle!)
        
        //setting particle color
        
        if(Information.info.mainColorWhite){
            particle?.particleColor = UIColor.white
        }else{
            particle?.particleColor = UIColor.black
        }
        
        //so cant ignore color change
        particle?.particleColorBlendFactor = 1
        particle?.particleColorSequence = nil

        
        //setting good or bad chance
        goodChance = (arc4random_uniform(2)==1) ? true : false // 1 out of 2 chance of good
        
        
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
        particle.removeFromParent() // removing orgional particle node
        self.color = UIColor.clear
        
        self.texture = nil // nil texture , bold square no longer needed
        
        let particleAfterEffect = SKEmitterNode(fileNamed: "ChanceParticleExploding.sks")
        
        
        //setting particle target
        particleAfterEffect?.targetNode = gameScene
        
        //setting particle color if its good or bad
        
        
        let RED_COLOR = UIColor(colorLiteralRed: 223/255, green: 58/255, blue: 25/255, alpha: 1)
        let GREEN_COLOR = UIColor(colorLiteralRed: 50/255, green: 245/255, blue: 189/255, alpha: 1)
        
        self.addChild(particleAfterEffect!)
        
        if(goodChance){
            particleAfterEffect?.particleColor = GREEN_COLOR
        }else{
            particleAfterEffect?.particleColor = RED_COLOR
        }
        
        //so cant ignore color change
        particleAfterEffect?.particleColorBlendFactor = 1
        particleAfterEffect?.particleColorSequence = nil
        
        
        //removal after animation effect
        self.run(SKAction.wait(forDuration: 1), completion: { // 1 sec animation fade effect
            self.removeFromParent() // self removal
        })
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func chanceToSnake(){
        //MARK: Where the magic happens
        if(goodChance){
            //apply good effect if possible
            applyGoodEffect()
            //play sound
            Information.info.playGoodChanceSound(scene: gameScene)
        }else{
            //apply bad effect if possible
            applyBadEffect()
            //play sound
            Information.info.playBadChanceSound(scene: gameScene)
        }
        
        
        
    }
    
    func applyGoodEffect(){
        switch(arc4random_uniform(2)){
        case 0:
            //make snake skinner by 10% if width is greater than 30 pixels
            if(gameScene.snake.size.width > 30){
                gameScene.snake.size.width *= 0.9
                gameScene.particle.particleScale *= 0.9
            }
            break
        case 1:
            //make snake slower if speed impulse is greater than 50
            if(gameScene.snakeImpulseContstant > 50){
                gameScene.snakeImpulseContstant -= 10
            }
            break
        default:
            break
        }
    }
    func applyBadEffect(){
        switch(arc4random_uniform(3)){
        case 0:
            //make snake larger by 10% if width is less than 150 pixels
            if(gameScene.snake.size.width < 150 ){
                gameScene.snake.size.width *= 1.1
                gameScene.particle.particleScale *= 1.1
            }
            break
        case 1:
            //make snake faster is snake impulse constant is less than 140
            if(gameScene.snakeImpulseContstant < 140){
                gameScene.snakeImpulseContstant += 10
            }
            break
        case 2:
            //make screen shake for 10 seconds
            gameScene.shakeCamera(layer: gameScene.currentFormation, duration: 10, ampX: 120, ampY: 40)
            gameScene.shakeCamera(layer:  gameScene.nextFormation, duration: 10, ampX: 120, ampY: 40)
            gameScene.shakeCamera(layer:  gameScene.particle, duration: 10, ampX: 120, ampY: 40)
            break
        default:
            break
        }
    }
    
    
    
}
