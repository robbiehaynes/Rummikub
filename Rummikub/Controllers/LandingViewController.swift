//
//  ViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/11.
//

import UIKit
import GameKit
import FirebaseAuth

class LandingViewController: UIViewController {

    @IBOutlet weak var multiplayerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        signUserIntoGameCenter()
    }
    
    @IBAction func multiplayerPressed(_ sender: UIButton) {
        
        GameCenterAuthProvider.getCredential { credential, error in
            if let error {
                print("Error getting credential: \(error)")
                let alert = UIAlertController(
                    title: "Oh no!",
                    message: "There was an error getting your GameCenter credentials. Please try again.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if let credential {
                self.signUserIntoFirebase(withCred: credential)
            } else {
                print("No credentials")
                return
            }
            
        }
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
                    self.multiplayerButton.isHidden = true
                }
            }
            
        }
    }
    
    func signUserIntoFirebase(withCred credential: AuthCredential) {
        
        if GKLocalPlayer.local.isAuthenticated {
                
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    print("Error signing in to with credential: \(error)")
                    let alert = UIAlertController(
                        title: "Oh no!",
                        message: "There was an error signing into Firebase with your GameCenter credentials. Please try again.",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                print("User signed in")
                self.performSegue(withIdentifier: "goToMultiplayer", sender: self)
            }
            
        } else {
            
            let alert = UIAlertController(
                title: "Oh no!",
                message: "You are not authenticated with GameCenter. Please sign in and then continue.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

