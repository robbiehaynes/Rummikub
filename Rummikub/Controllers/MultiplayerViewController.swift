//
//  MultiplayerViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/12.
//

import UIKit
import FirebaseFirestore

class MultiplayerViewController: UIViewController {

    @IBOutlet weak var joinCodeTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createButtonPressed(_ sender: UIButton) {
        Task {
            do {
                let gameRoom = try await GameRoom.create()
                try await gameRoom.save()
                UserDefaults.standard.set(gameRoom.gameCode, forKey: "currentMultiplayerGame")
            } catch {
                print("Error creating game room: \(error)")
            }
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        let gameCode = joinCodeTextField.text ?? ""
        
        Task {
            do {
                let gameRoom = try await GameRoom.fetchGameRoom(withCode: gameCode)
                if let gameRoom {
                    try await gameRoom.join()
                    UserDefaults.standard.set(gameRoom.gameCode, forKey: "currentMultiplayerGame")
                }
            } catch {
                print("Error fetching/joining game room: \(error)")
            }
        }
    }
}
