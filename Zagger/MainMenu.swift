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
    var highscoreLabel: SKLabelNode!
    var animationBool : Bool = false
    
    //MARK: This class handles the animation and actions of the mainMenu
    var gameScene: GameScene!
    func start(scene: GameScene){
        //starting up menu
        self.gameScene = scene
        assignVars()
        //animate in scene
        animateOnScene()
        
    }
    
    
    func assignVars(){
        //setting vars
        
        titleBlock = self.childNode(withName: "TitleBlock") as? SKSpriteNode
        audioBlock = self.childNode(withName: "AudioBlock") as? Button
        leaderboardBlock = self.childNode(withName: "LeaderboardBlock") as? Button
        shopBlock = self.childNode(withName: "ShopBlock") as? Button
        highscoreLabel = titleBlock.childNode(withName: "Highscore") as? SKLabelNode
        highscoreLabel.text = "Best: \(Information.info.highscore)"
        
        
        
    }
    
    func animateOnScene(){
        //remove from current scene
        titleBlock.removeFromParent()
        audioBlock.removeFromParent()
        leaderboardBlock.removeFromParent()
        shopBlock.removeFromParent()
        //attach to scene
        gameScene.addChild(titleBlock)
        gameScene.addChild(audioBlock)
        gameScene.addChild(leaderboardBlock)
        gameScene.addChild(shopBlock)
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
                        self.animationBool = true // animation has completed
                        //assign actions
                        self.assignActions()
                    })
                })
            })
        })
    }
    
    func assignActions(){
        //handling audio vars
        audioBlock.playAction = {
            let audioOnNode = self.audioBlock.childNode(withName: "AudioOn") as? SKSpriteNode
            audioOnNode?.alpha = (audioOnNode?.alpha==1) ? 0 : 1
            Information.info.soundOn = (audioOnNode?.alpha==1) ? true : false
        }
        //highscore block
        leaderboardBlock.playAction = {
            //check leaderboard
            if(self.gameScene.gameViewController.gcEnabled){
                //if gamecenter is enabled send info 
                self.gameScene.gameViewController.addScoreAndSubmitToGC(score: Information.info.highscore)
            }
            self.gameScene.gameViewController.checkGCLeaderboard()
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

