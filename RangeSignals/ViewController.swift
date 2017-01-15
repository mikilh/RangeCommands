//
//  ViewController.swift
//  RangeSignals
//
//  Created by Michael Kilhullen on 1/14/17.
//  Copyright © 2017 Kilhullenhome. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVAudioPlayer?
    var timer: Timer!
    var timerEnabled = false
    var seconds = 120
    var timeleft = 120
    var soundEffect: String?
    
    @IBOutlet weak var timerLabel: UILabel!

    @IBAction func prepareButton(_ sender: UIButton) {
        playSound(1)
    }
    @IBAction func shootButton(_ sender: UIButton) {
        playSound(0)
        startTimer()
    }
    @IBAction func retrieveAction(_ sender: Any) {
        playSound(2)
        resetTimer()
    }
    
    @IBAction func ceaseButton(_ sender: UIButton) {
        playSound(4)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "RangeCommands.timerSwitch") {
            timerEnabled = true
            seconds = defaults.integer(forKey: "RangeCommands.seconds")
            if seconds == 0 {
                timerEnabled = false
                timerLabel.text = "add time limit to settings"
            } else {
                timerLabel.text = "Timer set: \(seconds)"
            }
            
        } else {
            timerEnabled = false
            timerLabel.text = "unlimited time"
        }
        soundEffect = defaults.string(forKey: "RangeCommands.sound")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playSound(_ times: Int) {
        guard let url = Bundle.main.url(forResource: soundEffect, withExtension: "mp3") else {
            print("url not found")
            return
        }
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player!.numberOfLoops = times
            player!.enableRate = true
            if times > 3 {
                if soundEffect == "buzzer2" {
                    player!.rate = 2
                } else {
                    player!.rate = 4
                }
            }
            else {
                if soundEffect == "buzzer2" {
                    player!.rate = 1
                } else {
                    player!.rate = 2
                }
          }

            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func startTimer(){
        if timerEnabled {
            timeleft = seconds
            timer = Timer.scheduledTimer(timeInterval: 1.0 , target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    func timerRunning() {
        timeleft -= 1
        timerLabel.text = "Time remaining: \(timeleft)"
        if timeleft == 0 {
           retrieveAction(timerLabel)
            resetTimer()
        }
        
    }
    
    func resetTimer() {
        if timerEnabled {
            timer.invalidate()
            timerLabel.text = "Timer set: \(seconds)"
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if timer == nil {
            return true
        } else if timer.isValid {
            return false
        }
        return true
    }
}

