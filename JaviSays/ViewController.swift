//
//  ViewController.swift
//  JaviSays
//
//  Created by Javier Giner Alvarez on 14/10/2019.
//  Copyright © 2019 Javier Giner Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var contentGameView: UIView!
    
    @IBOutlet var colorButtons: [CircularButton]!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet var playerLabels: [UILabel]!
    @IBOutlet var scoreLabels: [UILabel]!
    
    @IBOutlet weak var soundButton: CircularButton!
    
    var currentPlayer = 0
    var scores = [0,0]
    var sequenceIndex = 0
    var colorSequence = [Int]()
    var colorsToTap = [Int]()
    
    var gameEnded = false
    
    var player: AVAudioPlayer?
    var isMuted = false
    var volumen: Float = 1.0
    let soundActiveImage = UIImage(systemName: "speaker.2")
    let soundInactiveImage = UIImage(systemName: "speaker.slash")
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isMuted = defaults.bool(forKey: "Muted")
        
        if isMuted  {
            soundButton.setImage(soundInactiveImage, for: .normal)
        } else {
            soundButton.setImage(soundActiveImage, for: .normal)
        }
        
        colorButtons = colorButtons.sorted() { $0.tag < $1.tag }
        playerLabels = playerLabels.sorted() { $0.tag < $1.tag }
        scoreLabels = scoreLabels.sorted() { $0.tag < $1.tag }
        
        createNewGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameEnded {
            gameEnded = false
            createNewGame()
        }
    }
    
    private func createNewGame() {
        colorSequence.removeAll()
        
        actionButton.setTitle("Empezar Partida", for: .normal)
        actionButton.isEnabled = true
        for button in colorButtons {
            button.alpha = 0.4
            button.isEnabled = false
        }
        
        currentPlayer = 0
        scores = [0,0]
        playerLabels[currentPlayer].alpha = 1.0
        playerLabels[1].alpha = 0.75
        updateScoreLabels()
    }
    
    private func updateScoreLabels(){
        for (index,labels) in scoreLabels.enumerated(){
            labels.text = "\(scores[index])"
        }
    }
    
    private func switchPlayers(){
        playerLabels[currentPlayer].alpha = 0.75
        currentPlayer = currentPlayer == 0 ? 1 : 0
        playerLabels[currentPlayer].alpha = 1.0
    }
    
    private func addNewColor(){
        colorSequence.append(Int(arc4random_uniform(UInt32(4))))
    }
    
    private func playSecuence(){
        if sequenceIndex < colorSequence.count {
            flash(button: colorButtons[colorSequence[sequenceIndex]])
            sequenceIndex += 1
        } else {
            colorsToTap = colorSequence
            contentGameView.isUserInteractionEnabled = true
            actionButton.setTitle("Reproduce la secuencia!", for: .normal)
            for button in colorButtons{
                button.isEnabled = true
            }
        }
    }
    
    private func flash(button: CircularButton) {
        soundThisNote(note: "note\(button.tag)")
        UIView.animate(withDuration: 1, animations: {
            button.alpha = 1.0
            button.alpha = 0.4
        }) { (bool) in
            self.playSecuence()
        }
    }
    
    private func endGame(){
        let message = currentPlayer == 0 ? "Jugador 2 Gana!" : "Jugador 1 Gana!"
        actionButton.setTitle(message, for: .normal)
        gameEnded = true
    }
    
    private func soundThisNote(note : String){
        if !isMuted {
            if let xylophoneSound = Bundle.main.url(forResource: note, withExtension: "wav") {
                print(note)
                do {
                    player = try AVAudioPlayer(contentsOf: xylophoneSound, fileTypeHint: AVFileType.wav.rawValue)
                    player?.play()
                    
                } catch let error as NSError {
                    print(error.description)
                }
            }
        }
    }

    @IBAction func colorButtonHandller(_ sender: CircularButton) {
        soundThisNote(note: "note\(sender.tag)")
        if sender.tag == colorsToTap.removeFirst() {
            
        } else {
            for button in colorButtons {
                button.isEnabled = false
            }
            endGame()
            return
        }
        if colorsToTap.isEmpty {
            for button in colorButtons {
                button.isEnabled = false
            }
            scores[currentPlayer] += 1
            updateScoreLabels()
            switchPlayers()
            actionButton.setTitle("Continua Jugador \(currentPlayer + 1)", for: .normal)
            actionButton.isEnabled = true
        }
    }
    
    @IBAction func actionButtonHandler(_ sender: UIButton) {
        sequenceIndex = 0
        actionButton.setTitle("Memoriza Ahora!", for: .normal)
        actionButton.isEnabled = false
        contentGameView.isUserInteractionEnabled = false
        addNewColor()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(1)) {
            self.playSecuence()
        }
    }
    
    @IBAction func enableDisableSoundAction(_ sender: UIButton) {
        enableDisableSound(button: sender)
        switchMuted()
    }

    private func enableDisableSound(button: UIButton) {
        if isMuted  {
            button.setImage(soundActiveImage, for: .normal)
        } else {
            button.setImage(soundInactiveImage, for: .normal)
        }
    }
    
    private func switchMuted(){
        isMuted = !isMuted
        defaults.set(isMuted, forKey: "Muted")
    }
    
}

