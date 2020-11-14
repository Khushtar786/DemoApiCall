//
//  Constant.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import UIKit
import Foundation

struct Constant {
    
    static var isDebugingEnabled: Bool {
        return true
    }
}


extension UIViewController {
    func changeDateformat(dateString: String,currentFomat:String, expectedFromat: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = currentFomat
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = expectedFromat
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    func ShowAlert(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default, handler: handler)
            alertController.addAction(action)
            
            // busy(on: false)
            
            self.present(alertController, animated: true)
        }
    }
    func AlertViewConfirm(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: handler)
            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No", style: .cancel)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    //
    func displayAlert(with title: String?, message: String?, buttons: [String], buttonStyles: [UIAlertAction.Style] = [], handler: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for i in 0 ..< buttons.count {
                let style: UIAlertAction.Style = buttonStyles.indices.contains(i) ? buttonStyles[i] : .default
                let buttonTitle = buttons[i]
                let action = UIAlertAction(title: buttonTitle, style: style) { (_) in
                    handler(buttonTitle)
                }
                alertController.addAction(action)
            }
            self.present(alertController, animated: true)
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // function for the change border color
       func changeBorderColor(borderView:UIView, chngColor:Bool) {
           var changeColor = chngColor
           if changeColor == true {
               borderView.layer.borderWidth = 1
               borderView.layer.borderColor = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7843137255, alpha: 1)
           } else {
               changeColor = false
               borderView.layer.borderWidth = 0
           }
       }
}
