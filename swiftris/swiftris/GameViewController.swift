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

class GameViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        // Configure the view.
        //The as! operator is a forced downcast. The view object is of type SKView, but before downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene).
        
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)

    }


    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}
