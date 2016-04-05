//
//  GameScene.swift
//  swiftris
//
//  Created by Melissa Boring on 2/19/16.
//  Copyright (c) 2016 melbo. All rights reserved.
//
// Responsible for displaying everything Swiftris
// renders the Tetrominos, the background, and the game board
// responsible for playing the sounds and keeping track of the time

import SpriteKit

//SLOWEST speed at which our shapes will travel
//every 6/10th of a second our shape should descend by one row
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene
{
    //closure ( a block of code that performs a function )
    //a closure that takes no parameters and returns nothing...and its optional
    var tick:(() -> ())?
    
    //GAmeScene's current tick length
    var tickLengthMillis = TickLengthLevelOne
    
    //last time we experienced a tick
    var lastTick:NSDate?
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        //OpenGL powers SpriteKit [(0,0) is bottom left corner] so the coordinate system is opposite native iOs
        //We will draw from the top down so our anchor point at 0,1.0
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        //create node capable of displaying our background image
        //let cannot be reassigned
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
    }
    
    override func didMoveToView(view: SKView)
    {
        
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        //guard statement checks the conditions which follow it
        //if the condition fails, guard executes the else block
        //if lastTick is missing the games has been paused and not reporting ticks so return
        guard let lastTick = lastTick else
        {
            return
        }
        
        //lastTick is present so recover time passed since last execution of update by invoking 
        //timeIntervalSinceNow 
        //multiply by -1000 to calculate positive millisecond value
        //dot syntax invokes functions on objects
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis
        {
            self.lastTick = NSDate()
            
            //check if tick exists and if so invoke with no parameters
            tick?()
        }
        
    }
    
    func startTicking()
    {
        lastTick = NSDate()
    }
    
    func stopTicking()
    {
        lastTick = nil
    }
    
}
