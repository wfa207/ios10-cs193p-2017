//
//  ViewController.swift
//  01_Homework
//
//  Created by Wes Auyueng on 3/20/17.
//  Copyright © 2017 Wes AuYeung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var userIsTyping = false
    
    private var displayInteger = ""
    
    private var displayDecimal = ""
    
    private var displayValueIsDecimal = false
    
    private var model = CalculatorModel()
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    private var displayValue: Double! {
        get {
            return Double(display.text!)
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var descriptionDisplayValue: String! {
        get {
            return descriptionDisplay.text!
        }
        set {
            descriptionDisplay.text = newValue
        }
    }
    
    func getDigitString(from numberString: String) -> String {
        return numberString.characters.count > 0 ? numberString : "0"
    }
    
    func resetDisplay() {
        userIsTyping = false
        displayValueIsDecimal = false
        displayInteger = ""
        displayDecimal = ""
    }
    
    func performOperationWith(_ input: String) -> Void {
        resetDisplay()
        model.performOperationWith(input)
        let (mainDisplayResult, descriptionDisplayResult) = model.result
        displayValue = mainDisplayResult ?? displayValue
        descriptionDisplayValue = descriptionDisplayResult
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if digit == "." { return displayValueIsDecimal = true }
        
        if displayValueIsDecimal { displayDecimal += digit }
        else { displayInteger += digit }
        
        if !userIsTyping { userIsTyping = true }
        
        display.text = getDigitString(from: displayInteger) +
            "." + getDigitString(from: displayDecimal)
    }
    
    @IBAction func touchOperation(_ sender: UIButton) {
        let symbol = sender.currentTitle!
        if symbol != "c" { model.setOperandTo(displayValue) }
        performOperationWith(symbol)
    }
    
}

