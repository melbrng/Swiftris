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

//SPRITEKIT - Graphics rendering and animation infrastructure
//Use to animate images (Sprites)
//Traditional rendering loop where contents of each frame is processed before the frame is rendered
//The game determines the contents of the scene and how those contents change in each frame
//SpriteKit renders frames of animation efficiently using graphics hardware
//Position of the sprites can be changed arbitrarily in each frame of animation

//Scenes(SKScene) are presented inside a View (SKView)
//place view inside window and render content to it
//Scenes:
// - hold sprites and other content
// - implements per frame logic and processing

import SpriteKit

//SLOWEST speed at which our shapes will travel
//every 6/10th of a second our shape should descend by one row
let TickLengthLevelOne = NSTimeInterval(600)

let BlockSize:CGFloat = 20.0

class GameScene: SKScene
    
{
    //nodes are the fundamental building blocks for all content
    //scene is the root node
    //scene and its descendents determine which content is drawn and how it is rendered
    //SKNode does not draw anything, rather applies it properties to its descendants
    //all nodes are responder objects ( respond to user input )
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6,y: -6)
    
    
    //closure ( a block of code that performs a function )
    //a closure that takes no parameters and returns nothing...and its optional
    var tick:(() -> ())?
    
    //GameScene's current tick length
    var tickLengthMillis = TickLengthLevelOne
    
    //last time we experienced a tick
    var lastTick:NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
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
        //SKSpriteNote is a SKNode that draws a textured image, colored square, textured image blended with color
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        
    }
    
    //called whenever a scene is presented in a view
    override func didMoveToView(view: SKView)
    {
        
    }
   
    //lets use update to determine if a time interval has passed
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
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            // #10
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #11
            sprite.position = pointForColumn(block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            // #12
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.2)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                
                //research error why nil vs {} would fail
                SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: 0.2)]), completion:{})
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            if block == shape.blocks.last {
                sprite.runAction(moveToAction, completion: completion)
            } else {
                sprite.runAction(moveToAction)
            }
        }
    }

    
}
