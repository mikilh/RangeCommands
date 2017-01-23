//
//  ViewController.swift
//  RangeSignals
//
//  Created by Michael Kilhullen on 1/14/17.
//  Copyright © 2017 Kilhullenhome. All rights reserved.
//

// TODO: toggle button display to indicate that it's not enabled

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVAudioPlayer?
    var timer: Timer?
    var timerEnabled = false
    var seconds = 120
    var timeleft = 120
    var soundEffect: String?
    var timerPaused = false
    
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var shootButton: UIButton!
    @IBOutlet weak var ceasefireButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pauseLabel: UILabel!
    @IBOutlet weak var adjustTimerStepper: UIStepper!
    @IBOutlet weak var resetTimerButton: UIButton!
    @IBOutlet weak var optionsButton: UIBarButtonItem!

    // MARK: - Actions
    
    /// prepare to shoot makes two sounds
    @IBAction func prepareButton(_ sender: UIButton) {
        playSound(1)
    }
    
    /// shoot button makes one sound and starts/resumes the time if enabled
    @IBAction func shootButton(_ sender: UIButton) {
        playSound(0)
        if timerEnabled {
            if timerPaused {
                resumeTimer()
            } else {
                startTimer()
            }
        }
    }
    // retrieve button makes three tones and resets the timer if enabled
    @IBAction func retrieveAction(_ sender: Any) {
        playSound(2)
        if timerEnabled {
            if timerPaused {
                resumeTimer()
            }
         resetTimer()
        }
    }
    
    /// cease fire button makes 5 more rapid tones and pauses the timer if enabled
    @IBAction func ceaseButton(_ sender: UIButton) {
        playSound(4)
        if timerEnabled {
            if timer != nil {
                pauseTimer()
            }
        }
    }
    
    // action to pause the timer without sending tones
    @IBAction func timerTapped(_ sender: UITapGestureRecognizer) {
        if timerEnabled && timer != nil {
            if timerPaused {
                resumeTimer()
            } else {
                pauseTimer()
            }
        }
        
    }
    
    /// when the timer is paused, the user can optionally add or remove time 
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        timeleft = Int(sender.value)
        updateTimerLabel(timeleft)
    }
    
    // when timer is paused, the user can optionally reset the time
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        timeleft = seconds
        updateTimerLabel(timeleft)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the stepper
        adjustTimerStepper.minimumValue = 5
        adjustTimerStepper.maximumValue = 300
        adjustTimerStepper.stepValue = 1.0
        
    }
    
    /// gets defaults and sets up the ui
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
        pauseLabel.text = nil 
        soundEffect = defaults.string(forKey: "RangeCommands.sound")
    }
    
    // MARK: - methods

    /// plays a sound a certain number of times
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
    
    /// start the timer
    func startTimer(){
        if timerPaused{
            resumeTimer()
        } else {
            timeleft = seconds
            timer = Timer.scheduledTimer(timeInterval: 1.0 , target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
        //once the timer starts, disable  buttons
        lineButton.isEnabled = false
        shootButton.isEnabled = false
        optionsButton.isEnabled = false
        
    }
    
    /// pause the timer
    func pauseTimer(){
        timerPaused = true
        pauseLabel.text = "PAUSED"
        pauseLabel.startBlink()
        lineButton.isEnabled = true
        shootButton.isEnabled = true
        resetTimerButton.isHidden = false
        adjustTimerStepper.value = Double(timeleft)
        adjustTimerStepper.isHidden = false
   }
    
    /// resume the timer
    func resumeTimer(){
        timerPaused = false
        pauseLabel.text = nil
        pauseLabel.stopBlink()
        lineButton.isEnabled = false
        shootButton.isEnabled = false
        resetTimerButton.isHidden = true
        adjustTimerStepper.isHidden = true
    }
    
    /// timer selector
    func timerRunning() {
        if !timerPaused {
            timeleft -= 1
            if timeleft == 0 {
                retrieveAction(timerLabel)
                resetTimer()
                return
            }
            updateTimerLabel(timeleft)
        }
    }
    
    /// reset the timer
    func resetTimer() {
        if timerEnabled && timer != nil {
            timer!.invalidate()
            timer = nil
            updateTimerLabel(seconds)
            lineButton.isEnabled = true
            shootButton.isEnabled = true
            optionsButton.isEnabled = true
            
        }
        
    }
    
    /// update the timer label to appear like a clock
    func updateTimerLabel(_ timeInSeconds: Int){
        
        var minutes, seconds: Int
        minutes = (timeInSeconds / 60 )
        seconds = timeInSeconds - minutes * 60
        
        timerLabel.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        
    }
  
    
}

/// extension to make UILabel blink
extension UILabel {
    
    func startBlink() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: [.autoreverse, .repeat], animations: {self.alpha = 0 }, completion: nil)
    }
    
    func stopBlink() {
        alpha = 1
        layer.removeAllAnimations()
    }
}

