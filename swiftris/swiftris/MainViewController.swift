//
//  MainViewController.swift
//  swiftris
//
//  Created by Melissa Boring on 5/29/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import UIKit


class MainViewController: UIViewController
{
    
    @IBOutlet weak var gamePlaySegmentControl: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        gamePlaySegmentControl.selectedSegmentIndex = 0
        
    }
    
    @IBAction func gamePlaySegmentControl(sender: AnyObject)
    {
        //print("index : " + String(gamePlaySegmentControl.selectedSegmentIndex))
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "showGameView")
        {
            print("index : " + String(gamePlaySegmentControl.selectedSegmentIndex))

            if let gameViewController:GameViewController = segue.destinationViewController as? GameViewController
            {
                gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
            }
        }
    }
}
