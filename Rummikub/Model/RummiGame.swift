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
    @Published var board = Board()
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func resetGame() {
        // Reset the game data.
        playingGame = false
        myTurn = false
        currentMatchId = nil
        localParticipant = nil
        opponents = []
        board = Board()
        youWon = false
    }
    
    func getPlayerInformation() {

        GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
            if let image {
                self.localParticipant = Participant(player: GKLocalPlayer.local, avatar: image)
            } else {
                self.localParticipant = Participant(player: GKLocalPlayer.local)
            }
        }
        
        GKLocalPlayer.local.register(self)
    }
    
    func startMatch(with playersToInvite: [GKPlayer]) {
        
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
    
    func takeTurn() async {
        
        guard currentMatchId != nil else { return }
        
        do {
            let match = try await GKTurnBasedMatch.load(withID: currentMatchId!)
            
            let activeParticipants = match.participants.filter { $0.status != .done }
            
            if activeParticipants.count < 2 {
                // Set the match outcomes for active participants.
                for participant in activeParticipants {
                    participant.matchOutcome = .won
                }
                
                // End the match in turn.
                try await match.endMatchInTurn(withMatch: match.matchData!)
                
                // Notify the local player when the match ends.
                youWon = true
                // TODO: Implement custom end of match handling
            } else {
                // Upload move
                
                let gameData = (encodeGameData() ?? match.matchData)!
                let nextParticipants = activeParticipants.filter { $0 != match.currentParticipant }
                
                match.setLocalizableMessageWithKey("\(localParticipant?.player.alias ?? "A player") has made their move", arguments: nil)
                
                try await match.endTurn(withNextParticipants: nextParticipants, turnTimeout: GKTurnTimeoutDefault, match: gameData)
                
                myTurn = false
            }
        } catch {
            print("Error: \(error.localizedDescription).")
//            resetGame()
        }
    }
    
    func forfeitMatch() async {
        // Check whether there's an ongoing match.
        guard currentMatchId != nil else { return }

        do {
            let match = try await GKTurnBasedMatch.load(withID: currentMatchId!)
            
            // Forfeit the match while it's the local player's turn.
            if myTurn {
                
                // Create the game data to store in Game Center.
                let gameData = (encodeGameData() ?? match.matchData)!
                // Remove the participants who quit and the current participant.
                let nextParticipants = match.participants.filter {
                  ($0.status != .done) && ($0 != match.currentParticipant)
                }

                // Forfeit the match.
                try await match.participantQuitInTurn(
                    with: GKTurnBasedMatch.Outcome.quit,
                    nextParticipants: nextParticipants,
                    turnTimeout: GKTurnTimeoutDefault,
                    match: gameData)
                
            } else {
                // Forfeit the match while it's not the local player's turn.
                try await match.participantQuitOutOfTurn(with: GKTurnBasedMatch.Outcome.quit)
            }
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func sendReminder() async {
        // Check whether there's an ongoing match.
        guard currentMatchId != nil else { return }
        
        do {
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchId!)
            
            // Create an array containing the current participant.
            let participants = match.participants.filter {
                $0 == match.currentParticipant
            }
            
            // Send a reminder to the current participant.
            try await match.sendReminder(to: participants, localizableMessageKey: "Hurry up! You're taking ages",
                                         arguments: [])
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
}
