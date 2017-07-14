//
//  Information.swift
//  Zagger
//
//  Created by Evan Chen on 7/13/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import Foundation

struct Information{
    
    //MARK: Purpose of this struct is to save information
    static var info = Information() // static
    
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
    
    mutating func loadInfo(){
        
        //loading in if audio is on
        if let audioOn = UserDefaults.standard.value(forKey: "audioOn"){
            soundOn = audioOn as! Bool
        }
        
        
        //loading highscore
        if let high = UserDefaults.standard.value(forKey: "highscore"){
            highscore = high as! Int64
        }
    }
    
}
