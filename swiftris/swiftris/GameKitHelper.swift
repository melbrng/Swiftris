//
//  GameKitHelper.swift
//  swiftris
//
//  Created by Melissa Boring on 6/10/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import GameKit


class GameKitHelper {
    
    var authenticationViewcontroller: UIViewController?
    
    var gameCenterEnabled:Bool! = false
    var leaderboardIdentifier:String?
    var localPlayer:GKLocalPlayer!
    var currentScore:Int64 = 0
    
    func authenticateLocalPlayer()
    {
        localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil)
            //if let gameKitViewcontroller: UIViewController = viewController
            {
                print("setAuthenticationViewController")
                self.setAuthenticationViewController(viewController!)
            }
            else
            {
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                self.gameCenterEnabled = true
                
                // Get the default leaderboard
                self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) in
                    if (error != nil)
                    {
                        print("Leaderboard error : " + String(error?.localizedDescription))
                    }
                    else
                    {
                        self.leaderboardIdentifier = leaderboardIdentifier!
                        
                    }
                });
            }
            
        }
    }
    
    
    func setAuthenticationViewController(authentication: UIViewController)
    {
        authenticationViewcontroller = authentication
        
        print("debugDescription : " + authenticationViewcontroller.debugDescription)

    }
    
    // MARK: Score & Achievements
    
    //increment score by 1 for each game played
    func reportGamesPlayedScore()
    {
        
        if GKLocalPlayer.localPlayer().authenticated
        {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier!)
            
            gkScore.value = self.currentScore + 1
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
    
    func loadGamesPlayedScore()
    {
        
        if GKLocalPlayer.localPlayer().authenticated
        {
            
            // leaderboard for the current local player
            let gkLeaderboard = GKLeaderboard(players: [GKLocalPlayer.localPlayer()])
            gkLeaderboard.identifier = leaderboardIdentifier
            
            gkLeaderboard.loadScoresWithCompletionHandler({ (scores, error) -> Void in
                var score: Int64 = 0
                
                if error == nil
                {
                    //check for value since scores is an optional
                    
                    if let scoresArray = scores
                    {
                        score = scoresArray[0].value
                    }
                    
                    self.currentScore = score
                }
            })
        }
    }
    
    func loadAchievements()
    {
        
        GKAchievement.loadAchievementsWithCompletionHandler() { achievements, error in
            guard let achievements = achievements else { return }
            
            print(achievements)
        }
    }
    

}
