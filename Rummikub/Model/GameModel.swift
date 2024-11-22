//
//  GameModel.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/21.
//

import GameKit

struct GameModel : Codable {
    var playerHands: [String:[Tile]]
    var board: Board
    var winner: String? = nil
    
    init(playerHands: [String:[Tile]] = [:], board: Board = Board()) {
        self.playerHands = playerHands
        self.board = board
    }
    
    mutating func drawFromPile(forPlayer player: String) {
        if let tile = board.draw() {
            // Add tile to the players' hand
            if playerHands[player] == nil {
                playerHands[player] = []
            }
            playerHands[player]!.append(tile)
            
            if board.drawPile.count == 0 {
                print("You win!")
                winner = player
            }
        } else {
            // No tiles left
            print("No tiles left")
        }
    }
    
    mutating func instantiatePlayers(localPlayer: String, opponents: [String] = [])
    {
        if playerHands[localPlayer] == nil {
            playerHands[localPlayer] = []
        }
        opponents.forEach {
            if playerHands[$0] == nil {
                playerHands[$0] = []
            }
        }
    }
}
