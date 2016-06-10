//
//  GameKitHelper.swift
//  swiftris
//
//  Created by Melissa Boring on 6/10/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import GameKit

class GameKitHelper: NSObject {
    
    var authenticationViewcontroller: UIViewController?
    
    var gameCenterEnabled:Bool! = false
    var leaderboardIdentifier:String?
    var localPlayer:GKLocalPlayer!
    
    func authenticateLocalPlayer()
    {
        localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            //if ((viewController) != nil)
            if let gameKitViewcontroller: UIViewController = viewController
            {
                self.setAuthenticationViewController(gameKitViewcontroller)
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
    }
    

}
