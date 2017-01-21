//
//  SettingsTableViewController.swift
//  RangeSignals
//
//  Created by Michael Kilhullen on 1/14/17.
//  Copyright © 2017 Kilhullenhome. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timerSwitch: UISwitch!
    @IBOutlet weak var stepper: UIStepper!
    
    var soundEffect: String!
    
    // MARK: - Actions

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        
        updateTimeLabel(Int(sender.value))
    }
    
    @IBAction func timerSwitched(_ sender: UISwitch) {
        
        stepper.isEnabled = sender.isOn
        updateTimeLabel(Int(stepper.value))
        
    }
 
    // MARK: - Overrides
    
    /// load the user defaults; set default value if none exist yet
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        timerSwitch.isOn = defaults.bool(forKey: "RangeCommands.timerSwitch")
        let seconds = defaults.integer(forKey: "RangeCommands.seconds")
        
        if let sound = defaults.string(forKey: "RangeCommands.sound") {
            soundEffect = sound
        } else {
            soundEffect = "whistle"
        }
        
        //setup the stepper
        stepper.wraps = true
        stepper.autorepeat = true
        stepper.minimumValue = 30
        stepper.maximumValue = 300
        stepper.stepValue = 15.0
        
        //set values if timer is on
        if timerSwitch.isOn {
            stepper.value = Double(seconds)
            updateTimeLabel(seconds)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectSound()

    }
    
    /// save defaults 
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(timerSwitch.isOn , forKey: "RangeCommands.timerSwitch")
        var seconds: Int
        if !timerSwitch.isOn {
            seconds = 0
        } else {
            seconds=Int(stepper.value)
        }
        defaults.set(seconds, forKey: "RangeCommands.seconds")
        defaults.set(soundEffect, forKey: "RangeCommands.sound")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark;
        soundEffect = getSoundName(indexPath.row)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
  
    // MARK: - class methods
    
    /// update the time label to look like a time value
    func updateTimeLabel(_ withSeconds: Int) {
        
        if (!timerSwitch.isOn) {
            timeLabel.text = nil
            return
        }
        
        var minutes, seconds: Int
        
        minutes = withSeconds / 60
        seconds = withSeconds - minutes * 60
        
        timeLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
        
    }
    
    /// translate standard sound name to its row
    func selectSound(){
        var row: Int
        switch soundEffect! {
        case "buzzer": row = 0
        case "buzzer2": row = 1
        default: row = 2
        }
        let indexPath = IndexPath(row: row, section: 1)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    /// translate the row back to the standard sound name
    func getSoundName(_ row: Int) -> String {
        switch row {
        case 0: return "buzzer"
        case 1: return "buzzer2"
        default: return "whistle"
        }
    }
    
    /// only one sound can be picked so clear all accessories
    func deSelectSound(){
      
        for row in 0...2 {
            let indexPath = IndexPath(row: row, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
        }
    }
    

}
