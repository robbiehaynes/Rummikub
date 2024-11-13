//
//  GameViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/12.
//

import UIKit
import FirebaseFirestore

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameCodeLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    
    var gameRoom: GameRoom?
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func leaveRoomPressed(_ sender: UIButton) {
        if let gameRoom {
            gameRoom.leave()
        }
    }
    
    func updateLabels() {
        if let gameRoom {
            gameCodeLabel.text = "Game Code: \(gameRoom.gameCode)"
            db.collection("gameRooms").document(gameRoom.gameCode)
                .addSnapshotListener { documentSnapshot, error in
                    
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let players = data["players"] as! [String]
                    self.playerLabel.text = "Players:\n"
                    players.forEach { player in
                        self.playerLabel.text?.append("\(player)\n")
                    }
                }
        }
        
    }

}
