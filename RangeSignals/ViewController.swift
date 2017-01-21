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

    // MARK: - Actions
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
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "RangeCommands.timerSwitch") {
            timerEnabled = true
            seconds = defaults.integer(forKey: "RangeCommands.seconds")
            updateTimerLabel(seconds)
            
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if timer == nil {
            return true
        } else if timer.isValid {
            return false
        }
        return true
    }
    
    // MARK: - methods

    func playSound(_ thisManyTimes: Int) {
        guard let url = Bundle.main.url(forResource: soundEffect, withExtension: "mp3") else {
            print("url not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            player!.numberOfLoops = thisManyTimes
            player!.enableRate = true
            
            // for cease fire, make the sounds more rapid
            if thisManyTimes > 3 {
                if soundEffect == "buzzer2" { //adjustment for specific sound length
                    player!.rate = 2
                } else {
                    player!.rate = 4
                }
            }
            else {
                if soundEffect == "buzzer2" { //adjustment for specific sound length
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
    
    /// start thie timer
    fileprivate func startTimer(){
        if timerEnabled {
            timeleft = seconds
            timer = Timer.scheduledTimer(timeInterval: 1.0 , target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    /// timer selector
    func timerRunning() {
        timeleft -= 1
        if timeleft == 0 {
           retrieveAction(timerLabel)
            resetTimer()
            return
        }
        
        updateTimerLabel(timeleft)
    }
    
    /// update the timer label to appear as a clock
    fileprivate func updateTimerLabel(_ timeInSeconds: Int){
        
        var minutes, seconds: Int
        
        minutes = (timeInSeconds / 60 )
        seconds = timeInSeconds - minutes * 60
        
        timerLabel.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        
    }
    /// reset the timer
    fileprivate func resetTimer() {
        if timerEnabled && timer != nil {
            timer.invalidate()
            updateTimerLabel(seconds)
        }
        
    }
    
}

