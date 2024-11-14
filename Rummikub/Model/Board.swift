//
//  Board.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/14.
//

import UIKit

struct Board: Codable {
    var collections: [TileCollection] = []
    var drawPile: [Tile] = []
    
    init() {
        drawPile = generatePile()
        drawPile.shuffle()
    }
    
    mutating func draw() -> Tile? {
        guard !drawPile.isEmpty else { return nil }
        return drawPile.removeLast()
    }
    
    mutating func addCollection(_ collection: TileCollection) {
        collections.append(collection)
    }
    
    private func generatePile() -> [Tile] {
        var pile : [Tile] = []
        // for each colour, 1 up to incl. 13, twice
        let availableColours : [String] = ["red", "green", "blue", "yellow"]
        
        for colour in availableColours {
            for num in 1...13 {
                let tile = Tile(value: num, colour: colour)
                let tile2 = Tile(value: num, colour: colour)
                pile.append(tile)
                pile.append(tile2)
            }
        }
        
        // Two Jokers
        pile.append(Tile(value: 20, colour: "black"))
        pile.append(Tile(value: 20, colour: "black"))
        
        return pile
    }
}
