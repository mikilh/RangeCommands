//
//  SettingsTableViewController.swift
//  RangeSignals
//
//  Created by Michael Kilhullen on 1/14/17.
//  Copyright © 2017 Kilhullenhome. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var secondsText: UITextField!
    @IBOutlet weak var timerSwitch: UISwitch!
    
    var soundEffect: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        soundEffect = "whistle"
        
        let defaults = UserDefaults.standard
        timerSwitch.isOn = defaults.bool(forKey: "RangeCommands.timerSwitch")
        secondsText.text = "\(defaults.integer(forKey: "RangeCommands.seconds"))"
        if let sound = defaults.string(forKey: "RangeCommands.sound") {
            soundEffect = sound
        } 
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }
        return 1
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectSound()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(timerSwitch.isOn , forKey: "RangeCommands.timerSwitch")
        defaults.set(Int(secondsText.text!), forKey: "RangeCommands.seconds")
        defaults.set(soundEffect, forKey: "RangeCommands.sound")
    }
  
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
    
    func getSoundName(_ row: Int) -> String {
        switch row {
        case 0: return "buzzer"
        case 1: return "buzzer2"
        default: return "whistle"
        }
    }
    
    func deSelectSound(){
      
        for row in 0...2 {
            let indexPath = IndexPath(row: row, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
        }
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
}
