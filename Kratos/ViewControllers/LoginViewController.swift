//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var phoneNumberUnderlineView: UIView!
    
    @IBOutlet var phoneNumberFullWidthConstraint: NSLayoutConstraint!
    @IBOutlet var phoneNumberNoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordUnderlineView: UIView!
    
    @IBOutlet var passwordFullWidthConstraint: NSLayoutConstraint!
    @IBOutlet var passwordNoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordConfirmationTextField: UITextField!
    @IBOutlet var passwordConfirmationUnderlineView: UIView!
    
    @IBOutlet var passwordConfirmationFullWIdthConstraint: NSLayoutConstraint!
    @IBOutlet var passwordConfirmationNoWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmationTextField.delegate = self
    }
    
    func beginningAnimations() {
        phoneNumberTextField.alpha = 0.01
        passwordTextField.alpha = 0.01
        passwordConfirmationTextField.alpha = 0.01
        
        UIView.animateWithDuration(1, delay: 1, options: [], animations: {
            self.phoneNumberNoWidthConstraint.active = false
            self.phoneNumberFullWidthConstraint.active = true
            
            self.passwordNoWidthConstraint.active = false
            self.passwordFullWidthConstraint.active = true

            self.passwordConfirmationNoWidthConstraint.active = false
            self.passwordConfirmationFullWIdthConstraint.active = true
            
        })
        UIView.animateWithDuration(0.5, delay: 4, options: [UIViewAnimationOptions.TransitionCrossDissolve], animations: {
            self.phoneNumberTextField.alpha = 1
            self.passwordTextField.alpha = 1
            self.passwordConfirmationTextField.alpha = 1
        })

    }
    
    func textFieldsValid() -> Bool {
        var valid = true
        let collection = [
            InputValidation.validatePhoneNumber(phoneNumberTextField.text)
        ]
        for (isValid, view) in collection {
            animate(view, with: isValid)
            if !isValid {
                valid = false
            }
        }
        return valid
    }
    
}
