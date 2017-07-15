//
//  GameViewController.swift
//  Zagger
//
//  Created by Evan Chen on 7/11/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//


import GameKit
import UIKit
import SpriteKit
import GameplayKit


class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    //MARK: Game Center Controller
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.score.Zagger"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: Loading in game information from saves
        Information.info.loadInfo()
        
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene"){
                // Set the scale mode to scale to fit the window
                                
                scene.scaleMode = .aspectFill
                
                //assigning controller to self
                scene.gameViewController = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        //MARK: Setting up game Center
        // Call the GC authentication controller
        authenticateLocalPlayer()
    }

    func resetScene(){
        if let scene = GameScene(fileNamed:"GameScene") {
            let view = self.view! as! SKView
            
            view.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill

            //reapplying gameViewController to self
            scene.gameViewController = self
            
            view.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
        }

    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { //print(error!)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
            }
        }
    }
    
    // MARK: - SUBMIT THE UPDATED SCORE TO GAME CENTER
    func addScoreAndSubmitToGC(score: Int64) {
        
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = score
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - OPEN GAME CENTER LEADERBOARD
    func checkGCLeaderboard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
