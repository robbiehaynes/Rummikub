//
//  Participant.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/14.
//

import UIKit
import GameKit

struct Participant : Identifiable {
    var id = UUID()
    var player: GKPlayer
    var tiles: [Tile] = []
    var avatar = UIImage(named: "person.crop.circle")
}
