//
//  GameCenterHelper.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/20.
//

import GameKit

final class GameCenterHelper: NSObject {
    typealias CompletionBlock = (Error?) -> Void
    
    static let helper = GameCenterHelper()
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    var viewController: UIViewController?
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            
            NotificationCenter.default.post(
                name: .authenticationChanged,
                object: (GKLocalPlayer.local.isAuthenticated && !GKLocalPlayer.local.isMultiplayerGamingRestricted))
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            }
            else {
                let alert = UIAlertController(
                    title: "Oh no!",
                    message: "There was an error authenticating your GameCenter credentials. Please try again.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.viewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        
        request.inviteMessage = "Would you like to play Rummikub?"
        
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        currentMatchmakerVC = vc
        viewController?.present(vc, animated: true)
    }
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}

extension GameCenterHelper: GKLocalPlayerListener {
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        // Remove the current participant. If the count drops below the minimum, the next participant ends the match.
        let nextParticipants = match.participants.filter { $0 != match.currentParticipant }
        
        // Quit while it's the local player's turn.
        match.participantQuitInTurn(with: GKTurnBasedMatch.Outcome.quit, nextParticipants: nextParticipants,
                                    turnTimeout: GKTurnTimeoutDefault, match: match.matchData!)
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        if let vc = currentMatchmakerVC {
          currentMatchmakerVC = nil
          vc.dismiss(animated: true)
        }

        guard didBecomeActive else { return }
        
        NotificationCenter.default.post(name: .presentGame, object: match)
    }
}



extension Notification.Name {
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
