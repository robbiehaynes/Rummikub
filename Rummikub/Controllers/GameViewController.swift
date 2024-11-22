//
//  GameViewController.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/12.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var handLabel: UILabel!
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var drawTileButton: UIButton!
    @IBOutlet weak var endTurnButton: UIButton!
    
    var gameModel: GameModel? = nil
    
    private var isSendingTurn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func drawTilePressed(_ sender: Any) {
        gameModel?.drawFromPile(forPlayer: GameCenterHelper.helper.localAlias!)
        
        updateUI()
    }
    
    @IBAction func endTurnPressed(_ sender: Any) {
        processGameUpdate()
    }
    
    @IBAction func leaveRoomPressed(_ sender: UIButton) {
        Task {
            if let gameModel {
                await GameCenterHelper.helper.forfeitMatch(gameModel) { error in
                    defer {
                        self.isSendingTurn = false
                    }
                    
                    if let error {
                        print("Error forfeiting game: \(error.localizedDescription)")
                        return
                    }
                    
                    self.dismiss(animated: true)
                }
            }
        }
    }

    private func updateUI() {
        drawTileButton.isEnabled = !isSendingTurn && GameCenterHelper.helper.canTakeTurnForCurrentMatch
        endTurnButton.isEnabled = !isSendingTurn && GameCenterHelper.helper.canTakeTurnForCurrentMatch
        
        if let safeGameModel = gameModel {
            // Game Label
            let opponents = safeGameModel.playerHands.keys.filter { $0 != GameCenterHelper.helper.localAlias }
            var gameLabelText = "Game against "
            opponents.forEach { opp in
                gameLabelText.append("\(opp), ")
            }
            gameLabelText.append("\n\nDraw Pile: \(safeGameModel.board.drawPile.count) left")
            
            // Hand Label
            let localHand = safeGameModel.playerHands[GameCenterHelper.helper.localAlias!] ?? []
            var handLabelText = "Your Hand: \(localHand.count)"
            localHand.forEach { tile in
                handLabelText.append("\n\(tile)")
            }
            
            gameLabel.text = gameLabelText
            handLabel.text = handLabelText
        } else {
            print("GameModel not yet set.")
        }
    }
    
    private func processGameUpdate() {
        isSendingTurn = true
        
        guard let gameModel else { return }
        
        if gameModel.winner != nil {
            GameCenterHelper.helper.win { error in
                defer {
                    self.isSendingTurn = false
                }
                
                if let error {
                    print("Error winning match: \(error.localizedDescription)")
                    return
                }
                
                self.dismiss(animated: true)
            }
        } else {
            GameCenterHelper.helper.endTurn(gameModel) { error in
                defer {
                    self.isSendingTurn = false
                }
                
                if let error {
                    print("Error ending turn: \(error.localizedDescription)")
                    return
                }
                
                self.dismiss(animated: true)
            }
        }
    }
}
