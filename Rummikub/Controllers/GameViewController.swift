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
    
    var gameCode: String = ""
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    func updateLabels() {
        gameCodeLabel.text = "Game Code: \(gameCode)"
        db.collection("gameRooms").document(gameCode)
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
