//
//  ViewController.swift
//  tipcalculator
//
//  Created by Evelio Tarazona on 3/27/16.
//  Copyright (c) 2016 Evelio Tarazona. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private static let kDotTag = 10
    private static let kDeleteTag = -1
    private static let kInputKey = "input"
    private static let kSelectedIndexKey = "selected_index"
    private static let kSavedDateKey = "saved_date"
    
    @IBOutlet weak var ammountLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipsContainer: UIView!
    @IBOutlet weak var totalSeparator: UIView!
    @IBOutlet weak var tipsControl: UISegmentedControl!
    @IBOutlet weak var deleteButton: ZFRippleButton!
    
    var formatter : NSNumberFormatter {
        let f = NSNumberFormatter()
        f.numberStyle = .CurrencyStyle
        return f
    }
    var ammountString : String = "0"
    var animateIntro : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDeleteButton(_:)))
        deleteButton.addGestureRecognizer(longPress)
        
        calculateTip(restoreState())
    }
    
    func longPressDeleteButton(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.Began {
            ammountString = "0"
            calculateTip(false)
        }
    }
    
    @IBAction func keyboardButtonTap(sender: AnyObject) {
        let dot : Character = "."
        let noDot = !ammountString.characters.contains(dot)
        
        switch sender.tag {
        case ViewController.kDotTag:
            if noDot {
                ammountString.append(dot)
            }
        case ViewController.kDeleteTag:
            ammountString = String(ammountString.characters.dropLast())
        default:
            var enoughDigits = false
            if let dotIndex = ammountString.characters.indexOf(dot) {
                if ammountString.characters.count > 3 {
                    enoughDigits = ammountString.endIndex.predecessor().predecessor().predecessor() == dotIndex
                }
            }
            let acceptDigits = noDot || !enoughDigits
            if acceptDigits {
                let digit = String(sender.tag)
                ammountString.appendContentsOf(digit)
            }
        }
        
        calculateTip()
    }
    
    @IBAction func tipControlValueChanged(sender: AnyObject) {
        calculateTip()
    }
    
    private func calculateTip(revealAll: Bool = true) {
        let tipPercentages = [0.10, 0.20, 0.30]
        let tipPercentage = tipPercentages[tipsControl.selectedSegmentIndex]
        let ammount = Double(ammountString) ?? 0
        let tip = ammount * tipPercentage
        let total = ammount + tip
        updateUI(ammount, tip: tip, total: total, revealAll: revealAll)
        saveState()
    }
    
    enum AppearFrom {
        case Right, Bottom, Current
    }
    
    private func showAnimated(v: UIView, duration: NSTimeInterval, delay: NSTimeInterval, appearFrom : AppearFrom = .Current) {
        weak var view = v
        view?.alpha = 0
        switch appearFrom {
        case .Right:
            view?.center.x = self.view.bounds.width
        case .Bottom:
            view?.center.y += (view?.bounds.height)!
        default:
            break
        }
        
        view?.hidden = false
        UIView.animateWithDuration(duration, delay: delay,options: UIViewAnimationOptions.CurveEaseOut, animations: {
            view?.alpha = 1
            switch appearFrom {
            case .Right:
                view?.center.x -= self.view.bounds.width
            case .Bottom:
                view?.center.y -= (view?.bounds.height)!
            default:
                break
            }
            
            view?.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func updateUI(ammount: Double, tip: Double, total: Double, revealAll : Bool = true) {
        ammountLabel.text = formatter.stringFromNumber(ammount)!
        let tipString = formatter.stringFromNumber(tip)!
        tipLabel.text = "+ \(tipString)"
        totalLabel.text = formatter.stringFromNumber(total)!
        if revealAll && animateIntro {
            animateIntro = false
            
            showAnimated(tipLabel, duration: 0.5, delay: 0.1)
            showAnimated(totalSeparator, duration: 0.4, delay: 0.2, appearFrom: .Right)
            showAnimated(totalLabel, duration: 0.3, delay:  0.3)
            showAnimated(tipsContainer, duration: 0.2, delay: 0.4, appearFrom: .Bottom)
        }
    }
    
    private func lessThan10MinutesAgo(date: NSDate) -> Bool {
        let now = NSDate()
        let minutesSinceDate = NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: now, options: []).minute
        return minutesSinceDate < 10
    }
    
    private func restoreState() -> Bool {
        var restored = false;
        let prefs = NSUserDefaults.standardUserDefaults()
        var selectedIndex = prefs.integerForKey(SettingsViewController.kDefaultSelectedIndexKey)
        
        if let storedDate = prefs.objectForKey(ViewController.kSavedDateKey) {
            if (lessThan10MinutesAgo(storedDate as! NSDate)) {
                if let storedInput = prefs.stringForKey(ViewController.kInputKey) {
                    ammountString = storedInput
                    restored = true
                }
                
                selectedIndex = prefs.integerForKey(ViewController.kSelectedIndexKey)
            }
        }
        tipsControl.selectedSegmentIndex = selectedIndex
        return restored
    }
    
    private func saveState() {
        let savedTime = NSDate()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setObject(savedTime, forKey: ViewController.kSavedDateKey)
        prefs.setObject(ammountString, forKey: ViewController.kInputKey)
        prefs.setInteger(tipsControl.selectedSegmentIndex, forKey: ViewController.kSelectedIndexKey)
        prefs.synchronize()
    }
    
}

