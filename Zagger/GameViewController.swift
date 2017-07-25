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
import GoogleMobileAds


class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    //MARK: Game Center Controller
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    //full screen AD
    var interstitial: GADInterstitial?
    
    var gameView: SKView!
    var gameScene: SKScene!
    var gamesPlayed = 0
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.score.Zagger"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: Loading in game information from saves
        Information.info.loadInfo()
        
        //MARK: Handle loading in an ad if possible here
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1967902439424087/3024719452")
        
        //Test Ad ID: ca-app-pub-3940256099942544/1033173712
        //Live Ad ID: ca-app-pub-1967902439424087/3024719452

        let request = GADRequest()
        interstitial?.load(request)
        
        
        
        if let view = self.view as! SKView? {
            gameView = view
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene"){
                // Set the scale mode to scale to fit the window
                gameScene = scene
                scene.scaleMode = .aspectFill
                
                //assigning controller to self
                scene.gameViewController = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        
        //MARK: Setting up game Center
        // Call the GC authentication controller
        authenticateLocalPlayer()
    }

    func resetScene(scene: GameScene){
        
        //MARK: Handle loading in an ad if possible here
        gamesPlayed+=1
        
        if(!Information.info.disabledAdvertisements && (interstitial?.isReady)! && gamesPlayed % 3 == 0){
            interstitial?.present(fromRootViewController: scene.gameViewController!)
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-1967902439424087/3024719452")
            let request = GADRequest()
            interstitial?.load(request)
        }
        
        
        
        //clearing scene
        
        gameScene.removeAllActions()
        gameScene.removeAllChildren()
        gameScene.removeFromParent()
        gameScene = nil
        gameView = nil
        

        
        if let scene = GameScene(fileNamed:"GameScene") {
            let view = self.view! as! SKView
            gameView = view
            gameScene = scene
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
