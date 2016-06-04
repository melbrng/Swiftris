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
    
    //lets present the Game VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "showGameView")
        {
            
            if let gameViewController:GameViewController = segue.destinationViewController as? GameViewController
            {
                //updateGamesPlayedAchievement()
                reportGamesPlayed()
                gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
            }
        }
    }
    
    //do nothing for now as I just want to make sure I am returning to my origin MainVC instead of creating a new one
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController)
    {
        //print("gameCenterEnabled : " + String(gameCenterEnabled))
        //print("leaderboardIdentifier : " + leaderboardIdentifier!)
    }
    
    //authenticate player on GameKit, if authenticated get default leaderboardID
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
                        
                        }
                    });
                }

        }
    }
    
    //present the GameCenter VC
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
    
    //dismiss GameCenterVC upon exit
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //set score to 1 for each game played
    func reportGamesPlayed()
    {
        if GKLocalPlayer.localPlayer().authenticated
        {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier!)
            gkScore.value = 1
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error) -> Void in
                if (error != nil)
                {
                    print("Error: " + (error?.localizedDescription)!)
                }
                else
                {
                    print("Score reported: \(gkScore.value)")
                }
            }))
        }
    }
    
}
