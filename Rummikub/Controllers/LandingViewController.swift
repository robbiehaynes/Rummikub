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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        signUserIntoGameCenter()
    }
    
    @IBAction func multiplayerPressed(_ sender: UIButton) {
        
    }
    
    func signUserIntoGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if viewController != nil {
                return
            }
            
            if error != nil {
                let alert = UIAlertController(
                    title: "Oh no!",
                    message: "There was an error authenticating your GameCenter credentials. Please try again.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                
                if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                    self.multiplayerButton.isEnabled = false
                }
            }
            
        }
    }
}

