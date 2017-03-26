//
//  ViewController.swift
//  Calculator
//
//  Created by Wes Auyueng on 3/7/17.
//  Copyright © 2017 Wes AuYeung. All rights reserved.
//

// In our UI, we can also group items together by "Stacks" (technically, embed
// them in Stacks). By doing so, it grants us greater control over how these items
// will appear in different layouts and rotations.

import UIKit

class ViewController: UIViewController {

    // We set the display up as an "Outlet" Connection, which gives us a
    // pointer, with which to refer to the component. Really, this turns the
    // component into an instance variable in our "ViewController" class.
    // Again, type here is referring to the component; i.e. UILabel.
    // Additionally, we will talk about weak / strong storage in a later session
    
    // Normally, UILabel (and any other component, really) will be inserted with a
    // "?", but we can change this to "!" if we **KNOW** that it will always be "set"
    @IBOutlet weak var display: UILabel!
    
    // While we *could* classify a type, 'false' is a Bool by default, and Swift can detect this
    // By declaring a value, we are "initializing" the variable. Note that in the UILabel above,
    // it is automatically initialized to 'nil' as an Optional.
    var userIsTyping = false
    
    // We set this up as an "Action" Connection, which allows us to receive
    // data from the component (a digit button in this case). For an action,
    // we should also specify what "Type" it is (not a datatype, rather a 
    // component type: "UIButton" in this case)
    @IBAction func touchDigit(_ sender: UIButton) {
        // sender.currentTitle is what is known as an "Optional" type
        // Optionals have two states: (i) set and (ii) not set
            // In the set case, it can have an associated value (a side value)
            // When we create the Optional, we can specify what type that value is
            // The "!" at the end grabs the associated value (in the set state)
        // If the Optional is in the "not set" state, the "!" will crash the app
        // This is good for debugging to highlight any errors
        // We "set" the state of an Optional by giving it a title (in the case of a button)
        let digit = sender.currentTitle!
        if userIsTyping {
            let textCurrentlyInDisplay = display.text!
            // We don't have to unwrap an optional when we **SET** (kinda makes sense)
            // We only need to unwrap when we **GET** an optional
            // However, "display" must be unwrapped as it's an optional that
            // (may or may not have the text property??)
            
            // Note that we cannot use the displayValue computed property here (not without
            // some modification of the computation itself). This is because we are expecting
            // a Double in the set method of displayValue. While we could change the code below
            // to create a Double, this creates some unintended consequences, since we would then
            // stringify the Double each time we set it, automatically adding a ".0" if there is
            // only one digit
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
    }
    
    // Swift has "computed properties" which don't store values, per say but actually
    // calculates values on the fly. We can compute a "set" and "get" case
    
    // By doing this, we can have a variable that essentially automates what we do
    // when we set or get it, meaning we can unpack / transform values before assigning
    // to the variable, and can have variables mapped to specific values when we "get" them
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            // You can think of this as the left hand gets "assigned" the righthand
            // value whenever we write (displayValue = [assigned value])
            // "newValue" is always whatever type we set the calling function to be
            // (in this case, Double) and will point to the righthand side of whatever
            // we set displayValue to.
            display.text = String(newValue)
        }
    }
    
    // The type of the CalculatorBrain is inferred in this case, but we could define it
    // with ": CalculatorBrain" if we wanted
    private var brain = CalculatorBrain()
    
    // Be careful when copying and pasting components on the display; they inherit
    // whatever methods are associated with them between copies
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue) // This will be a double
            userIsTyping = false
        }
        // We set this to false whenever we perform an operation; user shouldn't be typing
        // once they hit a performOperation button
        userIsTyping = false
        
        // We can use if statements to check if Optionals are defined before using them
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        
        // Again, this is simply setting if the brain.result Optional is set before we
        // assign its value to displayValue
        if let result = brain.result {
            displayValue = result
        }
        
    }
 
}

