//
//  GameKitHelper.swift
//  swiftris
//
//  Created by Melissa Boring on 6/10/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import GameKit

class GameKitHelper {
    
    //singleton
    static let sharedInstance = GameKitHelper()
    
    //override init so noone else can
    private init() {}

    var authenticationViewcontroller: UIViewController?
    var gameCenterEnabled:Bool! = false
    var leaderboardIdentifier:String?
    var localPlayer:GKLocalPlayer!
    var currentScore:Int64 = 0
    
     // MARK: Authenticate player
    
    func authenticateLocalPlayer()
    {
        localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil)
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
    
    // MARK: Achievement
    
    func updateRowsAddedAchievement(linesRemovedCount: Int)
    {
        print("updateRowsAddedAchievement : " + String(linesRemovedCount))
        
        //achievements
        //20 pts
        let rows5AddedAchievement = GKAchievement(identifier: "grp.rows_completed")
        //60 pts
        let rows20AddedAchievement = GKAchievement(identifier: "grp.20_rows_completed")
        //100 pts
        let rows100AddedAchievement = GKAchievement(identifier: "grp.100_rows_completed")
        
        //calculate percent complete
        rows5AddedAchievement.percentComplete = Double((linesRemovedCount * 4)*100/20)
        rows20AddedAchievement.percentComplete = Double((linesRemovedCount * 3)*100/60)
        rows100AddedAchievement.percentComplete = Double((linesRemovedCount * 1)*100/100)
        
        rows5AddedAchievement.showsCompletionBanner = true
        rows20AddedAchievement.showsCompletionBanner = true
        rows100AddedAchievement.showsCompletionBanner = true
        
        GKAchievement.reportAchievements([rows5AddedAchievement,rows20AddedAchievement,rows100AddedAchievement], withCompletionHandler:( { (error) -> Void in
            if (error != nil)
            {
                print("Report Achievements Error: " + (error?.localizedDescription)!)
            }
            else
            {
                print("Achievement reported")
            }
        }))
        
        
    }
    
    func loadAchievements()
    {
        
        
        GKAchievement.loadAchievementsWithCompletionHandler() { achievements, error in
            guard let achievements = achievements else { return }
            
            if achievements.count > 0
            {
                let rowsCompleted: GKAchievement = achievements[0]
                
                print(String(rowsCompleted.percentComplete))
                
                print(achievements)
            }
            
        }
    }
    
    func resetAchievements()
    {
        
        GKAchievement.resetAchievementsWithCompletionHandler(nil)
    }
    

}
