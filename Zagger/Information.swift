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
    
    mutating func loadInfo(){
        
        //loading in if audio is on
        if let audioOn = UserDefaults.standard.value(forKey: "audioOn"){
            soundOn = audioOn as! Bool
        }
    }
    
}
