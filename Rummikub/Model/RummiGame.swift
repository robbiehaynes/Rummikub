//
//  RummiGame.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/14.
//

import Foundation
import GameKit
import UIKit

class RummiGame: NSObject, GKMatchDelegate, GKLocalPlayerListener, ObservableObject {
    
    // Interface state
    @Published var myTurn = false
    @Published var playingGame = false
    
    // Outcomes
    @Published var youWon = false
    
    // Match Information
    @Published var currentMatchId: String? = nil
    
    // Persistent Game Data
    @Published var localParticipant: Participant? = nil
    @Published var opponents: [Participant] = []
    @Published var board: Board? = nil
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func getPlayerInformation(remotePlayers: [GKPlayer]) {

        GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
            if let image {
                self.localParticipant = Participant(player: GKLocalPlayer.local, avatar: image)
            } else {
                self.localParticipant = Participant(player: GKLocalPlayer.local)
            }
        }
        
        for remotePlayer in remotePlayers {
            remotePlayer.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    self.opponents.append(Participant(player: remotePlayer, avatar: image))
                } else {
                    self.opponents.append(Participant(player: remotePlayer))
                }
            }
        }
        
        GKLocalPlayer.local.register(self)
    }
    
    func startMatch(playersToInvite: [GKPlayer]) {
        
        getPlayerInformation(remotePlayers: playersToInvite)
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        request.recipients = playersToInvite
        
        // Present the interface where the player selects opponents and starts the game.
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        viewController.turnBasedMatchmakerDelegate = self
        rootViewController?.present(viewController, animated: true) { }
    }
    
    func removeMatches() async {
        do {
            // Load all the matches.
            let existingMatches = try await GKTurnBasedMatch.loadMatches()
            
            // Remove all the matches.
            for match in existingMatches {
                try await match.remove()
            }
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        
    }
}
