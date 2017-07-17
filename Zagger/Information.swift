//
//  Information.swift
//  Zagger
//
//  Created by Evan Chen on 7/13/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation
import SpriteKit
struct Information{

    //MARK: Purpose of this struct is to save information
    static var info = Information() // static
    
    
    //In Game Sound actions
    let moveSound = SKAction.playSoundFileNamed("SnakeMove.wav", waitForCompletion: false)
    
    let moveSoundA = SKAction.playSoundFileNamed("SnakeMoveA.wav", waitForCompletion: false)
    
    let gameOverSound = SKAction.playSoundFileNamed("GameOver.wav", waitForCompletion: false)
    
    let goodChanceSound = SKAction.playSoundFileNamed("GoodChance.mp3", waitForCompletion: false)
    
    let badChanceSound = SKAction.playSoundFileNamed("BadChance.wav", waitForCompletion: false)
    
    //controller of sound
    var soundOn: Bool = true{
        didSet{
            //saving this info
            UserDefaults.standard.set(soundOn, forKey: "audioOn")
        }
    }
    
    var highscore: Int64 = 0{
        didSet{
            //saving this info
            UserDefaults.standard.set(highscore, forKey: "highscore")
        }
    }
    
    var mainColorWhite: Bool = true{
        didSet{
            //saving this info
            UserDefaults.standard.set(mainColorWhite, forKey: "mainColorWhite")
        }
    }
    
    var disabledAdvertisements: Bool = false{
        didSet{
            //saving this info
            UserDefaults.standard.set(disabledAdvertisements, forKey: "disabledAds")
        }
    }
    
    mutating func loadInfo(){
        
        //loading in if audio is on
        if let audioOn = UserDefaults.standard.value(forKey: "audioOn"){
            soundOn = audioOn as! Bool
        }
        
        
        //loading highscore
        if let high = UserDefaults.standard.value(forKey: "highscore"){
            highscore = high as! Int64
        }
        
        //load color
        if let color = UserDefaults.standard.value(forKey: "mainColorWhite"){
            mainColorWhite = color as! Bool
        }
        
        //load in app purchase
        if let disabled = UserDefaults.standard.value(forKey: "disabledAds"){
            disabledAdvertisements = disabled as! Bool
        }
    }
    //MARK : In Game Audio play funcs
    func playSnakeSound(scene: GameScene){
        if(soundOn){
            scene.run(moveSound)
        }
    }
    
    func playSnakeSoundA(scene: GameScene){
        if(soundOn){
            scene.run(moveSoundA)
        }
    }
    
    func playGameOverSound(scene: GameScene){
        if(soundOn){
            scene.run(gameOverSound)
        }
    }
    
    func playGoodChanceSound(scene: GameScene){
        if(soundOn){
            scene.run(goodChanceSound)
        }
    }
    
    func playBadChanceSound(scene: GameScene){
        if(soundOn){
            scene.run(badChanceSound)
        }
    }
}
