//
//  GameViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/12.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameCodeLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    
    var game: RummiGame?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        
        if let game = game {
            gameCodeLabel.text = game.currentMatchId
            playerLabel.text = game.localParticipant?.player.alias
            
            print(game.board.collections)
            print(game.board.drawPile)
        } else {
            print("Im here")
        }
    }
    
    @IBAction func leaveRoomPressed(_ sender: UIButton) {
        Task {
            await game?.forfeitMatch()
            self.dismiss(animated: true)
        }
    }

}
