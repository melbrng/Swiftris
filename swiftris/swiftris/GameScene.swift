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
    
    //create a timer for game play
//    var gameTimer = NSTimer()
//    let startDate = NSDate()
//    var gameCounter = 0
    
    //closure ( a block of code that performs a function )
    //a closure that takes no parameters and returns nothing...and its optional
    var tick:(() -> ())?
    
    //GameScene's current frame tick length
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
        
        //lets make the background the same size as the scene so that when we execute on different size phones my OCD is not affected
        background.size = (scene?.size)!
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        //set up timer adding it to the runloop automatically
        //gameTimer = NSTimer .scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameScene.updateTimer), userInfo: nil, repeats: true)
        
        //set up looping playback for the most annoying song in the world
        runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
        
    }
    
//    func updateTimer()->Int
//    {
//        
//        gameCounter+=1
//        //print("counter = " + String(gameCounter))
//        return gameCounter
//        
//    }
    
    //play any sound file on demand
    func playSound(sound:String)
    {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    //called whenever a scene is presented in a view
    override func didMoveToView(view: SKView)
    {
        
    }
   
    //lets use update to determine if a time interval has passed
    override func update(currentTime: CFTimeInterval)
    {
        
        //print("update")
       
        
        /* Called before each frame is rendered */
        //guard statement checks the conditions which follow it
        //if the condition fails, guard executes the else block
        //if lastTick is missing the games has been paused and not reporting ticks so return
        
        //print(lastTick?.description)
        
        guard let lastTick = lastTick else
        {
            return
        }
        
        //lastTick is present so recover time passed since last execution of update by invoking 
        //timeIntervalSinceNow 
        //multiply by -1000 to calculate positive millisecond value
        //dot syntax invokes functions on objects
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        //print(timePassed)
        
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
        //print((lastTick?.description)! + " startTicking")
    }
    
    func stopTicking()
    {
        lastTick = nil
        //print(" stopTicking")
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint
    {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for block in shape.blocks
        {
            // #10
            var texture = textureCache[block.spriteName]
            if texture == nil
            {
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
    
    func movePreviewShape(shape:Shape, completion:() -> ())
    {
        for block in shape.blocks
        {
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
    
    func redrawShape(shape:Shape, completion:() -> ())
    {
        for block in shape.blocks
        {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            if block == shape.blocks.last
            {
                sprite.runAction(moveToAction, completion: completion)
            }
            else
            {
                sprite.runAction(moveToAction)
            }
        }
    }

    // MARK: ANIMATIONS
    // take tuple data for each removed line
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:() -> ()) {
        
        //determine how long to wait before calling completion closure
        var longestDuration: NSTimeInterval = 0
        
        // iterate column by column
        for (columnIdx, column) in fallenBlocks.enumerate() {
            
            //block by block
            for (blockIdx, block) in column.enumerate() {
                let newPosition = pointForColumn(block.column, row: block.row)
                let sprite = block.sprite!
                
                // blocks fall one after the other than all at once
                let delay = (NSTimeInterval(columnIdx) * 0.05) + (NSTimeInterval(blockIdx) * 0.05)
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                
                // remove lines and shoot blocks off the screen
                // generate random to introduce natural variance
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(block.column, row: block.row)
                point = CGPointMake(point.x + (goLeft ? -randomRadius : randomRadius), point.y)
                
                let randomDuration = NSTimeInterval(arc4random_uniform(2)) + 0.5
                
                // choose beginning and starting angles
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.followPath(archPath.CGPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .EaseIn
                let sprite = block.sprite!
                
                // place the block sprite above the others such that they animate above the other blocks and begin the sequence of actions which concludes with removing the sprite from the scene
                sprite.zPosition = 100
                sprite.runAction(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOutWithDuration(NSTimeInterval(randomDuration))]),
                            SKAction.removeFromParent()]))
            }
        }
        // run completion action after duration of time take to drop last block to its new resting place
        runAction(SKAction.waitForDuration(longestDuration), completion:completion)
    }
    
}
