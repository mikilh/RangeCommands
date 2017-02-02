//
//  HelpViewController.swift
//  RangeCommands
//
//  Created by Michael Kilhullen on 1/24/17.
//  Copyright © 2017 Kilhullenhome. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var helpTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "help", withExtension: "rtf") {
            
            var d : NSDictionary? = nil
            let attributedStringWithRtf = try! NSAttributedString(
                url: url,
                options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType],
                documentAttributes: &d)
            helpTextView.attributedText = attributedStringWithRtf
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
