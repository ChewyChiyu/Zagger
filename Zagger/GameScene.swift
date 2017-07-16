//
//  GameScene.swift
//  Zagger
//
//  Created by Evan Chen on 7/11/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

enum gameState{
    case isLaunched, isStarting, isPlaying, isEnding, isRestarting
}
enum formations{
    case formationA
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Class Variables
    
    //full screen AD
     var interstitial: GADInterstitial!
    
    //link from controller to scene
    var gameViewController = GameViewController()
    
    //current formation
    var currentFormation : SKNode!
    var nextFormation : SKNode!
    var numberOfFormation = 0{
        //increasing speed of snake after each formation
        didSet{
            if(snakeImpulseContstant < 140){ // max speed is 70-150
                snakeImpulseContstant += 10
            }
        }
    }
    
    var snakeImpulseContstant = 70
    var snake: SKSpriteNode!
    var particle: SKEmitterNode!
    //Handling the movement of the snake
    
    var snakeDirectionLeft:Bool = false{
        didSet{ //MARK: Arc Tan 1 = 45 degrees, arcTan(yVelo/xVelo) = radian
            if(snakeDirectionLeft){
                //thrust snake left
                particle.particleRotation = CGFloat(Double.pi/4)// 45 degrees
                snake.zRotation = CGFloat(Double.pi/4)// 45 degrees
                snake.physicsBody?.velocity = CGVector.zero
                snake.physicsBody?.applyImpulse(CGVector(dx: -snakeImpulseContstant, dy: snakeImpulseContstant))
                //play sound if possible
                Information.info.playSnakeSound(scene: self)
            }else{
                //thrust snake right
                particle.particleRotation = -CGFloat(Double.pi/4)
                snake.zRotation = -CGFloat(Double.pi/4)// 45 degrees
                snake.physicsBody?.velocity = CGVector.zero
                snake.physicsBody?.applyImpulse(CGVector(dx: snakeImpulseContstant, dy: snakeImpulseContstant))
                //play sound if possible
                Information.info.playSnakeSoundA(scene: self)
            }
        }
    }
    //camera
    var gameCamera : SKCameraNode!
    //score
    var scoreLabel: SKLabelNode!
    var score: Int64  = 0{
        didSet{
            scoreLabel.text = String(score)
        }
    }
    
    
    var mainMenu : MainMenu?
    var restartMenu: RestartMenu?
    //MARK: Game state didSet
    var state : gameState = .isLaunched{
        didSet{
            switch(state){
            case .isLaunched:
                //MARK: Main Menu
                if let m = MainMenu(fileNamed: "MainMenu"){
                    mainMenu = m
                    //start up mainMenu
                    mainMenu?.start(scene: self)
                }
                break
            case .isStarting:
                //apply vertical impulse to snake
                //applying particle to snake
                particle = snakeParticle()
                snake.addChild(particle)
                //turning snake particle
                particle.particleRotation = CGFloat(Double.pi/4)
                //showing score
                scoreLabel.alpha = 1
                
                break
            case .isPlaying:
                snake.alpha = 0 //turning snake invis for trail illusion
                //starting up snake
                
                break
            case .isEnding:
                //playing gameOverSound
                
                Information.info.playGameOverSound(scene: self)
                
                //removing all actions if any
                particle.removeAllActions()
                currentFormation.removeAllActions()
                nextFormation.removeAllActions()
                
                //stopping all sprites and by setting physicsWorld speed
                self.physicsWorld.speed = 0
                //handle highscore
                if(Information.info.highscore < score){
                    Information.info.highscore = score
                }
                //shake the camera a bit
                shakeCamera(layer: currentFormation, duration: 0.2, ampX: 60, ampY: 30)
                shakeCamera(layer: nextFormation, duration: 0.2, ampX: 60, ampY: 30)
                
                //boot up restart menu
                if let restart = RestartMenu(fileNamed: "RestartMenu"){
                    restartMenu = restart
                    restartMenu?.start(scene: self)
                }
                
                if(gameViewController.gcEnabled){
                    //if gamecenter is enabled send info
                    gameViewController.addScoreAndSubmitToGC(score: Information.info.highscore)
                }
                
                
                break
            case .isRestarting:
                //load add when restarting and ready
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: gameViewController)
                }
                
                //restarting game
                gameViewController.resetScene()
                break
            }
        }
    }
    
    
    //MARK: State change funcs
    func stateChangeToRestart(){
        state = .isRestarting
    }
    func stateChangeToPlaying(){
        state = .isPlaying
    }
    func stateChangeToStarting(){
        state = .isStarting
    }
    override func didMove(to view: SKView) {
        //MARK: Handle loading in an ad if possible here
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/1033173712")
        
        //Test Ad ID: ca-app-pub-3940256099942544/1033173712
        //Live Ad ID: ca-app-pub-1967902439424087/3024719452
        
        
        
        let request = GADRequest()
        interstitial.load(request)
        
        //MARK: Assigning class variables
        
        //setting didSet to isLaunched
        state = .isLaunched
        
        snake = self.childNode(withName: "Snake") as? SKSpriteNode
        
        if(Information.info.mainColorWhite){
            snake.color = UIColor.white
            self.backgroundColor = UIColor.black
        }else{
            snake.color = UIColor.black
            self.backgroundColor = UIColor.white
        }
        
        //so cant ignore color change
        snake.colorBlendFactor = 1
        
        
        
        currentFormation = SKNode()
        nextFormation = SKNode()
        //Setting up camera
        gameCamera = self.childNode(withName: "Camera") as? SKCameraNode
        scoreLabel = gameCamera.childNode(withName: "Score") as? SKLabelNode
        scoreLabel.alpha = 0
        self.camera = gameCamera
        
        //setting physics contact delegate to self
        self.physicsWorld.contactDelegate  = self
        
        //setting default formations
        newCurrentFormation()
        newNextFormation()
    }
    
    //MARK: Physics contact delegate
    func didBegin(_ contact: SKPhysicsContact) {
        let contactPointA = contact.bodyA
        let contactPointB = contact.bodyB
        
        //snake collisions
        
        if(contactPointA.node?.name == "Snake" && contactPointB.node?.name == "Obstacle"){
            //death on contact
            state = .isEnding
        }
        if(contactPointB.node?.name == "Snake" && contactPointA.node?.name == "Obstacle"){
            //death on contact
            state = .isEnding
        }
        
        //particle collisions with obstacles
        if(contactPointA.node?.name == "Obstacle" && contactPointB.node?.name == "ChanceParticle"){
            contactPointB.node?.removeFromParent() // removing partcile
        }
        if(contactPointB.node?.name == "Obstacle" && contactPointA.node?.name == "ChanceParticle"){
            contactPointA.node?.removeFromParent() // removing partcile
        }
        
        //particle collisions with snake
        if(contactPointA.node?.name == "Snake" && contactPointB.node?.name == "ChanceParticle"){
            let particle = contactPointB.node as? ChanceParticle
            particle?.contactedWithSnake()
        }
        if(contactPointB.node?.name == "Snake" && contactPointA.node?.name == "ChanceParticle"){
            let particle = contactPointA.node as? ChanceParticle
            particle?.contactedWithSnake()
        }
        
    }
    
    
    //MARK: Formation functions
    
    func newCurrentFormation(){
        currentFormation = buildRandomFormation()
        applyFormation(formation: currentFormation)
        generateChanceParticles() //chance particle
    }
    
    func newNextFormation(){
        nextFormation = buildRandomFormation()
        applyFormation(formation: nextFormation)
        generateChanceParticles() //chance particle
    }
    
    func generateChanceParticles(){
        //random num of particles, some will die on spawn via contact with obstacles
        for _ in 0...Int(arc4random_uniform(4)){ // 1 min , 5 max
            let newChanceParticle = ChanceParticle(gameScene: self)
            self.addChild(newChanceParticle)
        }
    }
    
    func applyFormation(formation: SKNode){
        //each formation is 9000 pixels long
        
        //formation buffer allows formations to be added one after another in y increasing order
        let yPosition = (numberOfFormation * 9500 )  // formation buffer
        
        self.addChild(formation)
        for obstacle in formation.children{
            obstacle.position.y += CGFloat(yPosition)
            
            //naming obstacle
            obstacle.name = "Obstacle"
            
            let obstaclePhysics = obstacle as? SKSpriteNode
            
            //coloring obstacle
            if(Information.info.mainColorWhite){
                obstaclePhysics?.color = UIColor.white
            }else{
                obstaclePhysics?.color = UIColor.black
            }
            
            obstaclePhysics?.colorBlendFactor = 1
            
            //applying physics to obstacles
            
            //bounding rect physics body
            obstaclePhysics?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (obstaclePhysics?.size.width)!, height: (obstaclePhysics?.size.height)!))
            
            // no collision but yes contact
            obstacle.physicsBody?.collisionBitMask = 0
            obstacle.physicsBody?.contactTestBitMask = UINT32_MAX
            //no gravity
            obstacle.physicsBody?.affectedByGravity = false
            obstacle.physicsBody?.allowsRotation = false
        }
        numberOfFormation+=1 // increasing number of formations
    }
    
    
    //MARK: Build formations
    func buildRandomFormation() -> SKNode{
        
        //arc random for a random formation
        var fileString = String()
        switch(arc4random_uniform(6)+1){
        case 1:
            fileString = "FormationA.sks"
            break
        case 2:
            fileString = "FormationB.sks"
            break
        case 3:
            fileString = "FormationC.sks"
        case 4:
            fileString = "FormationD.sks"
            break
        case 5:
            fileString = "FormationE.sks"
            break
        case 6:
            fileString = "FormationF.sks"
            break
        default:
            break
        }
        
        let formation = SKScene(fileNamed: fileString)
        let formationNode = SKNode()
        for obstacle in (formation?.children)!{
            //removing from parent and adding to formationNode
            obstacle.removeFromParent()
            formationNode.addChild(obstacle)
        }
        return formationNode
    }
    //MARK: User input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(state == .isLaunched && (mainMenu?.animationBool)!){
            mainMenu?.animateOffScene {
                self.stateChangeToStarting()
            }
        }
        
        if(state == .isStarting){
            stateChangeToPlaying()
        }
        //change snake direction based on taps
        if(state == .isPlaying){
            snakeDirectionLeft = !snakeDirectionLeft
            //increment score
            score+=1
        }
        
    }
    
    //MARK: Particle Generation
    
    func snakeParticle() -> SKEmitterNode{
        let snakeRightParticle = SKEmitterNode()
        snakeRightParticle.targetNode = self
        snakeRightParticle.particleTexture = SKTexture(imageNamed: "Triangle")
        
        if(Information.info.mainColorWhite){
            snakeRightParticle.particleColor = UIColor.white
        }else{
            snakeRightParticle.particleColor = UIColor.black
        }
        
        snakeRightParticle.particleColorBlendFactor = 1
        snakeRightParticle.particleColorSequence = nil
        
        snakeRightParticle.particleLifetime = 1
        snakeRightParticle.particleBirthRate = 1000
        snakeRightParticle.particleAlphaSpeed = -1
        snakeRightParticle.name = "Particle"
        return snakeRightParticle
    }
    //MARK: Render
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        clampCamera()
        removeNodes()
        checkIfNewFormation()
    }
    func checkIfNewFormation(){
        //applys new formation when children count is less than zero for current or next formation
        if(currentFormation.children.count <= 0){
            newCurrentFormation()
        }
        if(nextFormation.children.count <= 0){
            newNextFormation()
        }
    }
    func clampCamera(){
        
        //moving camera here, only moving y pos, attaching game camera to snake
        if((snake.position.y + (view?.bounds.height)!*0.1) >= gameCamera.position.y){
            gameCamera.position.y = snake.position.y + (view?.bounds.height)!*0.1
        }
    }
    func removeNodes(){
        //removing obstacles not in camera
        
        for obstacle in currentFormation.children{
            if(obstacle.position.y < snake.position.y - (view?.bounds.height)! * 4){
                obstacle.removeFromParent()
            }
        }
        for obstacle in nextFormation.children{
            if(obstacle.position.y < snake.position.y - (view?.bounds.height)! * 4){
                obstacle.removeFromParent()
            }
        }
    }
    func shakeCamera(layer:SKNode, duration:Float, ampX: Float, ampY: Float) {
        //code taken from internet
        let amplitudeX:Float = ampX;
        let amplitudeY:Float = ampY;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
    }
    

}
