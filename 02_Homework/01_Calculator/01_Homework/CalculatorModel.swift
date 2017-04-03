//
//  CalculatorModel.swift
//  01_Homework
//
//  Created by Wes Auyueng on 3/20/17.
//  Copyright © 2017 Wes AuYeung. All rights reserved.
//

import Foundation

/**
 Model associated with the Calculator's view
 
 - Author: Wes AuYeung
*/

struct CalculatorModel {
    
    private var accumulator: Double?
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private var description: String = ""
    
    private var calculationIsNew: Bool {
        get {
            return description.characters.count == 0
        }
    }
    
    var result: (displayResult: Double?, descriptionResult: String) {
        get {
            return (accumulator ?? 0, description)
        }
    }
    
    private struct PendingBinaryOperation {
        let firstOperand: Double
        let pendingOperation: (Double, Double) -> Double
        
        func perform(on secondOperand: Double) -> Double {
            return pendingOperation(firstOperand, secondOperand)
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, Position)
        case binaryOperation((Double, Double) -> Double)
        case clear
        case equals
    }
    
    private enum Position {
        case before(String?)
        case after(String?)
    }
    
    /**
     Contains all possible operations the Calculator is currently capable of
    */
    
    private let operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "cos": Operation.unaryOperation(cos, Position.before(nil)),
        "sin": Operation.unaryOperation(sin, Position.before(nil)),
        "tan": Operation.unaryOperation(tan, Position.before(nil)),
        "√": Operation.unaryOperation(sqrt, Position.before(nil)),
        "±": Operation.unaryOperation({-$0}, Position.before("-")),
        "x²": Operation.unaryOperation({$0 * $0}, Position.after("²")),
        "x³": Operation.unaryOperation({$0 * $0 * $0}, Position.after("³")),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "c": Operation.clear,
        "=": Operation.equals
    ]
    
    /**
     Performs the operation associated with the symbol pressed
     
     - Returns: Nothing (Void type)
     
     - Parameters:
        - symbol: Symbol entered from pressing a digit on the calculator view
     - Requires: accumulator != nil
     - Requires: pendingBinaryOperation != nil
            when operation == .binaryOperation or operation == .equals
    */
    
    mutating func performOperationWith(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let constant):
                accumulator = constant
                description += "\(accumulator!)"
            case .unaryOperation(let fn, let position):
                if accumulator != nil {
                    if calculationIsNew {
                        description = String(accumulator!)
                    }
                    accumulator = fn(accumulator!)
                    switch position {
                    case .before(let character):
                        let descriptionCharacter = character ?? symbol
                        description = "\(descriptionCharacter)(\(description))"
                    case .after(let character):
                        let descriptionCharacter = character ?? symbol
                        description = "(\(description))\(descriptionCharacter)"
                    }
                }
            case .clear:
                accumulator = nil
                description = ""
                pendingBinaryOperation = nil
            case .binaryOperation(let fn):
                if accumulator != nil {
                    if resultIsPending {
                        description += " \(accumulator!)"
                        accumulator = pendingBinaryOperation!.perform(on: accumulator!)
                    } else {
                        pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, pendingOperation: fn)
                        if calculationIsNew {
                            description += "\(accumulator!) \(symbol)"
                        } else {
                            description += " \(symbol)"
                        }
                    }
                }
            case .equals:
                if accumulator != nil && resultIsPending {
                    description += " \(accumulator!)"
                    accumulator = pendingBinaryOperation!.perform(on: accumulator!)
                    pendingBinaryOperation = nil
                }
            }
        }
    }
    
    mutating func setOperandTo(_ operand: Double) {
        accumulator = operand
    }
    
}
