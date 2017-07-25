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
    var audioBlock: Button?
    var leaderboardBlock: Button?
    var colorBlock: Button?
    var highscoreLabel: SKLabelNode!
    var animationBool : Bool = false
    
    var disableAds: Button?
    
    //MARK: This class handles the animation and actions of the mainMenu
    weak var gameScene: GameScene?
    func start(scene: GameScene){
        //starting up menu
        self.gameScene = scene
        assignVars()
        //animate in scene
        animateOnScene()
        
    }
    
//    
    func assignVars(){
        //setting vars
        
        titleBlock = self.childNode(withName: "TitleBlock") as? SKSpriteNode
        audioBlock = self.childNode(withName: "AudioBlock") as? Button
        leaderboardBlock = self.childNode(withName: "LeaderboardBlock") as? Button
        colorBlock = self.childNode(withName: "ColorBlock") as? Button
        highscoreLabel = titleBlock.childNode(withName: "Highscore") as? SKLabelNode
        highscoreLabel.text = "Best: \(Information.info.highscore)"
        disableAds = titleBlock.childNode(withName: "DisableAds") as? Button
     }
//
    func animateOnScene(){
        //remove from current scene
        titleBlock.removeFromParent()
        audioBlock?.removeFromParent()
        leaderboardBlock?.removeFromParent()
        colorBlock?.removeFromParent()
        //attach to scene
        gameScene?.addChild(titleBlock)
        gameScene?.addChild(audioBlock!)
        gameScene?.addChild(colorBlock!)
        gameScene?.addChild(leaderboardBlock!)
        //move sprites off screen // 1500 pixels
        titleBlock.position.x -= 1500
        audioBlock?.position.x -= 1500
        leaderboardBlock?.position.x -= 1500
        colorBlock?.position.x -= 1500
        //load audio information from save
        audioBlock?.childNode(withName: "AudioOn")?.alpha = (Information.info.soundOn) ? 1 : 0
        
        disableAds?.childNode(withName: "DisableBar")?.alpha = (Information.info.disabledAdvertisements) ? 1 : 0
        
        //move sprites with time delay for animation effect in order from top to bottom
        titleBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: { [weak self] in
            self?.audioBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: { [weak self] in
                self?.leaderboardBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: { [weak self] in
                    self?.colorBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: { [weak self] in
                        //assign actions to ndoes
                        self?.animationBool = true // animation has completed
                        //assign actions
                        self?.assignActions()
                    })
                })
            })
        })
    }

    func assignActions(){
        //handling audio vars
        audioBlock?.playAction = { [weak self] in
            guard let strongSelf = self else { return }
            
            let audioOnNode = strongSelf.audioBlock?.childNode(withName: "AudioOn") as? SKSpriteNode
            audioOnNode?.alpha = (audioOnNode?.alpha==1) ? 0 : 1
            Information.info.soundOn = (audioOnNode?.alpha==1) ? true : false
        }
        //highscore block
        leaderboardBlock?.playAction = {  [weak self] in
            guard let strongSelf = self else { return }
            //check leaderboard
            strongSelf.gameScene?.gameViewController?.checkGCLeaderboard()
        }
        //color block
        colorBlock?.playAction = { [weak self] in
            guard let strongSelf = self else { return }
            //only unlock if highscore is over 100
            if(Information.info.highscore >= 100){
            Information.info.mainColorWhite = !Information.info.mainColorWhite
            
            //inverting colors with a scene reset
                strongSelf.gameScene?.gameViewController?.resetScene(scene: (self?.gameScene!)!)
            }else{
                let myAlert: UIAlertController = UIAlertController(title: "Yea.. about that!", message: "Reach a highscore of 100 or over to Unlock !", preferredStyle: .alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.gameScene?.gameViewController?.present(myAlert, animated: true, completion: nil)
            }
        }
        
        //disable ads prompt
        disableAds?.playAction = { [weak self] in
            guard let strongSelf = self else { return }
           //disable ads option is only avaiable if highscore is over 200
            if(Information.info.highscore >= 200){
                
                let disableBar = strongSelf.disableAds?.childNode(withName: "DisableBar") as? SKSpriteNode
                
                disableBar?.alpha = (disableBar?.alpha==1) ? 0 : 1
                
                Information.info.disabledAdvertisements = (disableBar?.alpha==1) ? true : false
                
            }else{
            //nope cannot remove ads
            let myAlert: UIAlertController = UIAlertController(title: "Yea.. about that!", message: "Reach a highscore of 200 or over to remove ads!", preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            strongSelf.gameScene?.gameViewController?.present(myAlert, animated: true, completion: nil)
            }
        }
    }

    func animateOffScene(andOnCompletion completion:@escaping ()->()){
        titleBlock.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.15), completion: { [weak self] in
            self?.titleBlock.removeFromParent()
            self?.audioBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.1), completion: { [weak self] in
                self?.audioBlock?.removeFromParent()
                self?.leaderboardBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.1), completion: { [weak self] in
                    self?.colorBlock?.run(SKAction.moveBy(x: 1500, y: 0, duration: 0.1), completion: { [weak self] in
                        self?.colorBlock?.removeFromParent()
                        //animations have finished
                        completion()
                        
                    })
                })
            })
        })
    }
    
    
}

