//
//  RummiGame+MatchData.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/15.
//

import Foundation

struct GameData : Codable {
    var playerHands: [String:[Tile]]
    var board: Board
    
    init(playerHands: [String:[Tile]] = [:], board: Board = Board()) {
        self.playerHands = playerHands
        self.board = board
    }
    
    func encode() -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
}

extension RummiGame {
    
    func encodeGameData() -> Data? {
        
        var playerHands = [String:[Tile]]()
        
        // Add the local player's tile count.
        if let localPlayerName = localParticipant?.player.displayName {
            playerHands[localPlayerName] = localParticipant?.tiles
        }
        
        if !opponents.isEmpty {
            for opponent in opponents {
                playerHands[opponent.player.displayName] = opponent.tiles
            }
        }
        
        let gameData = GameData(playerHands: playerHands, board: board)
        return encode(gameData: gameData)
    }
    
    func encode(gameData: GameData) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(gameData)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
    
    func decodeGameData(matchData: Data) {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        guard let gameData = gameData else { return }
        
        // Set the match count.
        board = gameData.board
        
        // Set the local player's items.
        if let localPlayerName = localParticipant?.player.displayName {
            if let tiles = gameData.playerHands[localPlayerName] {
                localParticipant?.tiles = tiles
            }
        }
        
        // for each opponent set their tiles
        for i in 0..<opponents.count {
            if let tiles = gameData.playerHands[opponents[i].player.displayName] {
                opponents[i].tiles = tiles
            }
        }
    }
}
