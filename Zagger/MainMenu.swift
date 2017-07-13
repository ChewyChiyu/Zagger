//
//  MainMenu.swift
//  Zagger
//
//  Created by Evan Chen on 7/13/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MainMenu : SKScene{
    
    var titleBlock: SKSpriteNode!
    var audioBlock: Button!
    var leaderboardBlock: Button!
    var shopBlock: Button!
    
    var animationBool : Bool = false
    
    //MARK: This class handles the animation and actions of the mainMenu
    
    func assignVars(){
        //setting vars
        titleBlock = self.childNode(withName: "TitleBlock") as? SKSpriteNode
        audioBlock = self.childNode(withName: "AudioBlock") as? Button
        leaderboardBlock = self.childNode(withName: "LeaderboardBlock") as? Button
        shopBlock = self.childNode(withName: "ShopBlock") as? Button
    }
    
    func animateOnScene(scene: GameScene){
        //remove from current scene
        titleBlock.removeFromParent()
        audioBlock.removeFromParent()
        leaderboardBlock.removeFromParent()
        shopBlock.removeFromParent()
        //attach to scene
        scene.addChild(titleBlock)
        scene.addChild(audioBlock)
        scene.addChild(leaderboardBlock)
        scene.addChild(shopBlock)
        
        //move sprites off screen // 1500 pixels
        titleBlock.position.x -= 1500
        audioBlock.position.x -= 1500
        leaderboardBlock.position.x -= 1500
        shopBlock.position.x -= 1500
        
        //load audio information from save
        audioBlock.childNode(withName: "AudioOn")?.alpha = (Information.info.soundOn) ? 1 : 0
        
        
        //move sprites with time delay for animation effect in order from top to bottom
        titleBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.2), completion: {
            self.audioBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.2), completion: {
                self.leaderboardBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.2), completion: {
                    self.shopBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.2), completion: {
                        //assign actions to ndoes
                        self.assignActions(scene: scene)
                        self.animationBool = true // animation has completed
                    })
                })
            })
        })
    }
    
    func assignActions(scene: GameScene){
        //handling audio vars
        audioBlock.playAction = {
            let audioOnNode = self.audioBlock.childNode(withName: "AudioOn") as? SKSpriteNode
            audioOnNode?.alpha = (audioOnNode?.alpha==1) ? 0 : 1
            Information.info.soundOn = (audioOnNode?.alpha==1) ? true : false
        }
        
    }
    
    func animateOffScene(andOnCompletion completion:@escaping ()->()){
        titleBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: {
            self.titleBlock.removeFromParent()
            self.audioBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: {
                self.audioBlock.removeFromParent()
                self.leaderboardBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: {
                    self.leaderboardBlock.removeFromParent()
                    self.shopBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: {
                        self.shopBlock.removeFromParent()
                        //animations have finished
                        completion()
                    })
                })
            })
        })
    }
    
    
}

