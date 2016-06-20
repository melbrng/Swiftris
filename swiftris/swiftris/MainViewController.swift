//
//  MainViewController.swift
//  swiftris
//
//  Created by Melissa Boring on 5/29/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import UIKit
import GameKit

class MainViewController: UIViewController,GKGameCenterControllerDelegate
{
    
    @IBOutlet weak var gamePlaySegmentControl: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
        
        gamePlaySegmentControl.selectedSegmentIndex = 0
        
        
    }
    
    
    // MARK: Segue
    
    //lets present the Game VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if GameKitHelper.sharedInstance.gameCenterEnabled == true
        {
            if(segue.identifier == "showGameView")
            {
                
                if let gameViewController:GameViewController = segue.destinationViewController as? GameViewController
                {
                    //set the currentScore because we are going to add to it after completion of a game
                    GameKitHelper.sharedInstance.loadGamesPlayedScore()
                    gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
                }
            }
        }
        else
        {
            self.presentViewController(GameKitHelper.sharedInstance.authenticationViewcontroller!, animated: true, completion: nil)
        }
    }
    
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController)
    {
        //increment (report) the gamePlayedScore after completion of a game
        GameKitHelper.sharedInstance.reportGamesPlayedScore()
        
    }
    
    // MARK: GameCenter
    
    //present the GameCenter VC
    @IBAction func showGameCenter(sender: AnyObject)
    {
        
        if GameKitHelper.sharedInstance.gameCenterEnabled == true
        {
            let gcGameCenterViewController = GKGameCenterViewController()
            
            gcGameCenterViewController.gameCenterDelegate = self
            
            gcGameCenterViewController.viewState = GKGameCenterViewControllerState.Achievements
            
            gcGameCenterViewController.leaderboardIdentifier = GameKitHelper.sharedInstance.leaderboardIdentifier
            
            presentViewController(gcGameCenterViewController, animated: true, completion: nil)
            
        }
        else
        {
            self.presentViewController(GameKitHelper.sharedInstance.authenticationViewcontroller!, animated: true, completion: nil)
        }
    }
    
    //dismiss GameCenterVC upon exit
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
