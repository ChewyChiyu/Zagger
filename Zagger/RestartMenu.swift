//
//  RestartMenu.swift
//  Zagger
//
//  Created by Evan Chen on 7/14/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit

class RestartMenu : SKScene{
    
    var scoreBlock : SKSpriteNode!
    var restartBlock: Button!
    
    weak var gameScene: GameScene!
    
    func start(scene: GameScene){
        //starting reset menu
        gameScene = scene
        loadVars()
        animateRestart()
    }
    
    func loadVars(){
        scoreBlock = self.childNode(withName: "ScoreBlock") as? SKSpriteNode
        restartBlock = self.childNode(withName: "RestartBlock") as? Button
        
        //assign values
        let scoreLabel = scoreBlock.childNode(withName: "Score") as? SKLabelNode
        scoreLabel?.text = String(gameScene.score)
        
    }
    func animateRestart(){
        //removing from parent
        scoreBlock.removeFromParent()
        restartBlock.removeFromParent()
        
        //attach to scene
        gameScene.addChild(scoreBlock)
        gameScene.addChild(restartBlock)
        
        //move sprites up to restart location
        scoreBlock.position.y += gameScene.gameCamera.position.y
        restartBlock.position.y += gameScene.gameCamera.position.y
        
        //move sprites of screen, left 1500
        scoreBlock.position.x += 1500
        restartBlock.position.x += 1500
        
        //move sprites in top to bottom order
        scoreBlock.run(SKAction.moveBy(x: -1500, y: 0, duration: 0.2), completion: { [weak self] in
            self?.restartBlock.run(SKAction.moveBy(x: -1500, y: 0, duration: 0.2), completion: { [weak self] in
                //animation on has finished
                self?.assignActions()
            })
        })
    }
    func assignActions(){
        restartBlock.playAction = { [weak self] in
            guard let strongSelf = self else { return }
            //animate off scene
            strongSelf.scoreBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.1), completion: {
                strongSelf.restartBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.1), completion: {
                    //animation off has finished
                    //setting gameScene state to isRestarting
                    strongSelf.gameScene.stateChangeToRestart()
                })
            })
          }
    }
}
