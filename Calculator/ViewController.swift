//
//  ViewController.swift
//  Calculator
//
//  Created by Farkhat on 12/24/20.
//  Copyright © 2020 Farkhat Senalov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var accumulator : Double?
    
    enum operation {
           case Constant(Double)
           case UnaryOperation((Double) -> Double)
           case BinaryOperation((Double,Double) -> Double)
           case Equals
       }
    
    
    var Operations : Dictionary<String,operation> = [
        "AC" : operation.Constant(0),
        "x" : operation.BinaryOperation({$0 * $1}),
        "÷" : operation.BinaryOperation({$0 / $1}),
        "+" : operation.BinaryOperation({$0 + $1}),
        "-" : operation.BinaryOperation({$0 - $1}),
        "=" : operation.Equals
    ]
    
    private var firstNumber = 0.0
    private var resultNumber = 0.0
    private var currentOperations: Operation?
    private var isMidTyping : Bool = false
    private var pending : pendingBinOpInfo?
    
    private var result: Double?{
        get{
            return accumulator
        }
    }
    
    enum Operation {
        case add, subtract, multiply, divide
    }

    private var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont(name: "Helvetica", size: 100)
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNumberPad()
    }


    private func setupNumberPad() {
        let buttonSize: CGFloat = view.frame.size.width / 4
        
        let zeroButton = UIButton(frame: CGRect(x: 0, y: view.frame.size.height-buttonSize, width: buttonSize*2, height: buttonSize))
        zeroButton.setTitleColor(.white, for: .normal)
        zeroButton.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
        zeroButton.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        zeroButton.layer.borderWidth = 1
        zeroButton.setTitle("0", for: .normal)
        zeroButton.tag = 1
        view.addSubview(zeroButton)
        zeroButton.addTarget(self, action: #selector(zeroTapped), for: .touchUpInside)
        
        let dot = UIButton(frame: CGRect(x: buttonSize*2, y: view.frame.size.height-buttonSize, width: buttonSize, height: buttonSize))
        dot.setTitleColor(.white, for: .normal)
        dot.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
        dot.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        dot.layer.borderWidth = 1
        dot.setTitle(".", for: .normal)
        dot.tag = 1
        view.addSubview(dot)
        dot.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        
        for x in 0..<3 {
            let button1 = UIButton(frame: CGRect(x: buttonSize * CGFloat(x), y: view.frame.size.height-(buttonSize*2), width: buttonSize, height: buttonSize))
            button1.setTitleColor(.white, for: .normal)
            button1.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
            button1.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            button1.layer.borderWidth = 1
            button1.setTitle("\(x+1)", for: .normal)
            view.addSubview(button1)
            button1.tag = x+2
            button1.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        }

        for x in 0..<3 {
            let button2 = UIButton(frame: CGRect(x: buttonSize * CGFloat(x), y: view.frame.size.height-(buttonSize*3), width: buttonSize, height: buttonSize))
            button2.setTitleColor(.white, for: .normal)
            button2.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
            button2.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            button2.layer.borderWidth = 1
            button2.setTitle("\(x+4)", for: .normal)
            view.addSubview(button2)
            button2.tag = x+5
            button2.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        }

        for x in 0..<3 {
            let button3 = UIButton(frame: CGRect(x: buttonSize * CGFloat(x), y: view.frame.size.height-(buttonSize*4), width: buttonSize, height: buttonSize))
            button3.setTitleColor(.white, for: .normal)
            button3.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
            button3.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            button3.layer.borderWidth = 1
            button3.setTitle("\(x+7)", for: .normal)
            view.addSubview(button3)
            button3.tag = x+8
            button3.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        }

        let clearButton = UIButton(frame: CGRect(x: 0, y: view.frame.size.height-(buttonSize*5), width: view.frame.size.width - buttonSize, height: buttonSize))
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
        clearButton.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        clearButton.layer.borderWidth = 1
        clearButton.setTitle("AC", for: .normal)
        view.addSubview(clearButton)


        let operations = ["=","+", "-", "x", "÷"]

        for x in 0..<5 {
            let button4 = UIButton(frame: CGRect(x: buttonSize * 3, y: view.frame.size.height-(buttonSize * CGFloat(x+1)), width: buttonSize, height: buttonSize))
            button4.setTitleColor(.white, for: .normal)
            button4.backgroundColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
            button4.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            button4.layer.borderWidth = 1
            button4.setTitle(operations[x], for: .normal)
            view.addSubview(button4)
            button4.tag = x+1
            button4.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
        }

        resultLabel.frame = CGRect(x: 20, y: clearButton.frame.origin.y - 110.0, width: view.frame.size.width - 40, height: 100)
        view.addSubview(resultLabel)

        // Actions
        clearButton.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
    }

    @objc func clearResult() {
        resultLabel.text = "0"
        currentOperations = nil
        firstNumber = 0.0
    }

    @objc func zeroTapped() {

        if resultLabel.text != "0" {
            if let text = resultLabel.text {
                resultLabel.text = "\(text)\(0)"
            }
        }
    }

    @objc func numberPressed(_ sender: UIButton) {
        if isMidTyping{
            if sender.currentTitle! == "." && resultLabel.text!.contains(".") {
                
            }
            else{

                resultLabel.text = resultLabel.text! + sender.currentTitle!
            }
        }
        else{
            resultLabel.text = sender.currentTitle!
            isMidTyping = true
        }
    }
    
    var displayValue : Double {
        get{
            return Double(resultLabel.text!)!
        }
        set{
            resultLabel.text = String(newValue)
        }
    }
    
    func forTrailingZero(temp: Double) -> String {
           let tempVar = String(format: "%g", temp)
           return tempVar
    }

    @objc func operationPressed(_ sender: UIButton) {
        if isMidTyping{
            setOperand(operand: displayValue)
            isMidTyping = false
        }
       
        if let mathSymbol = sender.currentTitle{
            performOperation(symbol: mathSymbol)
        }
       
        if forTrailingZero(temp: result!) == "inf"{
            resultLabel.text = "ERROR"
        }
        else{
            resultLabel.text = forTrailingZero(temp: result!)
        }
    }
    
    func setOperand (operand : Double){
        accumulator = operand
    }
    
    func performOperation (symbol: String){
        if let operation = Operations[symbol]{
            switch operation {
            case .Constant(let value) : accumulator = value
            case .UnaryOperation(let function) : accumulator = function(accumulator!)
            case .BinaryOperation(let function) :
                executeEquals()
                pending = pendingBinOpInfo(binaryOperation: function, firstOperand: accumulator!)
            case .Equals :
                executeEquals()
                
            }
        }
        
    }
    
    func executeEquals(){
        if pending != nil{
            accumulator = pending?.binaryOperation(pending!.firstOperand, accumulator!)
            pending = nil
        }
    }
    
    struct pendingBinOpInfo {
        
        var binaryOperation : (Double,Double) -> Double
        var firstOperand : Double
        
    }

}

