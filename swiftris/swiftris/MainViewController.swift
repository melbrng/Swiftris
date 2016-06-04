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
    var gameCenterEnabled:Bool! = false
    var leaderboardIdentifier:String?
    var localPlayer:GKLocalPlayer!
    
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
                updateGamesPlayedAchievement()
                gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
            }
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController)
    {
        print("override")
        
    }
    
    func authenticateLocalPlayer()
    {
        localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil)
                {
                    self.presentViewController(viewController!, animated: true, completion: nil)
                }
            else
                {
                    print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                    self.gameCenterEnabled = true
                    
                    // Get the default leaderboard
                    self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) in
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
    
    func updateGamesPlayedAchievement()
    {
        if GKLocalPlayer.localPlayer().authenticated
        {
            let gamesPlayedAchievement = GKAchievement(identifier: "GamesPlayed")
            gamesPlayedAchievement.showsCompletionBanner = true
            gamesPlayedAchievement.percentComplete = 100.0
            let achievements = [gamesPlayedAchievement]
           
            GKAchievement .reportAchievements(achievements, withCompletionHandler: ({(error) -> Void in
                if (error != nil) {
                    // handle error
                    print("Error: " + error!.localizedDescription);
                }
                else
                {
                    print("Achievement reported")
                }
            }))
        }
    }
}
