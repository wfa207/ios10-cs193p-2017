//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Wes Auyueng on 3/11/17.
//  Copyright © 2017 Wes AuYeung. All rights reserved.
//

// We import "Foundation" here instead of "UIKit" because this is our model
// and thus, it is UI independent
import Foundation


/* While this certainly could have worked, it's much easier and nicer to use
 "Closures" (see below in the operations Dictionary */

/* func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}
 
func changeSign(operand: Double) -> Double {
    return -operand
} */

// Struct is essentially a class but it is *non-mutable*
    // We can see this in the code below where we mark certain methods as "mutating"
    // Many classes in Swift are actually Structs: Strings, Doubles, etc.
// Classes have inheritance but Structs *do not*
    // So, if you have something that you want to be sub-classed later, it must be a class
// Classes live in the "Heap" whereas Structs are passed throughout the application by copy
    // Thus, classes are always referred to with pointers (reference type) and updates to a 
    // single class will update all of its descendants. Each time a Struct is passed into a
    // function, a copy is being modified (value type).
struct CalculatorBrain {
    
    // Our accumulator variable is what is going to collect our inputs in our app
    
    // The "private" keyword maintains that the accumulator var is an internal
    // variable that cannot be accessed outside of this Struct
    
    // Note that we do *not* need an initializer for the accumulator variable, a
    // trait that is *specific* to Structs
    
    // While this is initialized, we don't actually want it to be so, so we set it
    // to a Double Optional with the "?"
    private var accumulator: Double?
    
    // We can also create a new type within this CalculatorBrain Struct that we will
    // use in defining our operations Dictionary below. This new type will be a bit
    // more flexible and can either be a function or a value
    
    // Enums can be very powerful and are in fact how Optionals are defined. Each
    // case within an enum can have an "associated value" which is what is passed
    // into the parentheses.
    private enum Operation {
        case constant(Double)
        // A function is a type like a Double, String, etc. The only difference is
        // we don't need to define the function by a keyword but rather just define
        // the function itself
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    // Instead of using a switch statement like the one below, we can store all of
    // our symbols / operators inside a table (Dictionary, like Python) and just
    // reference that before we perform each operation
    
    // When we create a Dictionary we have to declare the type of the key and the
    // type of the value it stores
    private var operations: Dictionary<String, Operation> = [
        "c": Operation.constant(0),
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        /* We can use closures, which are basically in-line anonymous functions.
         Closures follow the following format (an add function):
            {($0: Double, $1: Double) -> Double in return $0 + $1 }
         However, we don't always need all of the syntax above, Swift assumes that
         we will return something from a closure, so whatever follows the "in"
         keyword will implicitly be returned. In addition, since we define the types
         in our Operation enum, which Swift uses to classify the arguments in our
         closure. Finally, because we can refer to arguments in a closure generically
         (with $0, $1, $2, etc.), we don't even need to specify the arguments upfront.
         */
        "±": Operation.unaryOperation({-$0}),
        "×": Operation.binaryOperation({$0 * $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "=": Operation.equals
    ]
    
    // Remember the underscore essentially allows us to eliminate the need for a
    // public argument variable. So in this case, we can call performOperation with
        // performOperation('π')
    mutating func performOperation(_ symbol: String) {
        // We can use if statements to check if Optionals are defined before using them
        /* switch symbol {
        case "π":
            // We could just cast this to a string with '"\()"', but a better method
            // is to create a new String instance
            
            // We now set this to accumulator since the Brain (or model) is not
            // necessarily aware of the UI component it is altering
            accumulator = Double.pi
        case "√":
            // Operand is actually an Optional Double in this case because
            // there is a chance that display!.text! may not be convertible to a Double
            // By using "!" to unwrap the Double, we are assuming that operand will
            // **NEVER** be a true "String" (i.e. "Hello", "Welcome", "WOT M8?")
            
            // We now change this to accumulator. 
            if let operand = accumulator {
                accumulator = sqrt(operand)
            }
        default:
            break
        }*/
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let fn):
                if accumulator != nil {
                    accumulator = fn(accumulator!)
                }
            case .binaryOperation(let fn):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: fn, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
        
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    // We're setting this as an optional because we are not *always* in a pending
    // binary operation (if we press sqrt then we are not in a pending binary
    // operation)
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        // Note that this does not need to be "mutating" because we aren't
        // actually changing any properties on the struct
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    // This basically tells Swift that we are indeed writing to a private variable
    // When we do, Swift creates a copy of the Struct to be modified
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    // While "let" makes a variable "read-only" in some sense, it also limits us
    // to only being able to write the variable once
    
    // We set result to an Optional because there are cases where the result may
    // not be set. I.e. when we are in the middle of an operation (like after we
    // press "*" in 5 * 3)
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
