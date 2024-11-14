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

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func leaveRoomPressed(_ sender: UIButton) {
        
    }
    
    func updateLabels() {
        
    }

}
