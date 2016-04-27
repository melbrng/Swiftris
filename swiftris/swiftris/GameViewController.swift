//
//  GameViewController.swift
//  swiftris
//
//  Created by Melissa Boring on 2/19/16.
//  Copyright (c) 2016 melbo. All rights reserved.
//
// Responsible for handling user input and communicating between GameScene and a game logic class

import UIKit
import SpriteKit

//A constant or variable of a certain class type may actually refer to an instance of a subclass behind the scenes. Where you believe this is the case, you can try to downcast to the subclass type with a type cast operator (as? or as!).
//The forced form, as!, attempts the downcast and force-unwraps the result as a single compound action
//Use the forced form of the type cast operator (as!) only when you are sure that the downcast will always succeed. This form of the operator will trigger a runtime error if you try to downcast to an incorrect class type.

var scene: GameScene!
var swiftris:Swiftris!
var panPointReference:CGPoint?

class GameViewController: UIViewController, SwiftrisDelegate,UIGestureRecognizerDelegate
{

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        // Configure the view.
        //The as! operator is a forced downcast. The view object is of type SKView, but before downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene).
        
        //because SKView is a subclass of View , downcast in order to be able to access properties
        //??? Why downcast ??? Why not declare SKView instead ???
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)


    }


    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer)
    {
        swiftris.rotateShape()
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer)
    {
        swiftris.dropShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer)
    {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    // fail other gesture if choose
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if gestureRecognizer is UISwipeGestureRecognizer
        {
            if otherGestureRecognizer is UIPanGestureRecognizer
            {
                return true
            }
        }
        else if gestureRecognizer is UIPanGestureRecognizer
        {
            if otherGestureRecognizer is UITapGestureRecognizer
            {
                return true
            }
        }
        
        return false
    }
    
    
    func didTick()
    {
        swiftris.letShapeFall()
        swiftris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(swiftris.fallingShape!, completion: {})
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
            scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            scene.movePreviewShape(fallingShape) {
 
            self.view.userInteractionEnabled = true
            scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        //reset the score and level labels and the speed at which the ticks occur
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil
        {
            scene.addPreviewShapeToScene(swiftris.nextShape!)
            {
                self.nextShape()
            }
        }
        else
        {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris)
    {
        view.userInteractionEnabled = false
        scene.stopTicking()
        
        //game ends play game over sound
        scene.playSound("gameover.mp3")
        
        //then destroy the remaining blocks on the screen
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks())
        {
            swiftris.beginGame()
        }
    }
    
    //as players level up will decrease tick level
    func gameDidLevelUp(swiftris: Swiftris)
    {
        levelLabel.text = "\(swiftris.level)"
        
        if scene.tickLengthMillis >= 100
        {
            scene.tickLengthMillis -= 100
        }
        else if scene.tickLengthMillis > 50
        {
            scene.tickLengthMillis -= 50
        }
        
        scene.playSound("levelup.mp3")
    }
    
    //hear efforts
    func gameShapeDidDrop(swiftris: Swiftris)
    {
        
        scene.stopTicking()
        
        scene.redrawShape(swiftris.fallingShape!)
        {
            swiftris.letShapeFall()
        }
        
        scene.playSound("drop.mp3")
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris)
    {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        
        // #10
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks)
            {
                // #11
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    func gameShapeDidMove(swiftris: Swiftris)
    {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
