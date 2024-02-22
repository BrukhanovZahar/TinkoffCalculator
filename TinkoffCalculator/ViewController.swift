//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Захар Брюханов on 31.01.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String{
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
            case .add:
                return number1 + number2
            case .substract:
                return number1  - number2
            case .multiply:
                return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.dividedByZero
                }
                
                return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

protocol LongPressViewProtocol {
    var shared: UIView { get }
    
    func startAnimation()
    func stopAnimation()
}

class ViewController: UIViewController, LongPressViewProtocol {
    
    var shared: UIView = UIView()
    var animator: UIViewPropertyAnimator?
    
    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertWidth / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if label.text == "Ошибка" {
            resetLabelText()
        }
        
        if label.text == "0" && buttonText == "," {
            label.text = "0,"
        } else if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
        
        if label.text == "3,14159" {
            animateAlert()
        }
        
        sender.animateTap()
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: NSDate() as Date)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
            wasCalculation = true
            lastResult = result
        } catch {
            label.text = "Ошибка"
            label.shake()
        }
        
        
        calculationHistory.removeAll()
    }
    
    func animateAlert() {
            if !view.contains(alertView) {
                alertView.alpha = 0
                alertView.center = view.center
                alertView.tintColor = UIColor.white
                
                view.addSubview(alertView)
            }
            
            alertView.transform = CGAffineTransform(scaleX: 1, y: 1)
            alertView.layer.cornerRadius = 30
            alertView.clipsToBounds = true
            
            UIView.animateKeyframes(withDuration: 2.0, delay: 0.5) {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.alertView.alpha = 1
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    var newCenter = self.label.center
                    newCenter.y -= self.alertView.bounds.height
                    self.alertView.center = newCenter
                }
            }
        }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
              if sender.state == .began {
                  startAnimation()
              } else if sender.state == .ended {
                  stopAnimation()
              }
          }
        
    func startAnimation() {
        shared = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shared.backgroundColor = .systemOrange
        shared.center = view.center
        
        let circlePath = UIBezierPath(ovalIn: shared.bounds)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shared.layer.mask = shapeLayer
        
        view.addSubview(shared)
        
        animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeIn) {
            self.shared.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
        }
        
        animator?.startAnimation()
    }
    
    func stopAnimation() {
        animator?.stopAnimation(true)
        animator = nil
        shared.removeFromSuperview()
    }
    
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    let calculationHistoryStorage = CalculationHistoryStorage()
    var wasCalculation: Bool = false
    var lastResult: Double = 0.0
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Калькулятор"
        historyButton.accessibilityIdentifier = "historyButton"
        resetLabelText()
        calculations = calculationHistoryStorage.loadHistory()
        
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"
        
        view.subviews.forEach {
            if type(of: $0) == UIButton.self {
                $0.layer.cornerRadius = 15
            }
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        view.addGestureRecognizer(longPressGesture)
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
//            if wasCalculation {
//                vc.result = numberFormatter.string(from: NSNumber(value: lastResult))
//            } else {
//                vc.result = "NoData"
//            }
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetLabelText() {
        label.text = "0"
    }
}

extension UILabel {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        
        layer.add(animation, forKey: "position")
    }
}

extension UIButton {
    
    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opasity")
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        layer.add(animationGroup, forKey: "groupAnimation")
    }
}
