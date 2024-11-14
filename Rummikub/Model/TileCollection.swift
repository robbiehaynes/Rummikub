//
//  TileCollection.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/14.
//

import Foundation

enum CollectionType {
    case run
    case group
    case invalid
}

struct Tile : Codable {
    let value: Int
    let colour: UIColor
    
    init(value: Int, colour: UIColor) {
        self.value = value
        self.colour = colour
    }
}

struct TileCollection: Codable {
    
    private var tiles: [Tile]
    
    var type: CollectionType {
        return determineType()
    }
    
    mutating func addTile(_ tile: Tile) {
        tiles.append(tile)
    }
    
    mutating func popTile(withValue value: Int, withColour colour: UIColor) -> Tile? {
        return tiles.first { $0.value == value && $0.colour == colour }
    }
    
    private func determineType() -> CollectionType {
        if tiles.isEmpty { return .invalid }
        
        if validateGroup() { return .group }
        if validateRun() { return .run }
        
        return .invalid
    }
    
    private func validateGroup() -> Bool {
        guard let firstValue = tiles.first?.value else { return false }
        let uniqueColors = Set(tiles.map { $0.colour })
        
        return tiles.allSatisfy { $0.value == firstValue } && uniqueColors.count == tiles.count && tiles.count >= 3
    }
    
    private func validateRun() -> Bool {
        guard let firstColor = tiles.first?.colour else { return false }
        let sortedValues = tiles.map { $0.value }.sorted()
        
        let isSequential = zip(sortedValues, sortedValues.dropFirst()).allSatisfy { $1 == $0 + 1 }
        return cards.allSatisfy { $0.colour == firstColor } && isSequential && tiles.count >= 3
    }
}
