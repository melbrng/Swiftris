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
import GameKit

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
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gamePlayLabel: UILabel!
    
    
    //lets make this an optional since I want to set it to null on reset
    var gameTimer:NSTimer?
    var gamePlay = 0
    var gamePlayTime = 0
    var startTime = NSTimeInterval()
    
    enum gamePlayEnum:Int
    {
        case Classic = 0
        case Timed = 1
    }
    
    override func viewDidLoad()
    
    {
        super.viewDidLoad()
        
        //set the limit on the gamePlay time if the user chooses classic or timed play
        gamePlayTime = setTheGamePlayTime()
        
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        // Configure the view.
        //The as! operator is a forced downcast. The view object is of type SKView, but before downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene).
        
        //because SKView is a subclass of View , downcast in order to be able to access properties
        let skView = view as! SKView
        skView.multipleTouchEnabled = false

        //allow touch interaction with the view when voiceover is enabled
        skView.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        skView.isAccessibilityElement = true
        
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
    
     // MARK: Gestures
    
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
        let detectEdge = swiftris.detectIllegalPlacement().edgeColumn
        
        //detect which edge and announce
        if(detectEdge == "Left"){
            announce("Left Edge")
        }
        else if (detectEdge == "Right"){
            announce("Right Edge")
        }
        
        if let originalPoint = panPointReference {
            
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                
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
        
        return ( ( gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer) ||
            ( gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer ) )
    }
    
     // MARK: Game
    
    func didTick()
    {
        swiftris.letShapeFall()
        swiftris.fallingShape?.lowerShapeByOneRow()

        
        // TODO: appropriate code
        //crash fix, check for optional value
        if(swiftris.fallingShape != nil)
        {
            scene.redrawShape(swiftris.fallingShape!, completion: {})
        }
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        
        //announce the shape in play for voiceover
        announce((newShapes.fallingShape?.verbalDescription())!)
        
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
            scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            scene.movePreviewShape(fallingShape) {
 
            scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        //reset the score and level labels and the speed at which the ticks occur
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        timerLabel.text = "\(swiftris.timer)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        startTimer()
        
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

        scene.stopTicking()
        
        //game ends play game over sound
        scene.playSound("gameover.mp3")

        stopTimer()
        
        //then destroy the remaining blocks on the screen
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks())
        {
        
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
        //work when I disable new shapes in play--these announcements are happening at the same time so one overrides the other
        announce("Shape landed")
        
        // check for completed lines
        let removedLines = swiftris.removeCompletedLines()
        
        // if lines were removed update score label to newest score and animate blocks with explosive animation
        if removedLines.linesRemoved.count > 0
        {
            
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks)
            {
                //lets announce for voiceover
                self.announce("Lines Removed")
                
                // detect any new lines
                self.gameShapeDidLand(swiftris)
            }
            
            // Update rowsAddedAchievement
            GameKitHelper.sharedInstance.updateRowsAddedAchievement(removedLines.linesRemoved.count)
            
            scene.playSound("bomb.mp3")
        }
            //no new lines -- bring in next shape
        else
        {
            
            nextShape()
        }
    }
    
    func gameShapeDidMove(swiftris: Swiftris)
    {
        
        scene.redrawShape(swiftris.fallingShape!) {}
    }
    
     // MARK: GameTimer
    
    func startTimer()
    {
        //set up timer adding it to the runloop automatically
        self.gameTimer = NSTimer .scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer()
    {
        if gameTimer != nil
        {
            gameTimer!.invalidate()
            gameTimer = nil
        }
        
        startTime = NSDate.timeIntervalSinceReferenceDate()
   
    }
    
    func setTheGamePlayTime() -> Int
    {
        if(gamePlay == gamePlayEnum.Timed.rawValue)
        {
            gamePlayTime = 2
            gamePlayLabel.text = "Timed"
        }
        else
        {
            gamePlayLabel.text = "Classic"
        }
        
        return gamePlayTime
    }
    
    
    //  based on timer logic in SimpleStopDemo created by Ravi Shankar.
    func updateTimer()
    {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime

        //calculate the minutes in elapsed time.
        var minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        var seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        //concatenate minuets, seconds as assign it to the timerLabel
        timerLabel.text = "\(strMinutes):\(strSeconds)"
        
        if(Int(minutes) == gamePlayTime && gamePlay == gamePlayEnum.Timed.rawValue)
        {
            minutes = 0
            seconds = 0
        
            gameDidEnd(swiftris)
        }
    
    
    }
    
    @IBAction func resetButton(sender: AnyObject)
    {

        scene.stopTicking()
        
        stopTimer()
    }
    
    // MARK: Voiceover
    
    func announce(announcement : String) {
        
        if(UIAccessibilityIsVoiceOverRunning() == true){
            
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,announcement)
            
        }
    }
    


}
