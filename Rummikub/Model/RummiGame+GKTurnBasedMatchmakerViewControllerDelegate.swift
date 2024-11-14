//
//  RummiGame+GKTurnBasedMatchmakerViewControllerDelegate.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/14.
//

import Foundation
import UIKit
import GameKit

extension RummiGame: GKTurnBasedMatchmakerViewControllerDelegate {
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
//        resetGame()
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: any Error) {
        print("Error: \(error.localizedDescription).")
        viewController.dismiss(animated: true)
//        resetGame()
    }
    
    
}
