//
//  GameScene.swift
//  Zagger
//
//  Created by Evan Chen on 7/11/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import SpriteKit
import GameplayKit

enum gameState{
    case isLaunched, isStarting, isPlaying, isEnding, isRestarting
}
enum formations{
    case formationA
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Class Variables
    
    //link from controller to scene
    var gameViewController = GameViewController()
    
    //current formation
    var currentFormation : SKNode!
    var nextFormation : SKNode!
    var numberOfFormation = 0
    
    
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
                snake.physicsBody?.applyImpulse(CGVector(dx: -100, dy: 100))
            }else{
                //thrust snake right
                particle.particleRotation = -CGFloat(Double.pi/4)
                snake.zRotation = -CGFloat(Double.pi/4)// 45 degrees
                snake.physicsBody?.velocity = CGVector.zero
                snake.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 100))
            }
        }
    }
    //camera
    var gameCamera : SKCameraNode!
    
    
    //MARK: Game state didSet
    var state : gameState = .isLaunched{
        didSet{
            switch(state){
            case .isLaunched:
                print("changing gameState to isLaunched")
                break
            case .isStarting:
                print("isStarting")
                //apply vertical impulse to snake
                snake.alpha = 0 //turning snake invis for trail illusion
                //applying particle to snake
                particle = snakeParticle()
                snake.addChild(particle)
                //starting up snake
                snakeDirectionLeft = true
                DispatchQueue.main.async {
                    self.state = .isPlaying
                }
                break
            case .isPlaying:
                print("isPlaying")
                break
            case .isEnding:
                DispatchQueue.main.async {
                    self.state = .isRestarting
                }
                break
            case .isRestarting:
                print("restarting game")
                
                //restarting game
                
                gameViewController.resetScene()
                
                break
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        //MARK: Assigning class variables
        
        //setting didSet to isLaunched
        state = .isLaunched
        
        snake = self.childNode(withName: "Snake") as? SKSpriteNode
        currentFormation = SKNode()
        nextFormation = SKNode()
        //Setting up camera
        gameCamera = self.childNode(withName: "Camera") as? SKCameraNode
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
        
        
        if(contactPointA.node?.name == "Snake" && contactPointB.node?.name == "Obstacle"){
            //death on contact
            state = .isEnding
        }
        if(contactPointB.node?.name == "Snake" && contactPointA.node?.name == "Obstacle"){
            //death on contact
            state = .isEnding
        }
    }
    
    
    //MARK: Formation functions
    
    func newCurrentFormation(){
        currentFormation = buildRandomFormation()
        applyFormation(formation: currentFormation)
    }
    
    func newNextFormation(){
        nextFormation = buildRandomFormation()
        applyFormation(formation: nextFormation)
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
        switch(arc4random_uniform(3)+1){
        case 1:
            fileString = "FormationA.sks"
            break
        case 2:
            fileString = "FormationB.sks"
            break
        case 3:
            fileString = "FormationC.sks"
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
        //start up game if isLaunched
        if(state == .isLaunched){
            state = .isStarting
        }
        //change snake direction based on taps
        if(state == .isPlaying){
            snakeDirectionLeft = !snakeDirectionLeft
        }
    }
    
    //MARK: Particle Generation
    
    func snakeParticle() -> SKEmitterNode{
        let snakeRightParticle = SKEmitterNode()
        snakeRightParticle.targetNode = self
        snakeRightParticle.particleTexture = SKTexture(imageNamed: "Triangle")
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
}
