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
    var gameCenterEnabled:Bool!
    var leaderboardIdentifier:String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        authenticateLocalPlayer()
        
        gamePlaySegmentControl.selectedSegmentIndex = 0
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "showGameView")
        {
            
            if let gameViewController:GameViewController = segue.destinationViewController as? GameViewController
            {
                gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
            }
        }
    }
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil)
                {
                    self.presentViewController(viewController!, animated: true, completion: nil)
                }
                else
                {
                    print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                }
        }
        
        if (localPlayer.authenticated)
            {
                self.gameCenterEnabled = true
                
                // Get the default leaderboard
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) in
                    if (error != nil)
                    {
                        print(error?.localizedDescription)
                    }
                    else
                    {
                        self.leaderboardIdentifier = leaderboardIdentifier!
                        print(self.leaderboardIdentifier)
                    }
                });
                
            }
        }
    
    
    @IBAction func showGameCenter(sender: AnyObject)
    {
        if gameCenterEnabled == true
        {
            let gcGameCenterViewController = GKGameCenterViewController()
            
            gcGameCenterViewController.gameCenterDelegate = self
           
            gcGameCenterViewController.viewState = GKGameCenterViewControllerState.Leaderboards
            
            gcGameCenterViewController.leaderboardIdentifier = leaderboardIdentifier

            presentViewController(gcGameCenterViewController, animated: true, completion: nil)

        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
