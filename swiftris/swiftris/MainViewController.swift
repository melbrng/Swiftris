//
//  MainViewController.swift
//  swiftris
//
//  Created by Melissa Boring on 5/29/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import UIKit
import GameKit

//var gameKitHelper: GameKitHelper!

class MainViewController: UIViewController,GKGameCenterControllerDelegate
{
    
    @IBOutlet weak var gamePlaySegmentControl: UISegmentedControl!
//    var gameCenterEnabled:Bool! = false
//    var leaderboardIdentifier:String?
//    var localPlayer:GKLocalPlayer!
//    var currentScore:Int64 = 0
    var gameKitHelper:GameKitHelper! = nil
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        gameKitHelper = appDelegate.gameKitHelper
        
        gameKitHelper.authenticateLocalPlayer()
        
        gamePlaySegmentControl.selectedSegmentIndex = 0
        
        //gameKitHelper.resetAchievements()
        
    }
    
    
    // MARK: Segue
    
    //lets present the Game VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if gameKitHelper.gameCenterEnabled == true
        {
            if(segue.identifier == "showGameView")
            {
                
                if let gameViewController:GameViewController = segue.destinationViewController as? GameViewController
                {
                    //set the currentScore because we are going to add to it after completion of a game
                    gameKitHelper.loadGamesPlayedScore()
                    gameViewController.gamePlay = gamePlaySegmentControl.selectedSegmentIndex
                }
            }
        }
        else
        {
            self.presentViewController(gameKitHelper.authenticationViewcontroller!, animated: true, completion: nil)
        }
    }
    
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController)
    {
        //increment (report) the gamePlayedScore after completion of a game
        gameKitHelper.reportGamesPlayedScore()
        
    }
    
    // MARK: GameCenter
    
    //authenticate player on GameKit, if authenticated get default leaderboardID
//    func authenticateLocalPlayer()
//    {
//        localPlayer = GKLocalPlayer.localPlayer()
//        
//        localPlayer.authenticateHandler = {(viewController, error) -> Void in
//            if ((viewController) != nil)
//            {
//                self.presentViewController(viewController!, animated: true, completion: nil)
//            }
//            else
//            {
//                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
//                self.gameCenterEnabled = true
//                
//                // Get the default leaderboard
//                self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) in
//                    if (error != nil)
//                    {
//                        print("Leaderboard error : " + String(error?.localizedDescription))
//                    }
//                    else
//                    {
//                        self.leaderboardIdentifier = leaderboardIdentifier!
//                        
//                    }
//                });
//            }
//            
//        }
//    }
    
    //present the GameCenter VC
    @IBAction func showGameCenter(sender: AnyObject)
    {
        
        if gameKitHelper.gameCenterEnabled == true
        {
            let gcGameCenterViewController = GKGameCenterViewController()
            
            gcGameCenterViewController.gameCenterDelegate = self
            
            gcGameCenterViewController.viewState = GKGameCenterViewControllerState.Achievements
            
            gcGameCenterViewController.leaderboardIdentifier = gameKitHelper.leaderboardIdentifier
            
            presentViewController(gcGameCenterViewController, animated: true, completion: nil)
            
        }
        else
        {
            self.presentViewController(gameKitHelper.authenticationViewcontroller!, animated: true, completion: nil)
        }
    }
    
    //dismiss GameCenterVC upon exit
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Score & Achievements
    
    //increment score by 1 for each game played
//    func reportGamesPlayedScore()
//    {
//        
//        if GKLocalPlayer.localPlayer().authenticated
//        {
//            let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier!)
//            
//            gkScore.value = self.currentScore + 1
//            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error) -> Void in
//                if (error != nil)
//                {
//                    print("Error: " + (error?.localizedDescription)!)
//                }
//                else
//                {
//                    print("Score reported: \(gkScore.value)")
//                }
//            }))
//        }
//    }
    
//    func loadGamesPlayedScore()
//    {
//        
//        if GKLocalPlayer.localPlayer().authenticated
//        {
//            
//            // leaderboard for the current local player
//            let gkLeaderboard = GKLeaderboard(players: [GKLocalPlayer.localPlayer()])
//            gkLeaderboard.identifier = leaderboardIdentifier
//            
//            gkLeaderboard.loadScoresWithCompletionHandler({ (scores, error) -> Void in
//                var score: Int64 = 0
//                
//                if error == nil
//                {
//                    //check for value since scores is an optional
//                    
//                    if let scoresArray = scores
//                    {
//                        score = scoresArray[0].value
//                    }
//
//                    self.currentScore = score
//                }
//            })
//        }
//    }
    
    
}
