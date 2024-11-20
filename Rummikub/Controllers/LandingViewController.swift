//
//  ViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/11.
//

import UIKit
import GameKit

class LandingViewController: UIViewController {

    @IBOutlet weak var multiplayerButton: UIButton!
    
    var game: RummiGame? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GameCenterHelper.helper.viewController = self
        
        multiplayerButton.isEnabled = GameCenterHelper.isAuthenticated
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(authenticationChanged(_:)),
          name: .authenticationChanged,
          object: nil
        )
    }
    
    @IBAction func multiplayerPressed(_ sender: UIButton) {
        GameCenterHelper.helper.presentMatchmaker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameViewController {
            print("Sending game to GameViewController")
            gameVC.game = game!
        }
    }
    
    // MARK: - Notifications

    @objc private func authenticationChanged(_ notification: Notification) {
        multiplayerButton.isEnabled = notification.object as? Bool ?? false
    }
    
    @objc private func presentGame(_ notification: Notification) {
        guard let match = notification.object as? GKTurnBasedMatch else { return }
        
        loadAndDisplay(match: match)
    }
    
    //MARK: - Helpers
    private func loadAndDisplay(match: GKTurnBasedMatch) {
        // TODO: Implement this function
    }
}

