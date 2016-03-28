//
//  SettingsViewController.swift
//  tipcalculator
//
//  Created by Evelio Tarazona on 9/25/16.
//  Copyright © 2016 Evelio Tarazona. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    static let kDefaultSelectedIndexKey = "default_selected_index"
    
    @IBOutlet weak var defaultTipControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restoreState()
    }
    
    @IBAction func closeTaped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func defaultTipValueChanged(sender: AnyObject) {
        saveState()
    }
    
    
    private func restoreState() {
        let prefs = NSUserDefaults.standardUserDefaults()
        defaultTipControl.selectedSegmentIndex = prefs.integerForKey(SettingsViewController.kDefaultSelectedIndexKey)
    }
    
    private func saveState() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setInteger(defaultTipControl.selectedSegmentIndex, forKey: SettingsViewController.kDefaultSelectedIndexKey)
        prefs.synchronize()
    }
}