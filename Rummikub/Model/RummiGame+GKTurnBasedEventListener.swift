//
//  RummiGame+GKTurnBasedEventListener.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/15.
//

import UIKit
import GameKit

extension RummiGame: GKTurnBasedEventListener {
    
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        startMatch(with: playersToInvite)
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        switch match.status {
        case .open:
            Task {
                do {
                    // TODO: If the match is open, first check whether game play should continue.
                    
                    // Remove participants who quit or otherwise aren't in the match.
                    let nextParticipants = match.participants.filter { $0.status != .done }
                    
                    // End the match if active participants drop below the minimum.
                    if nextParticipants.count < 2 {
                        // Set the match outcomes for the active participants.
                        for participant in nextParticipants {
                            participant.matchOutcome = .won
                        }
                        
                        // End the match in turn.
                        try await match.endMatchInTurn(withMatch: match.matchData!)
                        
                        // Notify the local player when the match ends.
                        youWon = true
                    }
                    else if (currentMatchId == nil) || (currentMatchId == match.matchID) {
                        // If the local player isn't playing another match or is playing this match,
                        // display and update the game view.
                        
                        // Display the game view for this match.
                        playingGame = true
                        
                        // Update the interface depending on whether it's the local player's turn.
                        myTurn = GKLocalPlayer.local == match.currentParticipant?.player ? true : false
                        
                        // Remove the local player from the participants to find the opponent.
                        let participants = match.participants.filter {
                            self.localParticipant?.player.displayName != $0.player?.displayName
                        }
                        
                        // If the player starts the match, the opponent hasn't accepted the invitation and has no player object.
                        if !participants.isEmpty {
                            for participant in participants {
                                if (participant.status != .matching) && (participant.player != nil) {
                                    // Load the opponent's avatar and create the opponent object.
                                    let image = try await participant.player?.loadPhoto(for: GKPlayer.PhotoSize.small)
                                    opponents.append(Participant(player: (participant.player)!, avatar: image!))
                                    
                                    // Restore the current game data from the match object.
                                    //                                decodeGameData(matchData: match.matchData!)
                                }
                            }
                        }
                        
                        // Retain the match ID so action methods can load the current match object later.
                        currentMatchId = match.matchID
                    }
                    
                } catch {
                    // Handle the error.
                    print("Error: \(error.localizedDescription).")
                }
            }
        case .ended:
            print("Match ended.")
            
        case .matching:
            print("Still finding players.")
            
        default:
            print("Status unknown.")
        }
    }
    
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        // Remove the current participant. If the count drops below the minimum, the next participant ends the match.
        let nextParticipants = match.participants.filter { $0 != match.currentParticipant }
        
        // Quit while it's the local player's turn.
        match.participantQuitInTurn(with: GKTurnBasedMatch.Outcome.quit, nextParticipants: nextParticipants,
                                    turnTimeout: GKTurnTimeoutDefault, match: match.matchData!)
    }
    
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        let content = UNMutableNotificationContent()
        content.title = "Game has ended"
        content.body = "The game is over, thanks for playing"
        // Create a notification trigger for 60 seconds in the future.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0, repeats: false)
        // Create the request with the content and the trigger.
        let request = UNNotificationRequest(identifier: "com.haynoway.rummiGameEnded", content: content, trigger: trigger)
    }
}
